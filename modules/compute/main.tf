data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  base_tags = {
    Environment = var.environment
    Creator     = var.prefname
    Purpose     = var.purpose
  }

  key_name           = "${var.prefname}-ssh-key-1"
  private_key_output = length(var.private_key_path) > 0 ? var.private_key_path : "${path.module}/${var.prefname}-ssh-key-1.pem"
  db_host            = split(":", var.db_endpoint)[0]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "ssh_private_key" {
  filename        = local.private_key_output
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "ssh" {
  key_name   = local.key_name
  public_key = tls_private_key.ssh.public_key_openssh

  tags = merge(local.base_tags, {
    Name = local.key_name
  })
}

resource "aws_iam_role" "bastion" {
  name               = "${var.prefname}-bastion-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-bastion-role"
  })
}

resource "aws_iam_role" "app" {
  name               = "${var.prefname}-app-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-app-role"
  })
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefname}-bastion-profile"
  role = aws_iam_role.bastion.name
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.prefname}-app-profile"
  role = aws_iam_role.app.name
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = aws_key_pair.ssh.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.bastion.name

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-bastion-1"
  })
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.prefname}-app-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ssh.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    db_host     = local.db_host
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_type           = "gp3"
      volume_size           = 20
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.base_tags, {
      Name = "${var.prefname}-app-instance"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.base_tags, {
      Name = "${var.prefname}-app-volume"
    })
  }

  tags = merge(local.base_tags, {
    Name = "${var.prefname}-app-lt"
  })
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.prefname}-app-asg"
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1
  vpc_zone_identifier       = var.private_app_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefname}-app-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Creator"
    value               = var.prefname
    propagate_at_launch = true
  }

  tag {
    key                 = "Purpose"
    value               = var.purpose
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.prefname}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.prefname}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.app.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.prefname}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.prefname}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

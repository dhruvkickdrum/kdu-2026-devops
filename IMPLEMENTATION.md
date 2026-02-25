

Instead of writing everything in one large Terraform file, the infrastructure is broken into logical, reusable modules. This approach makes the project:

- Easier to understand  
- Easier to maintain  
- Scalable for future enhancements  
- Closer to real-world industry practices  

The infrastructure includes:

- Networking (VPC, subnets, routing)
- Security groups
- RDS MySQL database
- EC2 Auto Scaling Group
- Application Load Balancer

Everything is orchestrated from the root `main.tf`.

---

# Architecture Summary

This implementation follows the **classic Three-Tier Architecture pattern**:

1. **Presentation Layer**
   - Application Load Balancer (ALB)
   - Internet-facing

2. **Application Layer**
   - EC2 instances in Auto Scaling Group
   - Hosted in private subnet

3. **Database Layer**
   - RDS MySQL
   - Isolated in private DB subnets

We also include:
- A Bastion host for secure SSH access
- CloudWatch alarms for scaling policies


---

# Complete Implementation Flow (Step-by-Step)

When we run: terraform apply


Terraform executes the following logical flow:

---

## Provider Configuration (Root Level)

The root `main.tf` configures:

- AWS Provider
- Deployment region (`var.aws_region`)

This ensures all infrastructure is provisioned in the correct AWS region.

---

## Networking Layer – `modules/vpc`

This module creates:

- VPC
- Internet Gateway
- NAT Gateway
- 2 Public Subnets
- 1 Private App Subnet
- 2 Private DB Subnets
- Route Tables and Associations

### Why Separate Subnets?

| Subnet Type | Purpose |
|-------------|----------|
| Public      | ALB & Bastion |
| Private App | EC2 application servers |
| Private DB  | RDS Database |

This separation improves **security and isolation**.

### Outputs Provided:

- `vpc_id`
- `public_subnet_ids`
- `private_app_subnet_ids`
- `db_subnet_ids`

These outputs are passed to other modules.

---

## Security Layer – `modules/security`

Creates four security groups:

| Security Group | Allows |
|----------------|--------|
| ALB SG | HTTP from internet |
| App SG | Traffic only from ALB |
| DB SG | MySQL only from App SG |
| Bastion SG | SSH from allowed IP |

### Important Design Decision

Only IDs are passed between modules — not entire resource objects.  
This avoids Terraform dependency cycles.

---

## Database Layer – `modules/database`

Creates:

- `aws_db_subnet_group`
- `aws_db_instance` (MySQL)

The database:

- Is deployed in private DB subnets
- Is NOT publicly accessible
- Uses DB security group
- Is isolated from the internet

### Output:

- `db_endpoint`

This endpoint is injected into the compute layer.

⚠ RDS creation takes time (5–10 minutes).

---

## Compute Layer – `modules/compute`

This module provisions:

- SSH Key pair
- IAM role
- Launch Template
- Auto Scaling Group
- CloudWatch alarms
- Scaling policies

The Launch Template uses:
user_data.sh.tftpl


This script:

- Installs required packages
- Configures backend
- Connects application to RDS
- Starts the application

The Auto Scaling Group:

- Deploys instances in private app subnets
- Uses App security group
- Automatically scales based on CPU metrics

---

## Load Balancer Layer – `modules/load_balancer`

Creates:

- Application Load Balancer
- Target Group
- Listener
- ASG attachment

The ALB:

- Lives in public subnets
- Accepts HTTP requests
- Routes traffic to EC2 instances

---

## Root Orchestration

The root `main.tf` connects everything together.


After deployment, outputs include:

- ALB DNS
- DB Endpoint
- ASG Name
- Bastion Public IP


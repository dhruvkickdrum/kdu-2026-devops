terraform {
  backend "s3" {
    bucket         = "dhruv-tf-state-bucket"
    key            = "assignment-2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "dhruv-terraform-locks"
    encrypt        = true
  }
}
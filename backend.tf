terraform {
  backend "s3" {
    bucket       = "dhruv-three-tier-app-tfstate"
    key          = "dhruv-app/dev/terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}

locals {
  prefix = "${terraform.workspace}-${var.prefix}"
  common_tags = {
    ManagedBy   = "Terraform"
    Department  = "systems",
    Provider    = "Company Name",
    Owner       = "DevOps Team"
    Billing     = "Infrastructure"
    Environment = terraform.workspace
    UserEmail   = "infra@gmail.com"
  }
}

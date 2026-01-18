terraform {
  backend "s3" {
    bucket         = "azodha-terraform-state-404967771393"
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "azodha-terraform-locks"
  }
}

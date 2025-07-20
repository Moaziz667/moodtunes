terraform {
  cloud {
    organization = "Asm_aziz_stage"

    workspaces {
      name = "deploy-infra-monile"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

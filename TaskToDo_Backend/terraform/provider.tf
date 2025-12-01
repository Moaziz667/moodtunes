terraform {
  cloud {
    organization = "Asm_aziz_stage"

    workspaces {
      name = "deploy-infra-monile"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.14"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# MongoDB Atlas Provider
# Set MONGODB_ATLAS_PUBLIC_KEY and MONGODB_ATLAS_PRIVATE_KEY env vars in CI/CD
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

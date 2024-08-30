terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.62.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region

  default_tags {
    tags = {
      Service = "ws-service"
      Owner   = "dominik"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"

  default_tags {
    tags = {
      Service = "ws-service"
      Owner   = "dominik"
    }
  }
}
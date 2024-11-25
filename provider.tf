terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.49.0"
    }
  }
}

# Provider principal na região sa-east-1
provider "aws" {
  region = "sa-east-1"
}

# Provider específico para recursos que precisam estar em us-east-1 (como certificados para CloudFront)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}
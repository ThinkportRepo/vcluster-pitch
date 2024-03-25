terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.7.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.17.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
  }

  required_version = "~> 1.3"
}

provider "aws" {
  region = "eu-central-1"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
}
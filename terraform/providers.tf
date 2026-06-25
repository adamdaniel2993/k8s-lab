terraform {
  backend "s3" {
    bucket         = "axd3-terraformstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "axd3-terraform-state"
  }

  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
   kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:us-east-1:674288684391:cluster/axd3-cluster"
}

provider "aws" {
  region = var.region
  # assume_role {           #Assume role commented until I create pipeline, now testing localy
  #   role_arn = var.target_arn
  # }
  default_tags {
    tags = {
      Terraform = "Yes"
    }
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }

  registries = [
    {
      url      = "oci://public.ecr.aws/"
      username = data.aws_ecrpublic_authorization_token.token.user_name
      password = data.aws_ecrpublic_authorization_token.token.password
    }
  ]
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.main.token
  load_config_file       = false
}

data "aws_vpc" "selected" {
  tags = {
    Environment = "test"
    Name        = "k8s-test-vpc"
  }
}

data "aws_subnets" "public_subnets" {
  tags = {
    Network = "Public"
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnets" "private_subnets" {
  tags = {
    Network = "Private"
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_ecrpublic_authorization_token" "token" {
}

data "aws_eks_cluster_auth" "main" {
  name = module.eks.cluster_name
}
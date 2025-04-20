#### VPC and Security ########

data "aws_vpc" "test_k8s_vpc" {
  tags = {
    Name = "k8s-test-vpc"
  }
}

data "aws_subnets" "test_k8s_private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.test_k8s_vpc.id]
  }
  tags = {
    Network = "Private"
  }
}

data "aws_subnets" "test_k8s_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.test_k8s_vpc.id]
  }
  tags = {
    Network = "Public"
  }
}
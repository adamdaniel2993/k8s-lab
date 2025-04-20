module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = var.cluster_name
  cluster_endpoint_public_access = true
  node_security_group_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = null
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }


  vpc_id                   = data.aws_vpc.test_k8s_vpc.id
  subnet_ids               = data.aws_subnets.test_k8s_private_subnets.ids
  control_plane_subnet_ids = data.aws_subnets.test_k8s_private_subnets.ids #This is external configuration for control plane node in case you wants to expand nodes

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    axd3-wg = {
      min_size     = 2
      max_size     = 10
      desired_size = var.node_group_desire_size

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "Terraform"
      }
    }
  }

}
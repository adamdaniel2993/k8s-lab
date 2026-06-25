module "eks" {
  source             = "terraform-aws-modules/eks/aws"
  version            = "~> 21.0"
  name               = var.cluster_name
  kubernetes_version = "1.33"

  addons = {
    coredns = {
      configuration_values = jsonencode({
        #this toleration is for codeDNS because this addon does not have a very open wide toleration (Exist) so I need to specify a toleration System = true so it can run in managed nodes
        tolerations = [{
          key      = "system",
          value    = "true"
          operator = "Equal"
          effect   = "NoSchedule"
        }]
      })
    }
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  endpoint_public_access = true
  endpoint_public_access_cidrs = ["104.28.233.94/32", "104.28.201.93/32", "104.28.201.95/32" ]
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
  node_security_group_tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
  enable_cluster_creator_admin_permissions = true

  vpc_id                   = data.aws_vpc.selected.id
  subnet_ids               = [data.aws_subnets.private_subnets.ids[0], data.aws_subnets.private_subnets.ids[1]]
  control_plane_subnet_ids = [data.aws_subnets.private_subnets.ids[0], data.aws_subnets.private_subnets.ids[1]]

  eks_managed_node_groups = {
    systemnodes = {

      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2
      # iam_role_additional_policies = {
      #   Ec2FullAccess="arn:aws:iam::aws:policy/AmazonEC2FullAccess"
      # }

      metadata_options = {
        http_tokens = "optional"
      }

 #Here is the taint configuration, just pod with toleration system=true can run on managed nodes
      taints = {
        systempodstaint = {
          key    = "system"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

}
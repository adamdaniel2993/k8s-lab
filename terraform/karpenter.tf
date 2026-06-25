module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name = module.eks.cluster_name
  create_pod_identity_association = true
  namespace = "karpenter"


  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

#NOTE: This karpenter module will create an IAM role for use pod identity, and a role that karpenter ec2 will use as instance role

resource "kubernetes_namespace_v1" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "helm_release" "karpenter" {
  namespace           = "karpenter"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter" #we are autenticating from provider, when you use OCI as repo HELM tries to auth by default even if the repo is public, thats why we have the datasource looking for public.ecr credentials
  chart               = "karpenter"
  version             = "1.12.0"
  wait                = false
  upgrade_install     = true

  values = [
    <<-EOT
    serviceAccount:
      name: ${module.karpenter.service_account}
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    tolerations:
    - key: "system"
      value: "true"
      operator: "Equal"
      effect: "NoSchedule"
    EOT
  ]
  depends_on = [kubernetes_namespace_v1.karpenter]
}


############################################################################################################################################################################
# Nodepools and EC2NodeClass
############################################################################################################################################################################
# This example NodePool will provision general purpose instances
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML

apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: general-purpose
  annotations:
    kubernetes.io/description: "General purpose NodePool for generic workloads"
spec:
  template:
    spec:
      taints:
        - key: podtype
          value: workload
          effect: NoSchedule
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["1"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
   YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1
    kind: EC2NodeClass
    metadata:
      name: default
      annotations:
        kubernetes.io/description: "General purpose EC2NodeClass for running Amazon Linux 2 nodes"
    spec:
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${var.cluster_name}"
      amiSelectorTerms:
        - alias: al2023@latest # Amazon Linux 2023
    YAML

  depends_on = [
    helm_release.karpenter
  ]
}

###############################################################################
# Inflate deployment
###############################################################################
resource "kubectl_manifest" "karpenter_example_deployment" {
  yaml_body = <<-YAML
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: inflate
      namespace: test-karp
    spec:
      replicas: 0
      selector:
        matchLabels:
          app: inflate
      template:
        metadata:
          labels:
            app: inflate
        spec:
          terminationGracePeriodSeconds: 0
          containers:
            - name: inflate
              image: public.ecr.aws/eks-distro/kubernetes/pause:3.7
              resources:
                requests:
                  cpu: 1
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}
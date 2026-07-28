resource "helm_release" "ascp" {
  name       = "secrets-provider-aws"
  namespace  = "kube-system"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = "3.1.2"
  values = [
    <<-EOT
    # The provider is a DaemonSet - it must run on every node that can host a pod
    # mounting a CSI secret, otherwise the mount fails on nodes without it.
    tolerations:
      - key: "podtype"
        value: "workload"
        operator: "Equal"
        effect: "NoSchedule"
      - key: "system"
        value: "true"
        operator: "Equal"
        effect: "NoSchedule"

    secrets-store-csi-driver:
      syncSecret:
        enabled: true
      tolerations:
        - key: "podtype"
          value: "workload"
          operator: "Equal"
          effect: "NoSchedule"
        - key: "system"
          value: "true"
          operator: "Equal"
          effect: "NoSchedule"
    EOT
  ]

  depends_on = [module.eks]
}

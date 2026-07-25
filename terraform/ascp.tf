resource "helm_release" "ascp" {
  name       = "secrets-provider-aws"
  namespace  = "kube-system"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = "3.1.2"
  values = [
    <<-EOT
    usePodIdentity: "true"
    tolerations:
      - key: "podtype"
        value: "workload"
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
    EOT
  ]

  depends_on = [module.eks]
}

# creating argocd namepsace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

#installing argocd helm chart
resource "helm_release" "argocd" {
  depends_on = [kubernetes_namespace.argocd]

  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.7.1"

values = [
  file("${path.module}/argo/argocd_values.yaml")
]
timeout = 600  # Increase timeout to 10 minutes
}



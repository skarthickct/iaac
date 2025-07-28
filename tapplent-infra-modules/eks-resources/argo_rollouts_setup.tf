resource "kubernetes_namespace" "argo-rollouts" {
  metadata {
    name = "argo-rollouts"
  }
}

resource "helm_release" "argo-rollouts" {
  depends_on = [kubernetes_namespace.argo-rollouts]
  name       = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-rollouts"
  namespace  = "argo-rollouts"
  version    = "2.37.8"
}



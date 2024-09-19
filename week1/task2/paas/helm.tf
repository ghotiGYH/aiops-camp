resource "helm_release" "crossplane" {
  depends_on       = [module.k3s, null_resource.download_k3s_yaml]
  name             = "crossplane"
  repository       = "https://charts.crossplane.io/stable"
  chart            = "crossplane"
  namespace        = "crossplane-system"
  create_namespace = true
}

resource "helm_release" "argo_cd" {
  depends_on       = [module.k3s, null_resource.download_k3s_yaml]
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
}

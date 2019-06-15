resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
}
resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
        name = "tiller"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "system:serviceaccount:kube-system:tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind  = "ClusterRole"
    name = "cluster-admin"
  }
  depends_on = ["kubernetes_service_account.tiller"]
}

# Initialize Helm (and install Tiller)
provider "helm" {
  install_tiller = true
    service_account = "tiller"
    namespace = "kube-system"

  kubernetes {
    host                   = "${azurerm_kubernetes_cluster.aksqse.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.cluster_ca_certificate)}"
  }
}
# Add Kubernetes Stable Helm charts repo
# data "helm_repository" "stable" {
#     name = "stable"
#     url  = "https://kubernetes-charts.storage.googleapis.com"
# }

data "helm_repository" "qlik-edge" {
  name = "qlik-edge"
  url  = "https://qlik.bintray.com/edge"
}

resource "helm_release" "qseonk8s-init" {
  name       = "qseonk8s-init"
  repository = "${data.helm_repository.qlik-edge.metadata.0.name}"
  chart      = "qliksense-init"
  #version    = "latest"

  # values = [
  #   "${file("./scripts/basic.yaml")}"
  # ]

}
resource "helm_release" "qseonk8s" {
  name       = "qseonk8s"
  repository = "${data.helm_repository.qlik-edge.metadata.0.name}"
  chart      = "qliksense"
  #version    = "latest"

  values = [
    "${file("scripts/basic.yaml")}"
  ]

}

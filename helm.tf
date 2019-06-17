resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
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
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  depends_on = [kubernetes_service_account.tiller]
}

# Initialize Helm (and install Tiller)
provider "helm" {
  install_tiller  = true
  service_account = "tiller"
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.12.3"

  #tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.1"
  namespace = "kube-system"

  kubernetes {
    host = azurerm_kubernetes_cluster.aksqse.kube_config[0].host
    client_certificate = base64decode(
      azurerm_kubernetes_cluster.aksqse.kube_config[0].client_certificate,
    )
    client_key = base64decode(azurerm_kubernetes_cluster.aksqse.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(
      azurerm_kubernetes_cluster.aksqse.kube_config[0].cluster_ca_certificate,
    )
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
  repository = data.helm_repository.qlik-edge.metadata[0].name
  chart      = "qliksense-init"
  #version    = "latest"

  # values = [
  #   "${file("./scripts/basic.yaml")}"
  # ]
}

resource "helm_release" "qseonk8s" {
  name       = "qseonk8s"
  repository = data.helm_repository.qlik-edge.metadata[0].name
  chart      = "qliksense"
  timeout    = 1200

  #version    = "latest"

  // values = [
  //   file("scripts/basic.yaml"),
  // ]

  // set_string {
  //   name  = "elastic-infra.nginx-ingress.controller.service.beta\\.kubernetes\\.io/azure-load-balancer-internal"
  //   value = "true"
  // }
  values = [
  <<-EOF
devMode:
 enabled: true

engine:
 acceptEULA: "yes"

global:
  persistence:
    storageClass: azurefile

identity-providers:
 secrets:
   idpConfigs:
     - discoveryUrl: "https://lkn.au.auth0.com/.well-known/openid-configuration"
       clientId: "aaaa"
       clientSecret: "bbb"
       realm: "Auth0"
       hostname: "lkn.elastic.example"
       #useClaimsFromIdToken: true   
       claimsMapping:
         client_id: [ "client_id", "azp" ]
         groups: ["/https:~1~1qlik.com~1roles", "/https:~1~1qlik.com~1groups"]
         sub: ["/https:~1~1qlik.com~1sub", "sub"]

elastic-infra:
  nginx-ingress:
    controller:
      service:
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-internal: "true"
  EOF
]

}


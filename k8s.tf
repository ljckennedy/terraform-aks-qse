provider "kubernetes" {
  host = azurerm_kubernetes_cluster.aksqse.kube_config[0].host
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.aksqse.kube_config[0].client_certificate,
  )
  client_key = base64decode(azurerm_kubernetes_cluster.aksqse.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.aksqse.kube_config[0].cluster_ca_certificate,
  )
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}

resource "kubernetes_cluster_role" "azure-cloud-provider" {
  metadata {
    name = "azure-cloud-provider"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "azure-cloud-provider" {
  metadata {
    name = "azure-cloud-provider"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:azure-cloud-provider"
  }

  # subject {
  #     kind = "User"
  #     name = "admin"
  #     api_group = "rbac.authorization.k8s.io"
  # }
  subject {
    kind      = "ServiceAccount"
    name      = "persistent-volume-binder"
    namespace = "kube-system"
  }
  # subject {
  #     kind = "Group"
  #     name = "system:masters"
  #     api_group = "rbac.authorization.k8s.io"
  # }
}

resource "kubernetes_service" "internal-lb" {
  metadata {
    name = "internal-lb"
    annotations = {
      "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
    }
  }
  spec {
    # selector {
    #   app = "${kubernetes_pod.example.metadata.0.labels.app}"
    # }
    session_affinity = "ClientIP"
    port {
      port        = 443
      target_port = 443
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_storage_class" "azurefile" {
  metadata {
    name = "azurefile"
  }
  storage_provisioner = "kubernetes.io/azure-file"
  reclaim_policy      = "Retain"
  parameters = {
    skuName = "Standard_LRS"
  }
}


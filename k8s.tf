
provider "kubernetes" {
    host                   = "${azurerm_kubernetes_cluster.aksqse.kube_config.0.host}"
    client_certificate     = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.client_certificate)}"
    client_key             = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.client_key)}"
    cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.aksqse.kube_config.0.cluster_ca_certificate)}"
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
        kind = "ClusterRole"
        name = "system:azure-cloud-provider"
    }
    # subject {
    #     kind = "User"
    #     name = "admin"
    #     api_group = "rbac.authorization.k8s.io"
    # }
    subject {
        kind = "ServiceAccount"
        name = "kube-system:persistent-volume-binder"
        namespace = "kube-system"
    }
    # subject {
    #     kind = "Group"
    #     name = "system:masters"
    #     api_group = "rbac.authorization.k8s.io"
    # }
}

# #azure file storage
# kubectl create clusterrole system:azure-cloud-provider --verb=get,create --resource=secrets
# kubectl create clusterrolebinding system:azure-cloud-provider --clusterrole=system:azure-cloud-provider --serviceaccount=kube-system:persistent-volume-binder
# kubectl apply -f ./scripts/azure-sc.yaml

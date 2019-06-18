# output "client_key" {
#     value = "${azurerm_kubernetes_cluster.aksqse.kube_config.0.client_key}"
# }

# output "client_certificate" {
#     value = "${azurerm_kubernetes_cluster.aksqse.kube_config.0.client_certificate}"
# }

# output "cluster_ca_certificate" {
#     value = "${azurerm_kubernetes_cluster.aksqse.kube_config.0.cluster_ca_certificate}"
# }
// output "kube_config" {
//   value = azurerm_kubernetes_cluster.aksqse.kube_config_raw
// }

output "cluster_username" {
  value = azurerm_kubernetes_cluster.aksqse.kube_config[0].username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.aksqse.kube_config[0].password
}

output "host" {
  value = azurerm_kubernetes_cluster.aksqse.kube_config[0].host
}

output "run_this" {

  value = "az aks get-credentials -n ${var.cluster_name} -g ${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name} --overwrite-existing"
}
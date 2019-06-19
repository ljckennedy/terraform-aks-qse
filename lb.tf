resource "azurerm_lb" "internal_lb" {
  name                = "internal_lb"
  location            = "${length(var.mylocation) > 1 ? var.mylocation : azurerm_resource_group.aks[0].location }"
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"

  frontend_ip_configuration {
    name                 = "internal_lb_subnet"
    subnet_id            = "${length(var.myrg) > 1 ? var.mysubnet : azurerm_subnet.subnet[0].id }"
    private_ip_address_allocation = "Dynamic"
    #zones                = 
  }
}

// data "azurerm_lb_backend_address_pool" "internal_lb_backend_pool" {
//   name            = "internal_lb_backend_pool"
//   resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
//   loadbalancer_id = azurerm_lb.internal_lb.id
// }
resource "azurerm_lb_backend_address_pool" "internal_lb_backend_pool" {
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  loadbalancer_id     = azurerm_lb.internal_lb.id
  name                = "internal_lb_backend_pool"
  #count               = "${var.vmName != "worker" ? 1 : 0}"
}


resource "azurerm_network_interface" "internal_lb_nic" {
  name                = "internal_lb_nic" #"${var.reference["name"]}-${var.vmName}-vm-${count.index}-nic"
  location            = "${length(var.mylocation) > 1 ? var.mylocation : azurerm_resource_group.aks[0].location }" #"${var.reference["location"]}"
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}" #"${var.reference["name"]}"
  #count               = "${var.reference["${var.vmName}Count"]}"

  depends_on = ["azurerm_lb.internal_lb"]

  ip_configuration {
    name                          = "internal_lb_ip"
    subnet_id                     = "${length(var.myrg) > 1 ? var.mysubnet : azurerm_subnet.subnet[0].id }"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "internal_lb_nic_association" {
  network_interface_id    = azurerm_network_interface.internal_lb_nic.id #"${element(azurerm_network_interface.nic.*.id, count.index)}"
  ip_configuration_name   = azurerm_network_interface.internal_lb_nic.ip_configuration[0].name
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.internal_lb_backend_pool.id}" #"${var.vmName != "worker" ? azurerm_lb_backend_address_pool.lb-backend.id : ""}"
  #count                   = "${var.vmName != "worker" ? var.reference["${var.vmName}Count"] : 0}"

  depends_on = ["azurerm_network_interface.internal_lb_nic"]
}

resource "azurerm_lb_probe" "internal_lb_probe" {
  resource_group_name = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  loadbalancer_id     = azurerm_lb.internal_lb.id
  name                = "internal_lb_probe"
  port                = 443
  #count               = "${var.vmName != "worker" ? length(var.ports) : 0}"
}

resource "azurerm_lb_nat_rule" "internal_lb_rule" {
  resource_group_name            = "${length(var.myrg) > 1 ? var.myrg : azurerm_resource_group.aks[0].name}"
  loadbalancer_id                = azurerm_lb.internal_lb.id
  name                           = "HTTPS"
  protocol                       = "tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = azurerm_lb.internal_lb.frontend_ip_configuration[0].name
}
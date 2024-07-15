terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-Terra"
  location = var.project_location
}

resource "azurerm_iothub" "iot_hub" {
  name                = "${var.project_name}Hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "B1"
    capacity = "1"
  }

  provisioner "local-exec" {
    command = templatefile("create_devices.tpl", {
      iothubName        = "${azurerm_iothub.iot_hub.name}",
      resourceGroupName = "${azurerm_resource_group.rg.name}"
    })
    interpreter = ["Powershell", "-Command"]
  }
}



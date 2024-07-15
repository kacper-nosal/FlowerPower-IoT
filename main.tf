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

resource "random_id" "unique_suffix" {
  keepers = {
    seed = var.seed
  }

  byte_length = 2
}

resource "azurerm_resource_group" "rg"{
    name = "${var.project_name}-${random_id.unique_suffix.hex}"
    location = "${var.project_location}"
}

resource "azurerm_iothub" "iot_hub" {
  name                         = "${var.project_name}Hub"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location

  sku {
    name     = "B1"
    capacity = "1"
  }
}

resource "null_resource" "iot_hub_device" {
  provisioner "local-exec" {
    command = <<EOT
      az iot hub device-identity create --hub-name ${azurerm_iothub.iot_hub.name} --device-id mydevice
    EOT
  }
  
  depends_on = [azurerm_iothub.iot_hub]
}
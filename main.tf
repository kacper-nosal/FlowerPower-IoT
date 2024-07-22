terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.113.0"
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
      iothubName        = azurerm_iothub.iot_hub.name,
      resourceGroupName = azurerm_resource_group.rg.name
    })
    interpreter = ["Powershell", "-Command"]
  }
  
}

resource "azurerm_stream_analytics_job" "asa_job" {
  name                                     = "${var.project_name}Stream"
  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-GB"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 1


  transformation_query = file("query.sql")
}

resource "azurerm_stream_analytics_stream_input_iothub" "asa_in_iothub" {
  name                         = azurerm_iothub.iot_hub.name
  stream_analytics_job_name    = azurerm_stream_analytics_job.asa_job.name
  resource_group_name          = azurerm_stream_analytics_job.asa_job.resource_group_name
  endpoint                     = "messages/events"
  eventhub_consumer_group_name = "$Default"
  iothub_namespace             = azurerm_iothub.iot_hub.name
  shared_access_policy_key     = azurerm_iothub.iot_hub.shared_access_policy[0].primary_key
  shared_access_policy_name    = "iothubowner"

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

resource "azurerm_mssql_server" "sql_server" {
  name                         = lower("${var.project_name}")
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "TheFlorist"
  administrator_login_password = "tDm@>`W01Q7"
  minimum_tls_version          = "1.2"
}

resource "azurerm_mssql_firewall_rule" "firewall_rule_pass_all" {
  name             = "FirewallRulePassAll"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.1"
  end_ip_address   = "255.255.255.254"
}

resource "azurerm_mssql_firewall_rule" "firewall_rule_azure_exception" {
  name             = "FirewallRuleAzureException"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_database" "database" {
  name           = "${var.project_name}Base"
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  # license_type   = "LicenseIncluded"
  max_size_gb    = 250
  read_scale     = false
  sku_name       = "S0"
  zone_redundant = false

  provisioner "local-exec" {
    command = templatefile("create_tables.tpl", {
      serverName = azurerm_mssql_server.sql_server.name,
      databaseName = self.name,
      adminUserName = azurerm_mssql_server.sql_server.administrator_login,
      adminPassword = azurerm_mssql_server.sql_server.administrator_login_password
    })
    interpreter = ["Powershell", "-Command"]
  }
}

#in case of rerunning run .\SQL_config.ps1 -adminUserName TheFlorist -adminPassword 'tDm@>`W01Q7' -databaseName FlowerPowerBase -serverName flowerpower
#before creating later resources

resource "azurerm_stream_analytics_output_mssql" "asa_out_numeric_rt" {
  name                      = "NumericRealTimeData"
  stream_analytics_job_name = azurerm_stream_analytics_job.asa_job.name
  resource_group_name       = azurerm_stream_analytics_job.asa_job.resource_group_name

  server   = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  user     = azurerm_mssql_server.sql_server.administrator_login
  password = azurerm_mssql_server.sql_server.administrator_login_password
  database = azurerm_mssql_database.database.name
  table    = "[dbo].[NumericRealTimeData]"
}

# resource "azurerm_stream_analytics_output_mssql" "sim_data" {
#   name                      = "FlowerData"
#   stream_analytics_job_name = data.azurerm_stream_analytics_job.example.name
#   resource_group_name       = data.azurerm_stream_analytics_job.example.resource_group_name

#   server   = azurerm_sql_server.example.fully_qualified_domain_name
#   user     = azurerm_sql_server.example.administrator_login
#   password = azurerm_sql_server.example.administrator_login_password
#   database = azurerm_sql_database.example.name
#   table    = "ExampleTable"
# }

resource "azurerm_stream_analytics_output_mssql" "asa_out_binary_rt" {
  name                      = "BooleanRealTimeData"
  stream_analytics_job_name = azurerm_stream_analytics_job.asa_job.name
  resource_group_name       = azurerm_stream_analytics_job.asa_job.resource_group_name

  server   = azurerm_mssql_server.sql_server.fully_qualified_domain_name
  user     = azurerm_mssql_server.sql_server.administrator_login
  password = azurerm_mssql_server.sql_server.administrator_login_password
  database = azurerm_mssql_database.database.name
  table    = "[dbo].[BooleanRealTimeData]"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "${var.project_name}Plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "B1"
}



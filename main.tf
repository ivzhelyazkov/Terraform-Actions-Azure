# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Generate a random integer 
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create a resource group
resource "azurerm_resource_group" "taskboard_rg" {
  name     = "${var.resource_group_name}${random_integer.ri.result}"
  location = var.resource_group_location
}

# Create App Service Plan
resource "azurerm_service_plan" "taskboard_sp" {
  name                = "${var.app_service_plan_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboard_rg.name
  location            = azurerm_resource_group.taskboard_rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# Create a server resource
resource "azurerm_mssql_server" "taskboard_server" {
  name                         = "${var.sql_server_name}${random_integer.ri.result}"
  resource_group_name          = azurerm_resource_group.taskboard_rg.name
  location                     = azurerm_resource_group.taskboard_rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

# Create a firewall rule for the server
resource "azurerm_mssql_firewall_rule" "taskboard_firewall" {
  name             = "${var.firewall_rule_name}${random_integer.ri.result}"
  server_id        = azurerm_mssql_server.taskboard_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Create a database
resource "azurerm_mssql_database" "taskboard_db" {
  name           = "${var.sql_database_name}${random_integer.ri.result}"
  server_id      = azurerm_mssql_server.taskboard_server.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  sku_name       = "S0"
  zone_redundant = false
}


# Create Azure Linux Web app
resource "azurerm_linux_web_app" "taskboard_webapp" {
  name                = "${var.app_service_name}${random_integer.ri.result}"
  resource_group_name = azurerm_resource_group.taskboard_rg.name
  location            = azurerm_service_plan.taskboard_sp.location
  service_plan_id     = azurerm_service_plan.taskboard_sp.id

  site_config {
    application_stack {
      dotnet_version = "6.0"
    }
    always_on = false
  }

  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "Data Source=tcp:${azurerm_mssql_server.taskboard_server.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.taskboard_db.name};User ID=${azurerm_mssql_server.taskboard_server.administrator_login};Password=${azurerm_mssql_server.taskboard_server.administrator_login_password};Trusted_Connection=False; MultipleActiveResultSets=True;"
  }
}

# Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "taskboard_repo" {
  app_id                 = azurerm_linux_web_app.taskboard_webapp.id
  repo_url               = var.repo_URL
  branch                 = "main"
  use_manual_integration = true
}
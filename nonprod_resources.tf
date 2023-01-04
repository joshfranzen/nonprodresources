

provider "azurerm" {
  version         = "=2.26.0"
  subscription_id = "<your subscription id>"
  tenant_id       = "<your tenant id>"
}

resource "azurerm_resource_group" "nonprod" {
  name     = "dnl-nonprod-rg"
  location = "westus2"
}

resource "azurerm_app_service_plan" "nonprod" {
  name                = "dnl-nonprod-plan"
  location            = azurerm_resource_group.nonprod.location
  resource_group_name = azurerm_resource_group.nonprod.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "nonprod" {
  name                = "dnl-nonprod-web"
  location            = azurerm_resource_group.nonprod.location
  resource_group_name = azurerm_resource_group.nonprod.name
  app_service_plan_id = azurerm_app_service_plan.nonprod.id
}

resource "azurerm_app_service_scale_set" "nonprod" {
  name                = "dnl-nonprod-scalableset"
  location            = azurerm_resource_group.nonprod.location
  resource_group_name = azurerm_resource_group.nonprod.name
  sku {
    tier = "Standard"
    size = "S1"
  }
  autoscale {
    min_count = 2
    max_count = 10
  }
}

resource "azurerm_app_service_custom_hostname_binding" "nonprod" {
  app_service_name    = azurerm_app_service.nonprod.name
  resource_group_name = azurerm_resource_group.nonprod.name
  domain_name         = "<your domain name>"
}

resource "azurerm_sql_server" "nonprod" {
  name                         = "dnl-nonprod-sql"
  resource_group_name          = azurerm_resource_group.nonprod.name
  location                     = azurerm_resource_group.nonprod.location
  version                      = "12.0"
  administrator_login          = "<your administrator login>"
  administrator_login_password = "<your administrator login password>"
}

resource "azurerm_sql_database" "nonprod" {
  name                = "dnl-nonprod-db"
  resource_group_name = azurerm_resource_group.nonprod.name
  location            = azurerm_resource_group.nonprod.location
  server_name         = azurerm_sql_server.nonprod.name
  edition             = "Standard"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  max_size_bytes      = "1073741824"
}
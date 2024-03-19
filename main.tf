provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "fsher" {
  name     = "fsh-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "fshervnet" {
  name                = "fsher-vnet"
  location            = azurerm_resource_group.fsher.location
  resource_group_name = azurerm_resource_group.fsher.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "fshersubnet" {
  name                 = "fsher-sub"
  resource_group_name  = azurerm_resource_group.fsher.name
  virtual_network_name = azurerm_virtual_network.fshervnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
resource "azurerm_private_dns_zone" "fsherdnsz" {
  name                = "fsher.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.fsher.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "fsherdnslnk" {
  name                  = "fsherVnetZone.com"
  private_dns_zone_name = azurerm_private_dns_zone.fsherdnsz.name
  virtual_network_id    = azurerm_virtual_network.fshervnet.id
  resource_group_name   = azurerm_resource_group.fsher.name
  depends_on            = [azurerm_subnet.fshersubnet]
}

resource "azurerm_postgresql_flexible_server" "exfsherflxs" {
  name                   = "fsher-psqlflexibleserver"
  resource_group_name    = azurerm_resource_group.fsher.name
  location               = azurerm_resource_group.fsher.location
  version                = "12"
  delegated_subnet_id    = azurerm_subnet.fshersubnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.fsherdnsz.id
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb   = 32768
  storage_tier = "P30"

  sku_name   = "GP_Standard_D4s_v3"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.fsherdnslnk]

}
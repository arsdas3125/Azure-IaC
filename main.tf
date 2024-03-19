provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {
  }
}

resource "azurerm_resource_group" "ecsproqanam" {
  name     = "${var.name}-rg"
  location = var.location

}

resource "azurerm_virtual_network" "ecsproqavnet" {
  name                = var.vnet
  location            = azurerm_resource_group.ecsproqanam.location
  resource_group_name = azurerm_resource_group.ecsproqanam.name
  address_space       = ["10.155.247.96/28"]
}

resource "azurerm_network_security_group" "ecsproqanetg" {
  name                = "${var.name}-nsg"
  location            = azurerm_resource_group.ecsproqanam.location
  resource_group_name = azurerm_resource_group.ecsproqanam.name

  security_rule {
    name                       = "${var.name}-sec"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "ecsproqasubn" {
  name                 = var.subnet
  virtual_network_name = azurerm_virtual_network.ecsproqavnet.name
  resource_group_name  = azurerm_resource_group.ecsproqanam.name
  address_prefixes     = ["10.155.247.96/28"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "affs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "ecsproqasecg" {
  subnet_id                 = azurerm_subnet.ecsproqasubn.id
  network_security_group_id = azurerm_network_security_group.ecsproqanetg.id
}

resource "azurerm_private_dns_zone" "ecsproqapdz" {
  name                = "${var.name}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.ecsproqanam.name

  depends_on = [azurerm_subnet_network_security_group_association.ecsproqasecg]

}

resource "azurerm_private_dns_zone_virtual_network_link" "ecsproqavnetl" {
  name                  = "${var.name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.ecsproqapdz.name
  virtual_network_id    = azurerm_virtual_network.ecsproqavnet.id
  resource_group_name   = azurerm_resource_group.ecsproqanam.name
}

resource "azurerm_postgresql_flexible_server" "ecsproqasrvsqlflx" {
  name                   = var.server
  resource_group_name    = azurerm_resource_group.ecsproqanam.name
  location               = azurerm_resource_group.ecsproqanam.location
  version                = "11"
  delegated_subnet_id    = azurerm_subnet.ecsproqasubn.id
  private_dns_zone_id    = azurerm_private_dns_zone.ecsproqapdz.id
  administrator_login    = var.db_username
  administrator_password = var.db_password
  zone                   = "3"
  storage_mb             = 131072
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.ecsproqavnetl]

}

resource "azurerm_postgresql_flexible_server_database" "ecsproqadbsqlflx" {
  name      = "${var.dbname}-01"
  server_id = azurerm_postgresql_flexible_server.ecsproqasrvsqlflx.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

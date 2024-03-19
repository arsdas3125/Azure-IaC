provider "azurerm" {
  # subscription_id = "var.subscription_id"
  # client_id       = "var.client_id"
  # client_secret   = "var.client_secret"
  # tenant_id       = "var.tenant_id"
  features {
  }

}

resource "azurerm_resource_group" "fshrnam" {
  name     = "${var.name}-rg"
  location = var.location

}

resource "azurerm_virtual_network" "fshrvnet" {
  name                = "${var.name}-vnet"
  location            = azurerm_resource_group.fshrnam.location
  resource_group_name = azurerm_resource_group.fshrnam.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_network_security_group" "fshrnetg" {
  name                = "${var.name}-nsg"
  location            = azurerm_resource_group.fshrnam.location
  resource_group_name = azurerm_resource_group.fshrnam.name

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

resource "azurerm_subnet" "fshrsubn" {
  name                 = "${var.name}-subnet"
  virtual_network_name = azurerm_virtual_network.fshrvnet.name
  resource_group_name  = azurerm_resource_group.fshrnam.name
  address_prefixes     = ["10.1.1.0/24"]
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

resource "azurerm_subnet_network_security_group_association" "fshrsecg" {
  subnet_id                 = azurerm_subnet.fshrsubn.id
  network_security_group_id = azurerm_network_security_group.fshrnetg.id
}

resource "azurerm_private_dns_zone" "fshrpdz" {
  name                = "${var.name}-pdz.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.fshrnam.name

  depends_on = [azurerm_subnet_network_security_group_association.fshrsecg]

}

resource "azurerm_private_dns_zone_virtual_network_link" "fshrdzvnetl" {
  name                  = "${var.name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.fshrpdz.name
  virtual_network_id    = azurerm_virtual_network.fshrvnet.id
  resource_group_name   = azurerm_resource_group.fshrnam.name
}

resource "azurerm_postgresql_flexible_server" "fshrpostsqlflx" {
  name                   = var.server
  resource_group_name    = azurerm_resource_group.fshrnam.name
  location               = azurerm_resource_group.fshrnam.location
  version                = "11"
  delegated_subnet_id    = azurerm_subnet.fshrsubn.id
  private_dns_zone_id    = azurerm_private_dns_zone.fshrpdz.id
  administrator_login    = var.db_username
  administrator_password = var.db_password
  zone                   = "3"
  storage_mb             = 131072
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.fshrdzvnetl]

}

resource "azurerm_postgresql_flexible_server_database" "fshrpostsqlflx" {
  name      = "${var.dbname}-01"
  server_id = azurerm_postgresql_flexible_server.fshrpostsqlflx.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

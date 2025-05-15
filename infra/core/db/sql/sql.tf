# Servidor SQL parametrizado
resource "azurerm_sql_server" "sql" {
  name                         = var.sql_server_name         # p.ej. "${var.prefix}-sql-srv"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.db_admin_user
  administrator_login_password = var.db_admin_password

  tags = var.tags   # etiquetas aplicadas desde variables
}

# Base de datos SQL parametrizada
resource "azurerm_sql_database" "sqldb" {
  name                = var.sql_db_name      # p.ej. "sqldb"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  server_name         = azurerm_sql_server.sql.name
  sku_name            = var.sql_sku         # p.ej. "S0" o "GP_Gen5_2"
  collation           = var.db_collation    # p.ej. "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant      = var.enable_zones    # boolean para Alta Disponibilidad Zonal
  max_size_gb         = var.db_max_size
  tags                = var.tags
}

# Private Endpoint para SQL Server
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.prefix}-sql-pe"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  subnet_id           = var.subnet_id       # debe ser un subnet privado dentro de una VNet
  
  private_service_connection {
    name                           = "sql-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.sql.id
    subresource_names              = ["sqlServer"]
  }
}

# Zona DNS Privada para el endpoint SQL
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  name                  = "sql-vnet-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = var.vnet_id
}

# Registro DNS para SQL: apunta el nombre del servidor al IP del PE
resource "azurerm_private_dns_a_record" "sql_record" {
  name                = azurerm_sql_server.sql.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address]
}

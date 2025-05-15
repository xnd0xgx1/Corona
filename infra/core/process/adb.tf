# Workspace de Databricks en VNet propia
resource "azurerm_databricks_workspace" "ws" {
  name                       = var.databricks_name   # p.ej. "${var.prefix}dbw"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  sku                        = "premium"
  managed_resource_group_name = "${azurerm_resource_group.main.name}-mng-rg"
  tags                       = var.tags

  custom_parameters {
    virtual_network_id  = azurerm_virtual_network.main.id
    public_subnet_name  = var.public_subnet_name
    private_subnet_name = var.private_subnet_name
  }
}

# Configuración del proveedor de Databricks usando el workspace creado
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.ws.id
}

# Cluster de Databricks (ejemplo sencillo)
resource "databricks_cluster" "example" {
  cluster_name            = "${var.prefix}-cluster"
  spark_version           = var.spark_version  # p.ej. "12.2.x-scala2.12"
  node_type_id            = var.node_type      # p.ej. "Standard_DS3_v2"
  autotermination_minutes = var.auto_termination
  num_workers             = var.num_workers
  depends_on = [azurerm_databricks_workspace.ws]
}

# Metastore y catálogo de Unity Catalog
resource "databricks_metastore" "uc" {
  name         = var.databricks_metastore_name
  storage_root = var.metastore_storage_root  # p.ej. URL de contenedor gen2 para UC
}

resource "databricks_catalog" "cat_lakehouse" {
  name         = "lakehouse" 
  metastore_id = databricks_metastore.uc.id
}

resource "databricks_schema" "landing" {
  name         = "landing"
  catalog_name = databricks_catalog.cat_lakehouse.name
}

# Ubicación externa (Unity Catalog): vincula un contenedor ADLS con Databricks
resource "databricks_storage_credential" "landing" {
  name                 = "landing-storage-cred"
  azure_managed_identity = azurerm_user_assigned_identity.databricks.id
}

resource "databricks_external_location" "landing_ext" {
  name            = "landing-zone"
  url             = "abfss://${azurerm_storage_container.landing.name}@${azurerm_storage_account.landing.name}.dfs.core.windows.net/"
  credentials_name = databricks_storage_credential.landing.name
}

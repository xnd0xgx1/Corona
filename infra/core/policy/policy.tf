# Política incorporada: resringe ubicaciones permitidas (Allowed Locations).
# Usamos policy_type="BuiltIn" referenciando el ID de la directiva de Azure.
resource "azurerm_policy_definition" "allowed_locations" {
  mode = "Indexed"
  name         = "allowed-locations"
  policy_type  = "BuiltIn"
  display_name = "Allowed Locations (customized)"
  # Categoría y regla integrada para denegar ubicaciones no permitidas
  metadata = <<METADATA
{ "category": "Allowed Location" }
METADATA
  parameters = <<PARAMS
{
  "listOfAllowedLocations": {
    "type": "Array"
  }
}
PARAMS
  policy_rule = <<POLICY
{
  "if": {
    "not": {
      "field": "location",
      "in": "[parameters('listOfAllowedLocations')]"
    }
  },
  "then": {
    "effect": "deny"
  }
}
POLICY
}

# Asignación de la política de ubicaciones: el arreglo de regiones viene de variable
resource "azurerm_policy_assignment" "assign_allowed_locations" {
  name                 = "restrict-locations"
  scope                = var.scope_subscription_id
  policy_definition_id = azurerm_policy_definition.allowed_locations.id

  parameters = <<PARAMS
{
  "listOfAllowedLocations": {
    "value": var.allowed_locations
  }
}
PARAMS
}


# Definición de política personalizada: exige etiqueta obligatoria (efecto Deny).
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Require specified tag"
  description  = "Denies resources missing the required tag."
  # Parámetro dinámico para el nombre de etiqueta requerido
  parameters = <<PARAMS
        {
        "tagName": { "type": "String" }
        }
        PARAMS
        policy_rule = <<POLICY
        {
        "if": {
            "field": "[concat('tags[', parameters('tagName'), ']')]",
            "equals": ""
        },
        "then": {
            "effect": "deny"
        }
}
POLICY
}

# Asignación de la política: se pasa el valor real del parámetro (p.ej. "CostCenter").
resource "azurerm_policy_assignment" "assign_require_tags" {
  name                 = "enforce-required-tag"
  scope                = var.scope_rg_id   # puede ser un ID de suscripción o grupo de recursos
  policy_definition_id = azurerm_policy_definition.require_tags.id

  parameters = <<PARAMS
{
  "tagName": { "value": var.required_tag_name }
}
PARAMS
}

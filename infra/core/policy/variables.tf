variable "scope_subscription_id" {
  type = string
}

variable "scope_rg_id" {
  type = string
  default = ""
}
variable "required_tag_name" {
  type = string
  default = ""
}

variable "allowed_locations" {
  type = list(string)
}
variable "tags" {
  type = map(string)
  default = {}
}






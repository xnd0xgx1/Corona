variable "prefix" {
  type = string
}

variable "subnet_id" {
  type = string
  default = ""
}
variable "resource_group_id" {
  type = string
  default = ""
}

variable "db_admin_user" {
  type = string
  default = ""
}


variable "db_admin_password" {
  type = string
  default = ""
}




variable "sql_sku" {
  type = string
  default = ""
}




variable "db_collation" {
  type = string
  default = ""
}

variable "db_max_size" {
  type = string
  default = ""
}


variable "enable_zones" {
  type = string
  default = ""
}


variable "vnet_id" {
  type = string
  default = ""
}

variable "location" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {}
}




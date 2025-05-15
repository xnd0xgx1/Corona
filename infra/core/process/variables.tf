variable "databricks_name" {
  type = string
}

variable "public_subnet_name" {
  type = string
}


variable "location" {
  type = string
}

variable "private_subnet_name" {
  type = string
}




variable "tags" {
  type = map(string)
  default = {}
}

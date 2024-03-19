variable "subscription_id" {
  default = "cec4c50d-7921-4b36-9109-5df4528d69d8"

}

variable "client_id" {
  default = "add-client-id-information"
}

variable "client_secret" {
  default = "add-client-id-secret"

}

variable "tenant_id" {
  default = "39737165-b637-451f-8b66-a06e0ac765f2"
}

variable "name" {
  default     = "ecsproqa"
  description = "Prefix of the resource group name."
}

variable "location" {
  default     = "East US 2"
  description = "Location of the resource"
}

variable "server" {
  default     = "ecsproqasqldb"
  description = "PostGreSql Server Name"
}

variable "dbname" {
  default     = "ecsproqadb"
  description = "PostGreSql Database Instance Name"
}

variable "db_username" {
  default     = "psqladminqa"
  description = "PSQL DB Admin Username"
}

variable "db_password" {
  description = "PSQL DB Password"
  default     = "P@SQLadmqa01"

}
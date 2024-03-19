variable "subscription_id" {
  default     = "28e57e80-eb37-4a22-8b9d-c136a2904a9c"
  description = "Add the subscription ID "
}

variable "client_id" {
  default     = "211f6630-aa7c-4c5f-b358-e8c0286f9e1b"
  description = "Add client ID information"
}

variable "client_secret" {
  default     = "add--secret---here---"
  description = "Add-client-id-secret"
}

variable "tenant_id" {
  default     = "cdf226d7-79fd-4290-a3a7-996968201a26"
  description = "Add client id secret "
}

variable "name" {
  default     = "ecsproqa"
  description = "Prefix of the resource group name."
}

variable "location" {
  default     = "East US 2"
  description = "Location of the resource"
}

variable "vnet" {
  default     = "non-prod-vnet-ecspro-qa-eastus2-4a9c"
  description = "Name of the vnet in  QA"
}
variable "subnet" {
  default     = "eastus2-postgresdb"
  description = "Name of the subnet in  QA"
}

variable "server" {
  default     = "ecsproqasqlsrv01"
  description = "PostGreSql Server Name"
}

variable "dbname" {
  default     = "ecsproqadb01"
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

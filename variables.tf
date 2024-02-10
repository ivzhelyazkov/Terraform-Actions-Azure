# Resource group vars
variable "resource_group_name" {
  type        = string
  description = "Resource group in Azure"
}

variable "resource_group_location" {
  type        = string
  description = "Location of Azure resource group"
}

# Service plan vars
variable "app_service_plan_name" {
  type        = string
  description = "Azure app service plan"
}

# SQL server vars
variable "sql_server_name" {
  type        = string
  description = "Azure sql server"
}

variable "sql_admin_login" {
  type        = string
  description = "Azure sql admin username"
}

variable "sql_admin_password" {
  type        = string
  description = "Azure sql admin password"
}

variable "firewall_rule_name" {
  type        = string
  description = "Azure firewall rule"
}

# SQL database vars
variable "sql_database_name" {
  type        = string
  description = "Azure sql database"
}

# Web app sevice vars
variable "app_service_name" {
  type        = string
  description = "Azure app service"
}

# Repo vars
variable "repo_URL" {
  type        = string
  description = "Repo URL for Azure web app"
}

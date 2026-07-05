#================= GLOBAL VARIABLES ====================#

variable "region" {
  type        = string
  description = "AWS Region"
}

variable "target_arn" {
  type        = string
  description = "Arn role where application will be deployed"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment"
}



############# ECR ##############


variable "link_store_ecr" {
  type        = string
  description = "ECR name for link store app"
}


###### DB Secret manager #######
#Values are being populated manually
variable "linkstore_db_values" {
  type = map(string)
  default = {
    POSTGRES_USER     = ""
    POSTGRES_PASSWORD = ""
  }
}


############# RDS ###############

variable "db_name" {
  type        = string
  description = "Initial PostgreSQL database name"
}

variable "db_username" {
  type        = string
  description = "Master database username"
}

variable "postgres_engine_version" {
  type        = string
  description = "PostgreSQL engine version"
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage in GB"
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage autoscaling in GB"
}
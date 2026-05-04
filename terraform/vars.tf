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
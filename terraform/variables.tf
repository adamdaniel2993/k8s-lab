###### Global vars #####
variable "region" {
  type        = string
  description = "AWS region, where resources are going to live"
}

variable "target_account" {
  type        = string
  description = "Account where resources are going to be created"
}

variable "node_group_desire_size" {
  type = number
}

variable "cluster_name" {
  type = string
  description = "Name for eks cluster"
}
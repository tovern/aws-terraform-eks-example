variable "name" {
  type    = string
}

variable "product" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

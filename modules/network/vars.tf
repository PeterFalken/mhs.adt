## Variables definitions
variable "environment" {
  type = string
}

variable "regions" {
  type = list(string)
}

variable "subnet_cidr" {
  type = string
}

variable "cloud_function" {
}

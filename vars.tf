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

variable "yourname" {
  type    = string
  default = "LuisGarcia"
}

resource "random_string" "rand4char" {
  length  = 4
  special = false

  lifecycle {
    ignore_changes = [
      length,
      lower,
    ]
  }
}

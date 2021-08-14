variable "region" {
  description = "AWS"
  type        = string
  default     = "us-east-1"
}

variable "external_port" {
  type    = number
  default = 8080
  validation {
    condition     = can(regex("8080|80", var.external_port))
    error_message = "Port values error."
  }
}


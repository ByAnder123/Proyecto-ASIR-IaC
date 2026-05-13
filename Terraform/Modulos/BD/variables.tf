variable "vpc_id" {
    description = "ID de la VPC principal"
    type = string
}

variable "subred_bd_id" {
    description = "ID de la subred privada de BD"
    type = string
}

variable "clave_ssh" {
    description = "Nombre de la clave SSH para acceder"
    type = string
}

variable "rango_vpc" {
    description = "Rango de la VPC para permitir el tráfico interno"
    type = string
}

variable "ip_privada_bd" {
    description = "IP fija interna para la Base de Datos"
    type = string
    default = "192.168.3.20"
}
variable "rango_subred_web" {
    description = "El rango para la subred privada de servidores Web"
    type = string
}

variable "rango_subred_bd" {
    description = "El rango para la subred privada de la Base de Datos"
    type = string
}

variable "vpc_id" {
    description = "El ID de la VPC (viene del módulo de red)"
    type = string
}

variable "subred_publica_id" {
    description = "El ID de la subred DMZ pública (viene del módulo de red)"
    type = string
}

variable "subred_web_id" {
    description = "El ID de la subred privada Web (viene del módulo de red)"
    type = string
}

variable "subred_bd_id" {
    description = "El ID de la subred privada BD (viene del módulo de red)"
    type = string
}

variable "clave_ssh" {
    description = "El nombre exacto de la clave SSH creada en la consola de AWS"
    type = string
}
variable "rango_vpc" {
    description = "El rango para la VPC principal"
    type = string
}

variable "rango_subred_publica" {
    description = "El rango para la subred DMZ pública"
    type = string
}

variable "rango_subred_web" {
    description = "El rango para la subred privada de servidores Web"
    type = string
}

variable "rango_subred_bd" {
    description = "El rango para la subred privada de la Base de Datos"
    type = string
}

variable "zona_disponibilidad" {
    description = "La Zona de Disponibilidad de AWS donde se crearán las subredes"
    type = string
}
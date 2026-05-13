variable "aws_access_key" {
    description = "AWS Access Key"
    type = string
    sensitive = true
}

variable "aws_secret_key" {
    description = "AWS Secret Key"
    type = string
    sensitive = true
}

variable "clave_ssh" {
    description = "Nombre del archivo de la clave ssh"
    type = string
    default = "clave_ssh"
}

variable "rango_vpc" {
    description = "IP red vpc"
    type = string
    default = "192.168.0.0/16"
}

variable "rango_subred_publica" {
    description = "IP subred DMZ"
    type = string
    default = "192.168.1.0/24"
}

variable "rango_subred_web" {
    description = "IP subred web"
    type = string
    default = "192.168.2.0/24"
}

variable "rango_subred_bd" {
    description = "IP subred DB"
    type = string
    default = "192.168.3.0/24"
}

variable "zona_disponibilidad" {
    description = "Región"
    type = string
    default = "eu-west-2a"
}

variable "zona_disponibilidad_alb" {
    description = "Región"
    type = string
    default = "eu-west-2b"
}
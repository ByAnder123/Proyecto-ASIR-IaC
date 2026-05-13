variable "vpc_id" {
    description = "ID de la VPC principal"
    type = string
}

variable "subred_web_id" {
    description = "ID de la subred privada Web (Donde nacerán las máquinas)"
    type = string
}

variable "subred_alb_respaldo_id" {
    description = "Subred secundaria para cumplir el requisito del ALB"
    type = string
}

variable "clave_ssh" {
    description = "Clave para entrar a las máquinas clonadas"
    type = string
}

variable "rango_vpc" {
    description = "Rango de la red para permitir tráfico interno"
    type = string
}
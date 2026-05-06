terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.41" # Versión mínima del proveedor
        }
    }
    required_version = "~> 1.14" # Versión mínima instalada de Terraform
}

# Configuración del proveedor AWS
provider "aws" {
    region = "eu-west-2" # Región de Lóndres
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
}

module "red" {
    source = "./Modulos/Red"

    # Valores reales de las variables del módulo
    rango_vpc = "192.168.0.0/16"
    rango_subred_publica = "192.168.1.0/24"
    rango_subred_web = "192.168.2.0/24"
    rango_subred_bd = "192.168.3.0/24"
    zona_disponibilidad = "eu-west-2a"
}

module "firewall" {
    source = "./Modulos/Firewall"
    rango_subred_web = "192.168.2.0/24"
    rango_subred_bd  = "192.168.3.0/24"
    
    # Pasamos el nombre de la clave SSH
    clave_ssh = "clave_ssh"
    
    # Pasamos los IDs que saca los outputs del módulo red
    vpc_id            = module.red.vpc_id
    subred_publica_id = module.red.subred_publica_id
    subred_web_id     = module.red.subred_web_id
    subred_bd_id      = module.red.subred_bd_id
}
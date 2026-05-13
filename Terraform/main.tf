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

#=========#
# MODULOS #
#=========#

module "red" {
    source = "./Modulos/Red"

    # Variables globales
    rango_vpc = var.rango_vpc
    rango_subred_publica = var.rango_subred_publica
    rango_subred_web = var.rango_subred_web
    rango_subred_bd = var.rango_subred_bd
    zona_disponibilidad = var.zona_disponibilidad
}

module "firewall" {
    source = "./Modulos/Firewall"

    depends_on = [module.red]
    
    # Variables globales
    clave_ssh = var.clave_ssh
    rango_subred_web = var.rango_subred_web
    rango_subred_bd = var.rango_subred_bd
    
    # Outputs inyectados desde el Módulo de Red
    vpc_id = module.red.vpc_id
    subred_publica_id = module.red.subred_publica_id
    subred_web_id = module.red.subred_web_id
    subred_bd_id = module.red.subred_bd_id
}

module "BD" {
    source = "./Modulos/BD"

    depends_on = [module.red]

    # Variables globales
    clave_ssh = var.clave_ssh
    rango_vpc = var.rango_vpc

    # Outputs inyectados desde el Módulo de Red
    vpc_id = module.red.vpc_id
    subred_bd_id = module.red.subred_bd_id
}

module "web" {
    source = "./Modulos/Web"

    depends_on = [module.red]

    # Variables globales
    clave_ssh = var.clave_ssh
    rango_vpc = var.rango_vpc

    # Outputs inyectados desde el Módulo de Red
    vpc_id = module.red.vpc_id
    subred_web_id = module.red.subred_web_id
    subred_alb_respaldo_id = module.red.subred_alb_respaldo_id
}

#=======================================#
# AUTOGENERACIÓN DEL INVENTARIO ANSIBLE #
#=======================================#
resource "local_file" "inventario_ansible" {
    filename = "${path.module}/inventario.ini"
    content = <<-EOT
[firewall]
${module.firewall.ip_publica_firewall} ansible_user=ubuntu ansible_ssh_private_key_file=~/clave_ssh.pem dns_alb=${module.web.dns_alb}

[BD]
192.168.3.20 ansible_user=ubuntu ansible_ssh_private_key_file=~/clave_ssh.pem

[BD:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -o StrictHostKeyChecking=no -q ubuntu@${module.firewall.ip_publica_firewall} -i ~/clave_ssh.pem"'
EOT
}

#=================================#
# EJECUCIÓN AUTOMÁTICA DE ANSIBLE #
#=================================#
resource "null_resource" "ejecutar_ansible" {
    # Siempre que la IP cambia, se vuelve a ejecutar Ansible
    triggers = {
        siempre_ejecutar = module.firewall.ip_publica_firewall
    }

    # Esto asegura que Terraform primero cree el inventario y las máquinas antes de ejecutar Ansible
    depends_on = [
        local_file.inventario_ansible,
        module.firewall,
        module.BD
    ]

    provisioner "local-exec" {
        # ANSIBLE_HOST_KEY_CHECKING=False evita que se quede esperando a que el usuario escriba 'yes'
        command = "chmod 644 inventario.ini && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventario.ini ../Ansible/playbook_principal.yml"
    }
}
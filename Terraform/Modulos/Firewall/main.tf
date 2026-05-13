#==========================#
# TARJETAS DE RED FIREWALL #
#==========================#
resource "aws_network_interface" "firewall_web" {
    subnet_id = var.subred_web_id
    private_ips = ["192.168.2.10"]
    source_dest_check = false
    security_groups = [aws_security_group.sg_firewall.id]
    tags = {
        Name = "Red-Firewall-Web"
    }
}

resource "aws_network_interface" "firewall_bd" {
    subnet_id = var.subred_bd_id
    private_ips = ["192.168.3.10"]
    source_dest_check = false
    security_groups = [aws_security_group.sg_firewall.id]
    tags = {
        Name = "Red-Firewall-BD"
    }
}

#======================================#
# CONEXIÓN DE LAS TARJETAS SECUNDARIAS #
#======================================#
# Enchufamos la tarjeta de la LAN Web (eth1)
resource "aws_network_interface_attachment" "attach_web" {
    instance_id = aws_instance.servidor_firewall.id
    network_interface_id = aws_network_interface.firewall_web.id
    device_index = 1
}

# Enchufamos la tarjeta de la LAN BD (eth2)
resource "aws_network_interface_attachment" "attach_bd" {
    instance_id = aws_instance.servidor_firewall.id
    network_interface_id = aws_network_interface.firewall_bd.id
    device_index = 2
}

#=================#
# IP PÚBLICA FIJA #
#=================#
resource "aws_eip" "ip_fija_firewall" {
    domain = "vpc"
    network_interface = aws_instance.servidor_firewall.primary_network_interface_id
    tags = {
        Name = "EIP-Firewall"
    }
}

#====================#
# GRUPO DE SEGURIDAD #
#====================#
resource "aws_security_group" "sg_firewall" {
    name = "SG-Firewall"
    description = "Permite todo el trafico para delegar el control a iptables"
    vpc_id = var.vpc_id

    # Entrada: Permitimos todo
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1" 
        cidr_blocks = ["0.0.0.0/0"] 
    }

    # Salida: Permitimos todo
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG-Firewall"
    }
}

#============================#
# MÁQUINA VIRTUAL - FIREWALL #
#============================#
resource "aws_instance" "servidor_firewall" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.small"
    key_name = var.clave_ssh

    # 1. Tarjeta principal (eth0) integrada en la máquina
    subnet_id = var.subred_publica_id
    private_ip = var.ip_privada_fw
    source_dest_check = false # Permite enrutamiento
    vpc_security_group_ids = [aws_security_group.sg_firewall.id] # Enlazamos el firewall nativo

    tags = {
        Name = "VM-Firewall"
    }
}

#=========================#
# IMAGEN UBUNTU 22.04 LTS #
#=========================#
data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

#========================#
# TABLAS DE ENRUTAMIENTO #
#========================#
# Tabla de la Subred Web
resource "aws_route_table" "rt_web" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        network_interface_id = aws_instance.servidor_firewall.primary_network_interface_id
    }

    route {
        cidr_block = var.rango_subred_bd
        network_interface_id = aws_network_interface.firewall_web.id
    }

    tags = {
        Name = "RT-Web-Firewall"
    }
}

# Tabla de la Subred BD
resource "aws_route_table" "rt_bd" {
    vpc_id = var.vpc_id
    route {
        cidr_block = "0.0.0.0/0"
        network_interface_id = aws_instance.servidor_firewall.primary_network_interface_id
    }

    route {
        cidr_block = var.rango_subred_web
        network_interface_id = aws_network_interface.firewall_bd.id
    }

    tags = {
        Name = "RT-BD-Firewall"
    }
}

# Asociamos las tablas a las subredes
resource "aws_route_table_association" "a_web" {
    subnet_id = var.subred_web_id
    route_table_id = aws_route_table.rt_web.id
}

resource "aws_route_table_association" "a_bd" {
    subnet_id = var.subred_bd_id
    route_table_id = aws_route_table.rt_bd.id
}
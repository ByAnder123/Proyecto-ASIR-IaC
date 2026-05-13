#====================#
# GRUPO DE SEGURIDAD #
#====================#
resource "aws_security_group" "sg_bd" {
    name = "SG-BD"
    description = "Permitir todo el trafico interno."
    vpc_id = var.vpc_id

    # Entrada: Permitimos todo
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [var.rango_vpc] 
    }

    # Salida: Permitimos todo
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "SG-BD"
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

#======================#
# MÁQUINA VIRTUAL - BD #
#======================#
resource "aws_instance" "servidor_bd" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    key_name = var.clave_ssh
    subnet_id = var.subred_bd_id
    private_ip = var.ip_privada_bd
    vpc_security_group_ids = [aws_security_group.sg_bd.id]
    associate_public_ip_address = false 

    tags = {
        Name = "VM-Base-Datos"
    }
}
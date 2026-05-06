# Red principal - VPC
resource "aws_vpc" "red_principal" {
    cidr_block = var.rango_vpc
    tags = {
        Name = "VPC-ASIR-Router"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.red_principal.id
    tags = {
        Name = "Salida-Internet"
    }
}

#==========#
# SUBREDES #
#==========#
# Subred publica - DMZ
resource "aws_subnet" "sub_publica" {
    vpc_id = aws_vpc.red_principal.id
    cidr_block = var.rango_subred_publica
    availability_zone = var.zona_disponibilidad
    tags = {
        Name = "Sub-Publica"
    }
}

# Subred privada - Web
resource "aws_subnet" "sub_web" {
    vpc_id = aws_vpc.red_principal.id
    cidr_block = var.rango_subred_web
    availability_zone = var.zona_disponibilidad
    tags = {
        Name = "Sub-Web"
    }
}

# Subred privada - BD
resource "aws_subnet" "sub_bd" {
    vpc_id = aws_vpc.red_principal.id
    cidr_block = var.rango_subred_bd
    availability_zone = var.zona_disponibilidad
    tags = {
        Name = "Sub-BD"
    }
}

#======================#
# ENRUTAMIENTO PUBLICA #
#======================#
resource "aws_route_table" "rt_publica" {
    vpc_id = aws_vpc.red_principal.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "a_publica" {
    subnet_id = aws_subnet.sub_publica.id
    route_table_id = aws_route_table.rt_publica.id
}
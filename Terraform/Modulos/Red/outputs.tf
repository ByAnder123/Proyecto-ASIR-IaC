output "vpc_id" {
    description = "ID de la VPC"
    value = aws_vpc.red_principal.id
}

output "subred_publica_id" {
    description = "ID de la subred DMZ pública"
    value = aws_subnet.sub_publica.id    
}

output "subred_web_id" {
    description = "ID de la subred privada de Web"
    value = aws_subnet.sub_web.id  
}

output "subred_bd_id" {
    description = "ID de la subred privada de BD"
    value = aws_subnet.sub_bd.id           
}

output "igw_id" {
    description = "ID del Internet Gateway"
    value = aws_internet_gateway.igw.id
}

output "subred_alb_respaldo_id" {
    description = "ID de la subred fantasma para el ALB"
    value = aws_subnet.sub_alb_respaldo.id  
}
output "dns_alb" {
    description = "El nombre DNS autogenerado del Balanceador de Cargas"
    value = aws_lb.balanceador_web.dns_name
}
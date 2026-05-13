output "ip_privada_bd" {
    description = "La IP interna de la Base de Datos"
    value = aws_instance.servidor_bd.private_ip
}
output "ip_publica_firewall" {
    description = "La IP Pública Fija del Firewall para entrar por SSH"
    value = aws_eip.ip_fija_firewall.public_ip
}

output "ip_privada_web" {
    description = "La IP interna del Firewall en la LAN Web (eth1)"
    value = aws_network_interface.firewall_web.private_ip
}

output "ip_privada_bd" {
    description = "La IP interna del Firewall en la LAN Base de Datos (eth2)"
    value = aws_network_interface.firewall_bd.private_ip
}
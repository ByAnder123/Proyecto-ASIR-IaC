output "ip_publica_firewall" {
    description = "IP publica para conectarte por SSH"
    value = module.firewall.ip_publica_firewall
}

output "dns_alb" {
    description = "El nombre DNS autogenerado del Balanceador de Cargas"
    value = module.web.dns_alb
}
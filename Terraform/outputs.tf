output "ip_publica_firewall" {
  description = "IP publica para conectarte por SSH"
  value = module.firewall.ip_publica_firewall
}
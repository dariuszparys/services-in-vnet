output "public_entry_ip" {
  description = "Public Ip to call endpoint"
  value       = azurerm_public_ip.entry.ip_address
}

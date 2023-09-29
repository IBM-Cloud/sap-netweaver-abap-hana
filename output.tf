output "DB_HOSTNAME" {
  value		= module.db-vsi.HOSTNAME
}

output "DB_PRIVATE_IP" {
  value		= module.db-vsi.PRIVATE-IP
}

output "APP_HOSTNAME" {
  value		= module.app-vsi.HOSTNAME
}

output "APP_PRIVATE_IP" {
  value		= module.app-vsi.PRIVATE-IP
}

output "ATR_INSTANCE_NAME" {
  description = "Activity Tracker instance name."
  value       = var.ATR_NAME
}

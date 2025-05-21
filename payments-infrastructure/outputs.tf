output "payments_vm_ip_address" {
  value       = aws_instance.payments.private_ip
  description = "Private IP address for payments VM"
}
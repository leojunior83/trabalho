output "ec2_public_ip" {
  value = aws_instance.this[0].public_ip
}

output "efs_endpoint" {
  value = aws_efs_mount_target.efs-mt-site.dns_name
}

output "ssh_key" {
  value     = tls_private_key.this.private_key_pem
  sensitive = true
}
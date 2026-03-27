# =============================================================================
# Outputs
# =============================================================================
output "bastion_public_ip" {
  description = "Bastion host public IP — SSH entry point"
  value       = aws_instance.bastion.public_ip
}

output "jenkins_private_ip" {
  description = "Jenkins server private IP — reachable via bastion"
  value       = aws_instance.jenkins.private_ip
}

output "ssh_command" {
  description = "SSH jump command to reach Jenkins"
  value       = "ssh -J ec2-user@${aws_instance.bastion.public_ip} ec2-user@${aws_instance.jenkins.private_ip}"
}

output "jenkins_url" {
  description = "Jenkins UI — accessible from inside the VPC only"
  value       = "http://${aws_instance.jenkins.private_ip}:8080"
}

output "jenkins_initial_admin_password" {
  description = "Jenkins initial admin password — rotate after first login"
  value       = var.read_jenkins_password ? data.aws_ssm_parameter.jenkins_admin_password[0].value : "Run again with -var='read_jenkins_password=true' after Jenkins boots"
  sensitive   = true
}
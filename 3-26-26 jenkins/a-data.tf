data "aws_ssm_parameter" "jenkins_admin_password" {
  count           = var.read_jenkins_password ? 1 : 0
  name            = "/jenkins/initial-admin-password"
  with_decryption = true
}
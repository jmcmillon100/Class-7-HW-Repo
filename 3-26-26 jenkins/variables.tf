variable "read_jenkins_password" {
  type        = bool
  default     = false
  description = "Set to true on second apply after Jenkins has booted and written the password to SSM"
}

# variable "tags" {
#   type = map(string)
#   default = {
#     environment = "dev"
#     owner       = "thedawgs"
#   }
#   description = "Common tags to apply to all resources"
# }
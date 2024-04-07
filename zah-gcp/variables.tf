variable "username" {
  type = string
  description = "username to use for the vm"
  default = "zah"
}

variable "ssh_pub_key" {
  type = string
  description = "location of the public key for ssh"
  default = "/home/omar/.ssh/id_rsa.pub"
}

variable "cloudflare_api_token" {}

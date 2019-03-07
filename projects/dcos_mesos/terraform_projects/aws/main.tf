provider "aws" {
  # Change your default region here
  region = "us-east-1"
}

module "dcos" {
  source  = "dcos-terraform/dcos/aws"
  version = "~> 0.1"

  cluster_name        = "dcos-mesos"
  ssh_public_key_file = "~/.ssh/id_rsa.pub"
  admin_ips           = ["${data.http.whatismyip.body}/32"]

  num_masters        = "1"
  num_private_agents = "1"
  num_public_agents  = "2"

  dcos_version = "1.12.0"

  dcos_instance_os    = "rhel_7.3"
  bootstrap_instance_type = "t2.medium"
  masters_instance_type  = "t2.medium"
  private_agents_instance_type = "t2.medium"
  public_agents_instance_type = "t2.medium"

  providers = {
    aws = "aws"
  }

  # dcos_variant              = "ee"
  # dcos_license_key_contents = "${file("./license.txt")}"
  dcos_variant = "open"

  dcos_install_mode = "${var.dcos_install_mode}"
}

variable "dcos_install_mode" {
  description = "specifies which type of command to execute. Options: install or upgrade"
  default     = "install"
}

# Used to determine your public IP for forwarding rules
data "http" "whatismyip" {
  url = "http://whatismyip.akamai.com/"
}

output "masters-ips" {
  value = "${module.dcos.masters-ips}"
}

output "cluster-address" {
  value = "${module.dcos.masters-loadbalancer}"
}

output "public-agents-loadbalancer" {
  value = "${module.dcos.public-agents-loadbalancer}"
}

data "aws_vpc" "default" {
  default = true
}

module "ec2_backend" {
  instance_name    = "france-backend-instance"
  source           = "../../../ec2-instance"
  ami              = "ami-0256daaa9dbc8ea3c"
  instance_type    = "t4g.small"
  environment      = "prod"
  allowed_ports    = [22, 80, 9000]
  region           = "eu-west-3"
  ssh_user         = "admin"
  ansible_playbook = "playbook.yml"
  use_elastic_ip   = true
}

module "ec2_frontend" {
  instance_name    = "france-frontend-instance"
  source           = "../../../ec2-instance"
  ami              = "ami-0256daaa9dbc8ea3c"
  instance_type    = "t4g.small"
  environment      = "prod"
  allowed_ports    = [22, 80, 443, 3000]
  region           = "eu-west-3"
  ssh_user         = "admin"
  ansible_playbook = "playbook-frontend.yml"
  backend_ip       = module.ec2_backend.instance_ip
  use_elastic_ip   = true
  
  depends_on = [module.ec2_backend]
}

output "backend_instance_ip" {
  value = module.ec2_backend.instance_ip
}

output "frontend_instance_ip" {
  value = module.ec2_frontend.instance_ip
}

output "backend_ssh_private_key" {
  value     = module.ec2_backend.ssh_private_key
  sensitive = true
}

output "frontend_ssh_private_key" {
  value     = module.ec2_frontend.ssh_private_key
  sensitive = true
}
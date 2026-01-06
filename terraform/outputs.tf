output "france_dev_ip" {
  value = module.france_dev.instance_ip
}

output "france_staging_ip" {
  value = module.france_staging.instance_ip
}

output "france_prod_ip" {
  value = module.france_prod.instance_ip
}

output "germany_dev_ip" {
  value = module.germany_dev.instance_ip
}

output "germany_staging_ip" {
  value = module.germany_staging.instance_ip
}

output "germany_prod_ip" {
  value = module.germany_prod.instance_ip
}

output "ssh_private_keys" {
  value = {
    france_dev     = module.france_dev.ssh_private_key
    germany_dev    = module.germany_dev.ssh_private_key
    france_staging = module.france_staging.ssh_private_key
    germany_staging = module.germany_staging.ssh_private_key
    france_prod    = module.france_prod.ssh_private_key
    germany_prod   = module.germany_prod.ssh_private_key
  }
  sensitive = true
}
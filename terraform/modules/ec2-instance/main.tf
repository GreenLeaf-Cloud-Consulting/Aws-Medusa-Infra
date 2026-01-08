locals {
  provisioning_ip = var.use_elastic_ip ? aws_eip.instance_eip[0].public_ip : aws_instance.debian_instance.public_ip
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key-${var.region}-${var.environment}-${var.instance_name}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

variable "ssh_user" {
  description = "User to connect via SSH"
  type        = string
}


resource "aws_instance" "debian_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.instance_sg.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Environment = var.environment
    Name        = "Instance-${var.environment}"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Instance is ready yeahhhh !!!!!!!!!!!!!!!!!!!'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = tls_private_key.ssh_key.private_key_pem
      host        = self.public_ip
    }
  }
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/../../keys/${var.environment}-${var.instance_name}-key.pem"
  file_permission = "0400"
}

resource "aws_eip" "instance_eip" {
  count    = var.use_elastic_ip ? 1 : 0
  instance = aws_instance.debian_instance.id

  tags = {
    Environment = var.environment
    Name        = "${var.instance_name}-eip"
  }
}

# Attendre que l'EIP soit attachée avant de provisionner
resource "null_resource" "wait_for_eip" {
  count = var.use_elastic_ip ? 1 : 0

  triggers = {
    eip_id = aws_eip.instance_eip[0].id
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [aws_eip.instance_eip]
}

# Provisioning avec Ansible après l'EIP
resource "null_resource" "ansible_provisioning" {
  triggers = {
    instance_id = aws_instance.debian_instance.id
    playbook    = var.ansible_playbook
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "ssh-${var.environment}-${var.instance_name}:" >> ${path.root}/Makefile
      echo "\tssh -i ${path.root}/keys/${var.environment}-${var.instance_name}-key.pem ${var.ssh_user}@${local.provisioning_ip}" >> ${path.root}/Makefile
      echo "" >> ${path.root}/Makefile
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.root}/ansible/inventory/
      echo "[web]" > ${path.root}/ansible/inventory/${var.environment}-${var.instance_name}
      echo "${local.provisioning_ip} ansible_user=${var.ssh_user}" >> ${path.root}/ansible/inventory/${var.environment}-${var.instance_name}
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i ${path.root}/ansible/inventory/${var.environment}-${var.instance_name} \
        -u ${var.ssh_user} \
        --private-key ${path.root}/keys/${var.environment}-${var.instance_name}-key.pem \
        ${var.backend_ip != "" ? "-e backend_ip=${var.backend_ip}" : ""} \
        ${var.frontend_ip != "" ? "-e frontend_ip=${var.frontend_ip}" : ""} \
        ${path.root}/ansible/${var.ansible_playbook}
    EOT
  }

  depends_on = [
    aws_instance.debian_instance,
    local_file.ssh_private_key,
    null_resource.wait_for_eip
  ]
}
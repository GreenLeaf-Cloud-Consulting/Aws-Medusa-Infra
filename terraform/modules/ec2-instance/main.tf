resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "generated_key" {
  key_name   = "key-${var.environment}"
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

  provisioner "local-exec" {
    command = <<EOT
      echo "ssh-${var.environment}-${var.instance_name}:" >> ${path.root}/Makefile
      echo "\tssh -i ${path.root}/keys/${var.environment}-${var.instance_name}-key.pem ${var.ssh_user}@${self.public_ip}" >> ${path.root}/Makefile
      echo "" >> ${path.root}/Makefile
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.root}/ansible/inventory/
      echo "[web]" > ${path.root}/ansible/inventory/${var.environment}-${var.instance_name}
      echo "${self.public_ip} ansible_user=${var.ssh_user}" >> ${path.root}/ansible/inventory/${var.environment}-${var.instance_name}
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
        -i ${path.root}/ansible/inventory/${var.environment}-${var.instance_name} \
        -u ${var.ssh_user} \
        --private-key ${path.root}/keys/${var.environment}-${var.instance_name}-key.pem \
        ${path.root}/ansible/playbook.yml
    EOT
  }
}


resource "local_file" "ssh_private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/../../keys/${var.environment}-${var.instance_name}-key.pem"
  file_permission = "0400"
}
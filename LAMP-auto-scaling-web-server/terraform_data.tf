resource "terraform_data" "copy_php" {
  depends_on = [aws_instance.public_ec2, local_file.dbinfo_file]

  count = length(var.availability_zones)

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = element(aws_eip.public_ec2.*.public_ip, count.index)
    private_key = tls_private_key.ec2_private_key.*.private_key_pem[0]
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -d /var/www/html ]; do sleep 5; done",
      "echo '/var/www/html is ready'",
      "sudo chown -R ec2-user:apache /var/www/html",
      "sudo chmod -R 775 /var/www/html"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/index.php"
    destination = "/var/www/html/index.php"
  }

  provisioner "file" {
    source      = "${path.module}/dbinfo.inc"
    destination = "/var/www/html/dbinfo.inc"
  }
}

resource "terraform_data" "delete_dbinfo_file" {
  depends_on = [aws_ami_from_instance.public_ec2_ami]
  provisioner "local-exec" {
    command = "rm -f ${path.module}/dbinfo.inc"
  }
}

resource "terraform_data" "copy_key" {
  depends_on = [local_file.private_ec2_key, aws_ami_from_instance.public_ec2_ami]

  count = length(var.availability_zones)

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = element(aws_eip.public_ec2.*.public_ip, count.index)
    private_key = tls_private_key.ec2_private_key.*.private_key_pem[0]
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/ec2-user/keys"
    ]
  }

  provisioner "file" {
    source      = "${path.module}/${local_file.private_ec2_key.filename}"
    destination = "/home/ec2-user/keys/${local_file.private_ec2_key.filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/ec2-user/keys/${local_file.private_ec2_key.filename}"
    ]
  }
}

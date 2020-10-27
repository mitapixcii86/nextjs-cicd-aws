#Generate private key for ansible to access EC2 instance
resource "tls_private_key" "test_devops" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "cloud_pem_private" {
  filename = "key/terraform-ansible.pem"
  content  = tls_private_key.test_devops.private_key_pem
  provisioner "local-exec" {
    command = "chmod 400 ${self.filename}"
  }
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.test_devops.public_key_openssh
}

# security group for EC2 instances
resource "aws_security_group" "test_devops_ec2" {
  name        = "docker-nginx-test_devops-ec2"
  description = "allow incoming ssh and HTTP traffic only"
  vpc_id      = aws_vpc.test_devops.id
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# EC2 instances, one per availability zone
resource "aws_instance" "test_devops" {
  ami                         = lookup(var.ec2_amis, var.aws_region)
  associate_public_ip_address = true
  count                       = length(var.azs)
  depends_on                  = [aws_subnet.private]
  instance_type               = "t2.micro"
  subnet_id                   = element(aws_subnet.private.*.id, count.index)
  key_name                    = aws_key_pair.generated_key.key_name

  # references security group created above
  vpc_security_group_ids = [aws_security_group.test_devops_ec2.id]
  tags = {
    Name = "docker-nginx-test_devops-instance-${count.index}"
  }
  provisioner "file" {
    source      = "../app"
    destination = "/home/ubuntu"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(local_file.cloud_pem_private.filename)
    agent       = false

  }
}
#Attaching elastic IP
resource "aws_eip" "ip-test_devops" {
  instance = element(aws_instance.test_devops.*.id, count.index)
  count    = length(var.azs)
  vpc      = true
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(local_file.cloud_pem_private.filename)
    agent       = false

  }
  provisioner "remote-exec" {
    inline = ["sudo chmod +x /home/ubuntu",
    "sudo chmod +x /home/ubuntu/app/user_data.sh",
    "sudo /home/ubuntu/app/user_data.sh"]
  }
}




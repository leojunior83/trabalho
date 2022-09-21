data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${local.prefix}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "aws_instance" "this" {
  depends_on                  = [aws_efs_mount_target.efs-mt-site]
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.aws_instance_type
  count                       = 1
  key_name                    = aws_key_pair.this.key_name
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.sg-web.id]
  subnet_id              = aws_subnet.this.id
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-site"
    }
  )

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.this.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl wget nfs-common",
      "sudo mkdir -p /mnt/website && sudo chown ubuntu:ubuntu -R /mnt/website",
      "sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_mount_target.efs-mt-site.dns_name}:/ /mnt/website",
      "sudo curl -fsSL https://get.docker.com | bash",
      "sudo docker run --name ${local.prefix}-website-nginx -v /mnt/website:/usr/share/nginx/html:ro -p 80:80 -d nginx",
    ]
  }
  
  
  provisioner "file" {
    source      = "index.html"
    destination = "/mnt/website/"
  }

}

resource "aws_efs_file_system" "efs-site" {
  creation_token   = "site"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-source-site"
    }
  )
}

resource "aws_efs_mount_target" "efs-mt-site" {
  file_system_id  = aws_efs_file_system.efs-site.id
  subnet_id       = aws_subnet.this.id
  security_groups = ["${aws_security_group.ingress-efs-site.id}"]
}

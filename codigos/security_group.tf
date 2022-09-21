# Security Group
resource "aws_security_group" "sg-web" {
  name        = "${local.prefix}-sg-web"
  description = "Security Group para acesso SSH e HTTP"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.prefix}-sg"
    }
  )
}

resource "aws_security_group" "ingress-efs-site" {
  name   = "${local.prefix}-sg-efs-site"
  vpc_id = aws_vpc.this.id

  // NFS
  ingress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  // Terraform removes the default rule
  egress {
    cidr_blocks = [aws_vpc.this.cidr_block]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}
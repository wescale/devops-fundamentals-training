data "aws_vpc" "main" {}

resource "aws_security_group" "allow_ssh" {
  name        = "${data.aws_caller_identity.current.user_id}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "SSH from Internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}
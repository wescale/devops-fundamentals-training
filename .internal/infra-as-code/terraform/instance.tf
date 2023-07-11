data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.large"

  tags = {
    Name = "${data.aws_caller_identity.current.user_id}-server"
  }

  key_name = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
}
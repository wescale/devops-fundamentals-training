resource "aws_key_pair" "deployer" {
  key_name   = "${data.aws_caller_identity.current.user_id}deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
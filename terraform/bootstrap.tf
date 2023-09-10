# Create a private key
resource "tls_private_key" "private" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Upload key to AWS
resource "aws_key_pair" "private" {
  key_name   = var.key_name
  public_key = tls_private_key.private.public_key_openssh
}

# Save file
resource "local_file" "private_ssh_key" {
  filename = "../.ssh/id_rsa"
  content  = tls_private_key.private.private_key_openssh
}

resource "local_file" "public_ssh_key" {
  filename = "../.ssh/id_rsa.pub"
  content  = tls_private_key.private.public_key_openssh
}

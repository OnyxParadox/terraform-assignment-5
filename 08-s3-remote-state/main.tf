provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-065d2b03fb493085a"
  instance_type = "t3.micro"

  tags = {
    Name = "s3-state-terraform"
  }
}

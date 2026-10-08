provider "aws" {
  region = "ap-south-1"
}

module "ec2" {
  source = "./modules/ec2"

  ami           = "ami-065d2b03fb493085a"
  instance_type = "t3.micro"
  name          = "module-terraform"
}

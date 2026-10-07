variable "instance_name" {
	description = "value of the EC2 instance's Name tag."
	type = string
	default = "input-terraform"
}

variable "instance_type" {
	description = " The EC2 instance's type."
	type = string
	default = "t3.micro"
}

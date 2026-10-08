variable "ami" {
  description = "AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "name" {
  description = "Name tag for the EC2 instance."
  type        = string
}

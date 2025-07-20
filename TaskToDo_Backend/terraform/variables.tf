variable "aws_region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"  # Free tier in eu-north-1
}

variable "key_name" {
  default = "gitlab-deploy-key"  
}

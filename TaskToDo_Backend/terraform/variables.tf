variable "aws_region" {
  default = "eu-north-1"
}

variable "ami_id" {
  default = "ami-0c101f26f147fa7fd"  # Amazon Linux 2 for eu-north-1
}

variable "instance_type" {
  default = "t3.micro"  # Free tier in eu-north-1
}

variable "key_name" {
  default = "my-ci-key"  # Update this to match your key in AWS Console
}

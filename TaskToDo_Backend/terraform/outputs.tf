output "instance_public_ip" {
  value = aws_instance.ci_instance.public_ip
}




    # Create custom VPC
    resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true

    tags = {
        Name = "main-vpc"
    }
    }

    # Create subnet
    resource "aws_subnet" "main_subnet" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true

    tags = {
        Name = "main-subnet"
    }
    }

    # Internet Gateway
    resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "main-gw"
    }
    }
data "aws_ebs_volume" "docker_volume" {
  filter {
    name   = "tag:Name"
    values = ["DockerVolume"]
  }

  filter {
    name   = "availability-zone"
    values = [aws_instance.ci_instance.availability_zone]
  }
}

    # Route Table
    resource "aws_route_table" "main_rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "main-rt"
    }
    }

    # Associate Route Table with Subnet
    resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.main_subnet.id
    route_table_id = aws_route_table.main_rt.id
    }

    # Security Group (SSH + port 3000)
    resource "aws_security_group" "ssh_access" {
    name        = "allow_ssh_and_app"
    description = "Allow SSH and app access"
    vpc_id      = aws_vpc.main.id

    ingress {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow port 3000 for app"
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "allow_ssh_and_app"
    }
    }

    # Get latest Ubuntu AMI
    data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
    }

    # EC2 Instance
    resource "aws_instance" "ci_instance" {
    ami                         = data.aws_ami.ubuntu.id
    instance_type               = var.instance_type
    key_name                    = var.key_name
    subnet_id                   = aws_subnet.main_subnet.id
    vpc_security_group_ids      = [aws_security_group.ssh_access.id]
    associate_public_ip_address = true
userdata = <<-EOF
#!/bin/bash
set -eux

# Wait for the volume to appear
while [ ! -b /dev/nvme1n1 ]; do sleep 1; done

# Create mount point if it doesn't exist
mkdir -p /mnt/mongo-data

# Mount the volume (skip if already mounted)
if ! mountpoint -q /mnt/mongo-data; then
  mount /dev/nvme1n1 /mnt/mongo-data
fi

# Add to fstab if not already present to persist mount after reboot
grep -q '/dev/nvme1n1 /mnt/mongo-data' /etc/fstab || \
  echo '/dev/nvme1n1 /mnt/mongo-data ext4 defaults,noatime,nofail 0 2' >> /etc/fstab

# Change ownership so MongoDB container (user 999) can write
chown -R 999:999 /mnt/mongo-data
EOF


    depends_on = [
        aws_route_table_association.a
    ]

    tags = {
        Name = "ci-cd-ec2"
    }
    }

resource "aws_volume_attachment" "docker_volume" {
  device_name = "/dev/xvdf"
  volume_id   = data.aws_ebs_volume.docker_volume.id
  instance_id = aws_instance.ci_instance.id
  force_detach = true
}

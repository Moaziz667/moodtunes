variable "aws_region" {
  default = "eu-north-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "gitlab-deploy-key"
}

# =============================================================================
# MongoDB Atlas Variables
# =============================================================================

variable "atlas_public_key" {
  description = "MongoDB Atlas API Public Key"
  type        = string
  sensitive   = true
  default     = ""  # Provide via CI/CD or TF Cloud variables
}

variable "atlas_private_key" {
  description = "MongoDB Atlas API Private Key"
  type        = string
  sensitive   = true
  default     = ""  # Provide via CI/CD or TF Cloud variables
}

variable "atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
  default     = ""  # Provide via CI/CD or TF Cloud variables
}

variable "atlas_project_name" {
  description = "MongoDB Atlas Project Name"
  type        = string
  default     = "TaskToDo-Project"
}

variable "atlas_region" {
  description = "MongoDB Atlas Region (must match AWS region format for Atlas)"
  type        = string
  default     = "EU_NORTH_1"  # Stockholm - matches your AWS region
}

variable "atlas_db_username" {
  description = "MongoDB Atlas Database Username"
  type        = string
  default     = "tasktodo_admin"
}

variable "atlas_db_password" {
  description = "MongoDB Atlas Database Password"
  type        = string
  sensitive   = true
  default     = ""  # Provide via CI/CD or TF Cloud variables
}

# =============================================================================
# Auto-Scaling Variables
# =============================================================================

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 1
}

variable "docker_image" {
  description = "Docker image for the backend application"
  type        = string
  default     = "azizhk444/nodejserver"
}

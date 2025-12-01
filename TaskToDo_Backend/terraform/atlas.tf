# =============================================================================
# MongoDB Atlas Configuration
# Free tier M0 cluster for TaskToDo app
# =============================================================================

# Create Atlas Project
resource "mongodbatlas_project" "tasktodo" {
  name   = var.atlas_project_name
  org_id = var.atlas_org_id
}

# Create Free Tier M0 Cluster
resource "mongodbatlas_cluster" "tasktodo_cluster" {
  project_id = mongodbatlas_project.tasktodo.id
  name       = "tasktodo-cluster"

  # Free tier settings
  provider_name               = "TENANT"
  backing_provider_name       = "AWS"
  provider_region_name        = var.atlas_region
  provider_instance_size_name = "M0"  # Free tier!
}

# Create Database User
resource "mongodbatlas_database_user" "tasktodo_user" {
  project_id         = mongodbatlas_project.tasktodo.id
  username           = var.atlas_db_username
  password           = var.atlas_db_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "TaskToDo"
  }
}

# Whitelist IP Access (allow from anywhere for CI/CD flexibility)
# In production, you'd restrict this to specific IPs
resource "mongodbatlas_project_ip_access_list" "tasktodo_access" {
  project_id = mongodbatlas_project.tasktodo.id
  cidr_block = "0.0.0.0/0"
  comment    = "Allow access from anywhere (for CI/CD and dynamic EC2 IPs)"
}

# Output the connection string
locals {
  atlas_connection_string = "mongodb+srv://${var.atlas_db_username}:${var.atlas_db_password}@${replace(mongodbatlas_cluster.tasktodo_cluster.connection_strings[0].standard_srv, "mongodb+srv://", "")}/TaskToDo?retryWrites=true&w=majority"
}

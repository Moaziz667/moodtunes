# =============================================================================
# 🎬 CONFIGURATION DÉMO - Autoscaling plus rapide pour la vidéo
# =============================================================================
# Ce fichier override les valeurs pour une démo plus rapide
# Usage: terraform apply -var-file="demo.tfvars"
# =============================================================================

# ASG avec plus de capacité pour voir le scaling
asg_min_size         = 1
asg_max_size         = 4
asg_desired_capacity = 1

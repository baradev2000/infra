variable "aws_region" {
  description = "Région AWS de production."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Préfixe des ressources AWS."
  type        = string
  default     = "examen-todo"
}

variable "key_name" {
  description = "Nom d'une EC2 Key Pair existante."
  type        = string
}

variable "admin_cidr" {
  description = "IP publique de l'administrateur autorisée en SSH, par exemple 203.0.113.10/32."
  type        = string
}

variable "instance_type" {
  description = "m7i-flex.large (8 Go RAM) est adapté à SonarQube, monitoring et application."
  type        = string
  default     = "m7i-flex.large"
}

variable "backend_repository" {
  description = "Dépôt GitHub du backend."
  type        = string
  default     = "baradev2000/examen_b"
}

variable "frontend_repository" {
  description = "Dépôt GitHub du frontend."
  type        = string
  default     = "baradev2000/examen_f"
}

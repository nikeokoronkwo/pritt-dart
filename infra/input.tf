variable "location" {
  type        = string
  description = "The main location for instances"
  default     = "us-central1"
}

variable "project_id" {
  type        = string
  description = "The (GCP) Project ID"
}

variable "instance_url" {
  type        = string
  description = "The Instance URL for the given service"
}

variable "api_image_id" {
  description = "The Docker image ID for the API service"
  type        = string
}

variable "frontend_image_id" {
  description = "The Docker image ID for the frontend application"
  type        = string
}

variable "runner_image_id" {
  description = "The Docker image ID for the adapter runner service application"
  type        = string
}

variable "production" {
  type    = bool
  default = false
}

variable "tier" {
  type        = string
  description = "(WARN: Temporary feature) The tier for the given deployment"

  validation {
    condition     = contains(["basic", "pro", "enterprise", "custom"], var.tier)
    error_message = "Allowed values for the 'tier' parameter are: 'basic', 'pro', 'enterprise' and 'custom'"
  }
}
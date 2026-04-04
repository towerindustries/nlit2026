variable "workshop_name" {
  description = "Name of the workshop"
  type        = string
  default     = "Terraform 101"
}

variable "student_name" {
  description = "Student or attendee name"
  type        = string
  default     = "Attendee"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

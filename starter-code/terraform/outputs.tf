output "generated_file" {
  description = "Path to the generated file"
  value       = local_file.workshop_file.filename
}

output "summary" {
  description = "Simple workshop summary"
  value       = "${var.student_name} is running ${var.workshop_name} in ${var.environment}."
}

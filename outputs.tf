output "arn" {
  description = "Lambda ARN"
  value       = var.s3_bucket != null && var.s3_key != null ? aws_lambda_function.s3_lambda[0].arn : aws_lambda_function.filename_lambda[0].arn
}

output "version" {
  description = "Lambda Version"
  value       = var.s3_bucket != null && var.s3_key != null ? aws_lambda_function.s3_lambda[0].version : aws_lambda_function.filename_lambda[0].version
}

output "name" {
  description = "Lambda Name"
  value       = var.s3_bucket != null && var.s3_key != null ? aws_lambda_function.s3_lambda[0].function_name : aws_lambda_function.filename_lambda[0].function_name
}

output "invoke_arn" {
  description = "ARN to invoke the lambda method"
  value       = var.s3_bucket != null && var.s3_key != null ? aws_lambda_function.s3_lambda[0].invoke_arn : aws_lambda_function.filename_lambda[0].invoke_arn
}

output "cloudwatch_logs_arn" {
  description = "The arn of theh log group."
  value       = aws_cloudwatch_log_group.this.arn
}

output "cloudwatch_logs_name" {
  description = "The name of the log group."
  value       = aws_cloudwatch_log_group.this.name
}


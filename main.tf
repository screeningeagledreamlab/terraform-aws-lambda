resource aws_lambda_function filename_lambda {
  count = var.s3_bucket == null && var.s3_key == null ? 1 : 0

  function_name                  = format("%s", var.function_name)
  filename                       = var.filename
  description                    = var.description
  role                           = var.role_arn
  handler                        = var.handler
  runtime                        = var.runtime
  publish                        = var.publish
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.concurrency
  timeout                        = var.lambda_timeout
  tags                           = var.tags
  source_code_hash               = var.source_code_hash
  layers                         = var.layers

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config == null ? [] : [var.file_system_config]
    content {
      arn              = file_system_config.value.efs_access_point_arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = var.environment
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
    ]
  }

  depends_on = [aws_cloudwatch_log_group.this]
}

resource aws_lambda_function_event_invoke_config filename_lambda {
  count = var.s3_bucket == null && var.s3_key == null ? 1 : 0

  function_name                = aws_lambda_function.filename_lambda[0].function_name
  qualifier                    = aws_lambda_function.filename_lambda[0].version
  maximum_event_age_in_seconds = var.event_age_in_seconds
  maximum_retry_attempts       = var.retry_attempts

  depends_on = [
    aws_lambda_function.filename_lambda
  ]
}

resource aws_lambda_function_event_invoke_config filename_lambda_latest {
  count = var.s3_bucket == null && var.s3_key == null ? 1 : 0

  function_name                = aws_lambda_function.filename_lambda[0].function_name
  qualifier                    = "$LATEST"
  maximum_event_age_in_seconds = var.event_age_in_seconds
  maximum_retry_attempts       = var.retry_attempts

  depends_on = [
    aws_lambda_function.filename_lambda
  ]
}

resource aws_s3_bucket_object s3_file {
  count = var.s3_bucket != null && var.s3_key != null ? 1 : 0

  bucket      = var.s3_bucket
  key         = var.s3_key
  source      = var.filename
  source_hash = filemd5(var.filename)
}

resource aws_lambda_function s3_lambda {
  count = var.s3_bucket != null && var.s3_key != null ? 1 : 0

  function_name                  = format("%s", var.function_name)
  description                    = var.description
  role                           = var.role_arn
  handler                        = var.handler
  runtime                        = var.runtime
  publish                        = var.publish
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.concurrency
  timeout                        = var.lambda_timeout
  tags                           = var.tags
  layers                         = var.layers

  s3_bucket                      = var.s3_bucket
  s3_key                         = var.s3_key
  s3_object_version              = element(concat(aws_s3_bucket_object.s3_file.*.version_id, [null]), 0)

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [var.vpc_config]
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  dynamic "file_system_config" {
    for_each = var.file_system_config == null ? [] : [var.file_system_config]
    content {
      arn              = file_system_config.value.efs_access_point_arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_config == null ? [] : [var.tracing_config]
    content {
      mode = tracing_config.value.mode
    }
  }

  dynamic "environment" {
    for_each = var.environment == null ? [] : [var.environment]
    content {
      variables = var.environment
    }
  }

  lifecycle {
    ignore_changes = [
      filename,
    ]
  }

  depends_on = [aws_s3_bucket_object.s3_file, aws_cloudwatch_log_group.this]
}

resource aws_lambda_function_event_invoke_config s3_lambda {
  count = var.s3_bucket != null && var.s3_key != null ? 1 : 0

  function_name                = aws_lambda_function.s3_lambda[0].function_name
  qualifier                    = aws_lambda_function.s3_lambda[0].version
  maximum_event_age_in_seconds = var.event_age_in_seconds
  maximum_retry_attempts       = var.retry_attempts

  depends_on = [
    aws_lambda_function.s3_lambda
  ]
}

resource aws_lambda_function_event_invoke_config s3_lambda_latest {
  count = var.s3_bucket != null && var.s3_key != null ? 1 : 0

  function_name                = aws_lambda_function.s3_lambda[0].function_name
  qualifier                    = "$LATEST"
  maximum_event_age_in_seconds = var.event_age_in_seconds
  maximum_retry_attempts       = var.retry_attempts

  depends_on = [
    aws_lambda_function.s3_lambda
  ]
}

# Cloud watch
resource aws_cloudwatch_log_group this {
  name              = format("/aws/lambda/%s", var.function_name)
  retention_in_days = var.log_retention

  tags = merge(var.tags,
    { Function = format("%s", var.function_name) }
  )
}

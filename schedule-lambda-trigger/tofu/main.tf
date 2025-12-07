terraform {
  required_version = ">= 1.10.0, < 1.11.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.25.0"
    }

    archive = {
      source = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.aws_profile
}

# --- 1. IAM Role for Lambda Execution ---
resource "aws_iam_role" "scheduled_lambda" {
  name = "${var.name_prefix}-demo-scheduled-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Policy for logging
resource "aws_iam_policy" "scheduled_lambda" {
  name        = "${var.name_prefix}-demo-scheduled-lambda-policy"
  description = "Allows the scheduled Lambda to write logs to CloudWatch."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "scheduled_lambda" {
  role       = aws_iam_role.scheduled_lambda.name
  policy_arn = aws_iam_policy.scheduled_lambda.arn
}

# --- 2. Lambda Deployment Package (Zip the Python code) ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../process.py"
  output_path = "process.zip"
}

# --- 3. Lambda Function Definition ---
resource "aws_lambda_function" "schedule_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-demo-scheduled-lambda-function"
  role             = aws_iam_role.scheduled_lambda.arn
  handler          = "process.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 128
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}
# --- 4. IAM Role for EventBridge Scheduler Execution ---
# The Scheduler itself needs an IAM role to invoke the target (Lambda)
resource "aws_iam_role" "scheduler" {
  name = "${var.name_prefix}-demo-scheduled-lambda-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })
}

# Policy allowing the Scheduler role to invoke the Lambda function
resource "aws_iam_policy" "scheduler" {
  name        = "${var.name_prefix}-demo-scheduled-lambda-eventbridge-policy"
  description = "Allows the EventBridge Scheduler role to invoke the target Lambda."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "lambda:InvokeFunction",
        Effect = "Allow",
        Resource = aws_lambda_function.schedule_processor.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "scheduler" {
  role       = aws_iam_role.scheduler.name
  policy_arn = aws_iam_policy.scheduler.arn
}

# --- 5. EventBridge Scheduler (The Schedule) ---
resource "aws_scheduler_schedule" "trigger_lambda" {
  name                = "${var.name_prefix}-demo-scheduled-lambda-trigger-scheduler"
  description         = "Fires event using EventBridge Scheduler."

  # Rate expression for fixed intervals
  schedule_expression = var.event_schedule_expression

  flexible_time_window {
    mode = "OFF" # Ensures it fires precisely
  }

  target {
    arn      = aws_lambda_function.schedule_processor.arn
    role_arn = aws_iam_role.scheduler.arn
  }
}

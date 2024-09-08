provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["C:/Users/Admin/.aws/credentials"]
  profile = "Diwakar14"
}

resource "aws_iam_role" "lambda_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = <<EOF
  {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_policy" "iam_policy_for_lambda" {
  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

data "archive_file" "zip_the_nodejs_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/hello-lambda.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
  filename = "${path.module}/lambda/hello-lambda.zip"
  function_name = "Test-Lambda-Terraform"
  role = aws_iam_role.lambda_role.arn
  handler = "index.kinesisHandler"
  runtime = "nodejs20.x"
  depends_on = [ aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role ]
}


output "teraform_aws_role_output" {
 value = aws_iam_role.lambda_role.name
}

output "teraform_aws_role_arn_output" {
 value = aws_iam_role.lambda_role.arn
}

output "teraform_logging_arn_output" {
 value = aws_iam_policy.iam_policy_for_lambda.arn
}

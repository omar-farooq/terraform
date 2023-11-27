data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "send_emails"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["ses:SendEmail", "ses:SendRawEmail"]
          Effect = "Allow"
          Resource = "*"
        },
      ]
    })
  }
}

resource "aws_lambda_function" "lambda" {
    package_type = "Image"
	image_uri = var.image_uri
	function_name = var.function_name
	role = aws_iam_role.iam_for_lambda.arn

	environment {
		variables = var.envs
	}
}

resource "aws_lambda_function_url" "lambda" {
    count = var.function_url ? 1 : 0
    function_name = aws_lambda_function.lambda.function_name
    authorization_type = "AWS_IAM"
    cors {
        allow_origins = ["https://omar.earth", "https://www.omar.earth"]
    }
}

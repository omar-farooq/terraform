data "tls_certificate" "default" {
  url = var.provider_tls_url
}

resource "aws_iam_openid_connect_provider" "default" {
  url             = var.provider_url
  client_id_list  = [var.aud_value]
  thumbprint_list = [data.tls_certificate.default.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.default.arn]
    }

    dynamic "condition" {
      for_each = var.conditions
      content {
        test        = condition.value["test"]
        variable    = condition.value["variable"]
        values      = condition.value["values"]
      }
    }
  }
}

resource "aws_iam_policy" "s3_policy" {
  name = "s3-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListAllMyBuckets", "s3:ListBucket", "s3:HeadBucket"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

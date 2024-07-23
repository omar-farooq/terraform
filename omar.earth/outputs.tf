output "GITHUB_ROLE_ARN" {
  description   = "Role that needs to be assumed by GitLab CI. We will use this as a GitLab CI Variable"
  value         = aws_iam_role.github_actions.arn
}

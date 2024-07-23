output "assume_role_policy" {
  value = data.aws_iam_policy_document.assume-role-policy.json
}

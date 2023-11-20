output "uri" {
    value = aws_ecr_repository.repo.repository_url
    description = "The repository url to be referenced by other resources - e.g. lambdas"
}

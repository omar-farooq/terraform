output "certificate_arn" {
    description = "The arn of the validated certificate"
    value = aws_acm_certificate_validation.domain.certificate_arn
}

# Expose DNS validation records (Outputs)
output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}

# After that, we need to add DNS records in Porkbun
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket  = "jcast-dev-terraform-state-bucket"
    key     = "hugo-site/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # ACM certificates for CloudFront must be in us-east-1
}

provider "aws" {
  alias  = "eu-west-1"
  region = "eu-west-1"
}

# ACM Certificate in us-east-1
resource "aws_acm_certificate" "blog_cert" {
  provider          = aws.us-east-1
  domain_name       = "jcast.dev"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.blog_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = "Z014427436PMWA745G0F4"
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "blog_cert" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.blog_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route 53 DNS Record
resource "aws_route53_record" "blog" {
  zone_id = "Z014427436PMWA745G0F4"
  name    = "jcast.dev"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

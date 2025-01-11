################################# 백엔드/프런트엔드 공통환경

provider "aws" {
  region = "us-west-2" # 원하는 AWS 리전으로 변경
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# S3
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name-143-adf-ggads2245"
  force_destroy = true # 선택 사항: 버킷 삭제 시 모든 객체 삭제
  tags = {
    Name        = "MyUniqueBucket"
    Environment = "Dev"
  }
}

################################# 백엔드 공통환경

# EC2
resource "aws_instance" "example" {
  ami           = "ami-05d38da78ce859165" # Ubuntu
  instance_type = "t2.micro" # 무료 티어 사용 가능

  # 키 페어 설정
  key_name = "keys" # 미리 생성된 SSH 키 페어 이름

  # 보안 그룹 설정
  vpc_security_group_ids = [aws_security_group.example.id]

  tags = {
    Name = "MyEC2Instance"
  }
}

# 보안 그룹 생성
resource "aws_security_group" "example" {
  name_prefix = "example-sg-"

  # 인바운드 규칙: SSH(포트 22) 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 허용 (테스트용)
  }

  # 아웃바운드 규칙: 모든 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ExampleSecurityGroup"
  }
}

# RDS
resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase" # 기본 데이터베이스 이름
  username             = "admin"      # 마스터 사용자 이름
  password             = "password1234" # 마스터 비밀번호
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = false
  skip_final_snapshot  = true

  db_subnet_group_name = aws_db_subnet_group.example.name

  tags = {
    Name = "MySQL-RDS"
  }
}

# RDS가 사용할 서브넷 그룹 생성
resource "aws_db_subnet_group" "example" {
  name       = "example-db-subnet-group"
  subnet_ids = [aws_subnet.example1.id, aws_subnet.example2.id]

  tags = {
    Name = "MyDBSubnetGroup"
  }
}

# 서브넷 예제
resource "aws_subnet" "example1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "example2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = false
}

# VPC 예제
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVPC"
  }
}

################################# 프런트엔드 환경

# S3 버킷 생성
resource "aws_s3_bucket" "frontend_bucket" {
  bucket        = "storytracks-fe"
  force_destroy = true

  tags = {
    Name        = "FrontendBucket"
    Environment = "Production"
  }
}

resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::975050152113:user/brad"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

/*
# 2. S3 버킷 정책
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend_bucket.arn}/*"
      }
    ]
  })
}
*/

# 3. ACM 인증서 생성
resource "aws_acm_certificate" "cloudfront_cert" {
  domain_name       = "storytracks.net" # 사용할 도메인 입력
  validation_method = "DNS"
  provider          = aws.us_east_1 # CloudFront는 us-east-1 리전을 요구함

  tags = {
    Name        = "CloudFront SSL Certificate"
    Environment = "Production"
  }
}

/*# 4. DNS 검증용 Route 53 레코드 생성
resource "aws_route53_record" "cert_validation" {
  zone_id = "your-route53-zone-id" # Route 53의 Hosted Zone ID 입력
  name    = aws_acm_certificate.cloudfront_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cloudfront_cert.domain_validation_options[0].resource_record_type
  records = [aws_acm_certificate.cloudfront_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60
}*/

# 4. DNS 검증을 설정
resource "aws_route53_record" "cloudfront_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cloudfront_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = "Z0788468O5RUGIE5WVB" # Route 53 호스티드 존 ID
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}

# 5. CloudFront 배포
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = aws_s3_bucket.frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3-Frontend"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Frontend"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cloudfront_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "Frontend CloudFront Distribution"
    Environment = "Production"
  }
}

# 6. Route 53 레코드(CNAME)
resource "aws_route53_record" "cloudfront_alias" {
  zone_id = "Z0788468O5RUGIE5WVB" # Route 53의 Hosted Zone ID 입력
  name    = "storytracks.net"      # 연결할 도메인 이름
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.frontend_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.frontend_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

provider "aws" {
  region = "us-west-2" # 원하는 AWS 리전으로 변경
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
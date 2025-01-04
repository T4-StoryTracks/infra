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
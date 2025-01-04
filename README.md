# infra

```bash
% aws configure
```
명령 실행 시 아래 정보를 입력합니다:  
•	AWS Access Key ID: IAM 사용자나 역할에서 발급된 액세스 키 ID.  
•	AWS Secret Access Key: 위 Access Key에 대한 비밀 키.  
•	Default region name: 사용할 AWS 리전(예: us-east-1).  
•	Default output format: JSON, YAML, TABLE 중 하나(기본값: JSON).



IAM이동
Users
[유저명]
Add permissions -> Search에 AmazonS3FullAccess를 검색후 추가  

★이거는 EC2올리기위해
Policies이동  
Create policy  
이름을 정한 후 JSON클릭후 아래를 그대로 복붙후 저장  
Users로 이동하여 User name(dev?)를 클릭  
Add permissions  
Attach policies directly클릭후 위에서 정한 이름을 검색후 Add permission  
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSecurityGroup",
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:AuthorizeSecurityGroupEgress",
                "ec2:RevokeSecurityGroupEgress",
                "ec2:CreateTags",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceCreditSpecifications",
                "ec2:DescribeTags",
                "ec2:StartInstances",
                "ec2:StopInstances",
                "ec2:DescribeVolumes",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:TerminateInstances",
                "ec2:DescribeVolumes",
                "ec2:RunInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstances",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeSecurityGroups"
            ],
            "Resource": "*"
        }
    ]
}
```


```bash
% terraform init
% terraform plan
% terraform apply
(...)
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_s3_bucket.example: Creating...
aws_s3_bucket.example: Creation complete after 2s [id=my-unique-bucket-name-143-adf-ggads2245]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

# 결과
S3이동  
General purpose buckets->생성된 버킷 확인  

EC2이동  
생성된 인스턴스 확인  

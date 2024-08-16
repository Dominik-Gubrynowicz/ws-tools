data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  user_data = filebase64("userdata.yml")
  vpc_security_group_ids = [aws_security_group.security_group.id]
  subnet_id = var.subnet_id
  iam_instance_profile = var.role_name == null ? null : aws_iam_instance_profile.ec2_profile[0].name

  tags = {
    Name = "Jumphost server"
  }
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_security_group" "security_group" {
    name_prefix = "jumphost-sg"
    description = "Allow SSH traffic"
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_s3_bucket" "data_bucket" {
  bucket_prefix = "data-bucket"
  force_destroy = true
}

# Allow access from VPCE
resource "aws_s3_bucket_policy" "allow_vpce" {
    bucket = aws_s3_bucket.data_bucket.id
    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow",
                Principal = "*",
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:ListBucket",
                ],
                Resource = [
                    aws_s3_bucket.data_bucket.arn,
                    "${aws_s3_bucket.data_bucket.arn}/*",
                ],
                Condition = {
                    StringEquals = {
                        "aws:SourceVpce" = var.s3_vpce_id
                    }
                }
            }
        ]
    })
}

resource "aws_iam_instance_profile" "ec2_profile" {
    count = var.role_name == null ? 0 : 1
    name_prefix = "ec2_profile"
    role = var.role_name
}
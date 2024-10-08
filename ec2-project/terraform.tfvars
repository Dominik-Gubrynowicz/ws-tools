region = "eu-west-1"
app_name = "ws"
instance_type = "t3.micro"
app_port = 80
expose_port = 80
ami_id = "ami-0e58e277c7a0c9fdc"
max_number = 3
health_check_path = "/"
vpc_id = "vpc-05d68aa1a6a54fec2"
alb_subnet_ids = [ "subnet-060ab9c8fe321c484", "subnet-081f369c5147ffe5b" ]
app_subnet_ids = [ "subnet-01ae8988f0e995556", "subnet-07fd3c289310423c8" ]
role_name = "ws-role"
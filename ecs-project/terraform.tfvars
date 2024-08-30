region = "eu-west-1"
app_name = "root"
instance_type = "t3.micro"
app_port = 80
expose_port = 80
max_container_number = 10
max_instance_number = 3
health_check_path = "/"
vpc_id     = "vpc-05d68aa1a6a54fec2"
alb_subnet_ids = [ "subnet-0a121c8f5afddf443", "subnet-0359190be03579dcd"]
app_subnet_ids = [ "subnet-03d93d77f105fc591", "subnet-02d13a7d3cae4fcb7" ]
execution_task_role = "arn:aws:iam::997820552516:role/ws-task-execution"
task_role = "arn:aws:iam::997820552516:role/ws-task-execution"
ec2_role_name = "AmazonEC2ContainerServiceforEC2Role"
app_cpu = 256
app_memory = 512
image_url = "997820552516.dkr.ecr.eu-west-1.amazonaws.com/ws-repo:2"
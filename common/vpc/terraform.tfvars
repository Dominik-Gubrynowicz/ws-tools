vpc_id         = "vpc-05d68aa1a6a54fec2"
region         = "eu-west-1"
azs_number     = 2
public_subnets = true
private_subnets = [
  {
    name     = "private"
    internet = true
  },
  {
    name     = "data",
    internet = false
  }
]
gateway_endpoints = true
igw               = ""
custom_cidr       = "10.0.128.0/16"
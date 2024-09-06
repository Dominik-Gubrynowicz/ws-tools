#Poweshell script

# Create ssh key
ssh-keygen -t rsa -b 4096 -f id_rsa

$region = "us-east-1"
$subnet = "subnet-04fd67a27d2b40b4f"

# Get ubuntu ami from current region
$ami = & aws ec2 describe-images `
    --region $region `
    --owners 099720109477 `
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" `
    --query 'sort_by(Images, &CreationDate)[-1].ImageId' `
    --output text

echo $ami

# Remplace the region in the user-data.sh file powrshell
$keyPath = "id_rsa.pub"
$filePath = "user-data.sh"
$filePath2 = "data.sh"
$oldText = "SSH_PUBLIC_KEY"
$newText = Get-Content $keyPath

echo $newText

(Get-Content $filePath).Replace($oldText, $newText) | Set-Content $filePath2

# Create ec2 instance
aws ec2 run-instances `
    --image-id $ami `
    --count 1 `
    --instance-type t3.medium `
    --region $region `
    --subnet-id $subnet `
    --user-data file://$filePath2 `
    --associate-public-ip-address
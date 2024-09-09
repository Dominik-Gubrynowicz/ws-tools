#Poweshell script
$homedir = $env:USERPROFILE
# Create ssh directory if not exists
New-Item -Path "$homedir\.ssh" -ItemType Directory

# Create ssh key
ssh-keygen -t rsa -b 4096 -f "$homedir\.ssh\id_rsa"

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
$keyPath = "$homedir\.ssh\id_rsa.pub"
$filePath = "user-data.sh"
$filePath2 = "data.sh"
$oldText = "SSH_PUBLIC_KEY"
$newText = Get-Content $keyPath

(Get-Content $filePath).Replace($oldText, $newText) | Set-Content $filePath2

# Create ec2 instance
$instance_id = & aws ec2 run-instances `
    --image-id $ami `
    --count 1 `
    --instance-type t3.medium `
    --region $region `
    --subnet-id $subnet `
    --user-data file://$filePath2 `
    --associate-public-ip-address `
    --query 'Instances[0].InstanceId' `
    --output text

echo $instance_id

sleep 10

# Get public IP
$public_ip = & aws ec2 describe-instances `
    --instance-ids $instance_id `
    --query 'Reservations[0].Instances[0].PublicIpAddress' `
    --output text `
    --region $region



# Create .ssh config file with ssh configuration
New-Item $homedir\.ssh\config -ItemType File -Force -Value "Host $public_ip`n    User ubuntu`n    IdentityFile $home\.ssh\id_rsa"

ssh -N -f -L 8000:127.0.0.1:8000 ubuntu@public_ip
#!/bin/bash

echo "Creating EC2 for Flatris game..."

# Create security group
SG_ID=$(aws ec2 create-security-group \
    --group-name flatris-sg \
    --description "Security group for Flatris game" \
    --region ap-south-1 \
    --query 'GroupId' \
    --output text)

echo "Security Group ID: $SG_ID"

# Add rules
aws ec2 authorize-security-group-ingress \
    --group-name flatris-sg \
    --protocol tcp --port 22 --cidr 0.0.0.0/0 --region ap-south-1

aws ec2 authorize-security-group-ingress \
    --group-name flatris-sg \
    --protocol tcp --port 80 --cidr 0.0.0.0/0 --region ap-south-1

aws ec2 authorize-security-group-ingress \
    --group-name flatris-sg \
    --protocol tcp --port 443 --cidr 0.0.0.0/0 --region ap-south-1

# Create key pair
aws ec2 create-key-pair \
    --key-name flatris-key \
    --query 'KeyMaterial' \
    --output text > flatris-key.pem

chmod 400 flatris-key.pem

# Get Ubuntu AMI
AMI_ID=$(aws ec2 describe-images \
    --owners 099720109477 \
    --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*" \
    --query 'Images | sort_by(@, &CreationDate) | [-1].ImageId' \
    --output text \
    --region ap-south-1)

echo "Using AMI: $AMI_ID"

# Launch instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t2.micro \
    --key-name flatris-key \
    --security-group-ids $SG_ID \
    --region ap-south-1 \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=flatris-game}]' \
    --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=20,VolumeType=gp2}' \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Instance ID: $INSTANCE_ID"

# Wait for instance to run
echo "Waiting for instance to start..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region ap-south-1

# Get public IP
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text \
    --region ap-south-1)

echo "=========================================="
echo "EC2 Instance Created Successfully!"
echo "Public IP: $PUBLIC_IP"
echo "SSH Command: ssh -i flatris-key.pem ubuntu@$PUBLIC_IP"
echo "=========================================="

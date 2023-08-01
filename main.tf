# Create a VPC
resource "aws_vpc" "vpc-1" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-vpc"
  }
}

#Create a Subnet 
resource "aws_subnet" "vpc1-public-subnet" {
  vpc_id                  = aws_vpc.vpc-1.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "Public-Subnet"
  }
}

#Creating a Internet Gateway
resource "aws_internet_gateway" "public-gateway" {
  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "Public-Gateway"
  }
}

# Create Route Table and Route 
resource "aws_route_table" "public-rt" {

  vpc_id = aws_vpc.vpc-1.id

  tags = {
    Name = "public-subnet-rt"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public-gateway.id

}

#Create a connection between subnet and route table for traffic flowing 
resource "aws_route_table_association" "firstConnection" {
  subnet_id      = aws_subnet.vpc1-public-subnet.id
  route_table_id = aws_route_table.public-rt.id

}

#Create a Security Group 
resource "aws_security_group" "security-group" {
  name        = "terraform-sg"
  description = "Terraform Security Group"
  vpc_id      = aws_vpc.vpc-1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create a new key-value pair
resource "aws_key_pair" "terraform-auth" {
  key_name   = "new-keypair"
  public_key = file("~/.ssh/new-key.pub")

}

#Create a EC2 instance
resource "aws_instance" "server-instance" {
    ami = data.aws_ami.server-ami.id
    instance_type = "t2.micro"
    key_name = aws_key_pair.terraform-auth.key_name
    vpc_security_group_ids = [aws_vpc.vpc-1.default_security_group_id]
    subnet_id = aws_subnet.vpc1-public-subnet.id

    tags = {
      Name = "server-terraform"
    }
    
}
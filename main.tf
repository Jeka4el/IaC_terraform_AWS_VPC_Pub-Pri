# export AWS_ACCESS_KEY_ID="myAKI"
# export AWS_SECRET_ACCESS_KEY="mySAK"
# export AWS_DEFAULT_REGION="eu-west-3"


#Создал глобальную VPC , в ней будет две посети Public, Private
resource "aws_vpc" "global-vpc" {
     cidr_block = "10.0.0.0/16"
      tags = {
        Name = "global-NET"
  }
}
# Привязываю подсеть. 
resource "aws_subnet" "front-end-net" {
  vpc_id     = aws_vpc.global-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public-net"
  }
}
# Привязываю подсеть. 
resource "aws_subnet" "back-end-net" {
  vpc_id     = aws_vpc.global-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Private-net"
  }
}

# Created internet_gateway
resource "aws_internet_gateway" "global-GW" {
  vpc_id = aws_vpc.global-vpc.id

  tags = {
    Name = "Global-GW"
  }
}

# Created route_table
resource "aws_route_table" "global-RT" {
  vpc_id = aws_vpc.global-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.global-GW.id
  } 

  tags = {
    Name = "global-RT-Front"
  }
}

# Made subnet association

resource "aws_route_table_association" "a-front-net" {
  subnet_id      = aws_subnet.front-end-net.id
  route_table_id = aws_route_table.global-RT.id
}

# Created security_group ssh and web

resource "aws_security_group" "global-sg" {
  name        = "ssh-web"
  description = "Allow 22 and 80 ports traffic"
  vpc_id      = aws_vpc.global-vpc.id

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "WEB from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh-web-sg"
  }
}

# Find last wersion ubuntu  

data "aws_ami" "ubuntu-latest" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical 
}

# Added IC2 instance

resource "aws_instance" "web-server" {
  ami           = data.aws_ami.ubuntu-latest.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.front-end-net.id
  vpc_security_group_ids = [aws_security_group.global-sg.id]
  associate_public_ip_address = true

  key_name = "terraform"
  
 
  tags = {
    Name = "web-server"
  }
}

# Логинюсь в AWS , кдючи нужно спрятать в переменные.  
provider "aws" {
  region     = "eu-west-3"
  access_key = "AKIXXXXXXXXXXXXXXX"
  secret_key = "3AkQwFI8w6XsICuxxxxxxxxxxxxxx"
}

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

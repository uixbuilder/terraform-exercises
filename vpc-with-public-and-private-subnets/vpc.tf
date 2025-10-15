terraform {
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
}

resource "aws_vpc" "gen-demo-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "Terraform Auto VPC"
    }
}

resource "aws_subnet" "gen-public-subnet" {
    vpc_id            = aws_vpc.gen-demo-vpc.id
    cidr_block        = "10.0.0.0/24"
    tags = {
        Name = "Terraform Public Subnet"
    }
}

resource "aws_subnet" "get-private-subnet" {
    vpc_id            = aws_vpc.gen-demo-vpc.id
    cidr_block        = "10.0.1.0/24"
    tags = {
        Name = "Terraform Private Subnet"
    }
}

resource "aws_internet_gateway" "gen-igw" {
    vpc_id = aws_vpc.gen-demo-vpc.id
    tags = {
        Name = "Terraform IGW"
    }
}

resource "aws_route_table" "get-public-rtb" {
    vpc_id = aws_vpc.gen-demo-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gen-igw.id
    }
    tags = {
        Name = "Terraform Public RTB"
    }
}

resource "aws_route_table_association" "gen-public-subnet" {
    subnet_id      = aws_subnet.gen-public-subnet.id
    route_table_id = aws_route_table.get-public-rtb.id
}

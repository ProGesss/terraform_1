provider "aws" {
  profile    = "customprofile"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

resource "aws_vpc" "AWS_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "AWS_vpc"
  }
}

resource "aws_security_group" "allow_ssh" {
  name          = "allow_ssh"
  description   = "Allow SSH-ICMP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_web" {
  name          = "allow_web"
  description   = "Allow HTTP-HTTPS ingress traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "public_subnet_A" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.public_subnet_A
  map_public_ip_on_launch = true
  availability_zone_id    = var.PB_AV_zone_A
  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public_subnet_B" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.public_subnet_B
  map_public_ip_on_launch = true
  availability_zone_id    = var.PB_AV_zone_B
  tags = {
    Name = "Public Subnet B"
  }
}

resource "aws_subnet" "private_subnet_A" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.private_subnet_A
  availability_zone_id    = var.PR_AV_zone_A
  tags = {
    Name = "Private Subnet A"
  }

}

resource "aws_subnet" "private_subnet_B" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.private_subnet_B
  availability_zone_id    = var.PR_AV_zone_B
  tags = {
    Name = "Private Subnet B"
  }
}

resource "aws_subnet" "db_subnet_A" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.db_subnet_A
  availability_zone_id    = var.DB_AV_zone_A
  tags = {
    Name = "DB Subnet A"
  }
}

resource "aws_subnet" "db_subnet_B" {
  vpc_id                  = aws_vpc.AWS_vpc.id
  cidr_block              = var.db_subnet_B
  availability_zone_id    = var.DB_AV_zone_B
  tags = {
    Name = "DB Subnet B"
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id         = aws_vpc.AWS_vpc.id
  tags = {
    Name = "AWS IGW"
  }
}

resource "aws_eip" "eip_A" {
  vpc = true
  tags = {
    Name = "EIP A"
  }
}

resource "aws_eip" "eip_B" {
  vpc = true
  tags = {
    Name = "EIP B"
  }
}

resource "aws_nat_gateway" "nat_A" {
  subnet_id     = aws_subnet.db_subnet_A.id
  allocation_id = aws_eip.eip_A.id
  tags = {
    Name = "NAT A"
  }
}

resource "aws_nat_gateway" "nat_B" {
  subnet_id     = aws_subnet.db_subnet_B.id
  allocation_id = aws_eip.eip_B.id
  tags = {
    Name = "NAT B"
  }
}

resource "aws_route_table" "rt_PUB" {
  vpc_id        = aws_vpc.AWS_vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.aws_igw.id
  }
  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "rta_PUB_A" {
  subnet_id      = aws_subnet.public_subnet_A.id
  route_table_id = aws_route_table.rt_PUB.id
}

resource "aws_route_table_association" "rta_PUB_B" {
  subnet_id      = aws_subnet.public_subnet_B.id
  route_table_id = aws_route_table.rt_PUB.id
}

resource "aws_route_table" "rt_private_A" {
  vpc_id = aws_vpc.AWS_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_A.id
  }
  tags = {
    Name = "Private Route Table A"
  }
}

resource "aws_route_table_association" "rta_private_A" {
  subnet_id      = aws_subnet.private_subnet_A.id
  route_table_id = aws_route_table.rt_private_A.id
}

resource "aws_route_table" "rt_private_B" {
  vpc_id = aws_vpc.AWS_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_B.id
  }
  tags = {
    Name = "Private Route Table A"
  }
}

resource "aws_route_table_association" "rta_private_B" {
  subnet_id      = aws_subnet.private_subnet_B.id
  route_table_id = aws_route_table.rt_private_B.id
}

## Bastion Host from module 

module "bastion" {
  source            = "./bastion"  
  subnet_id         = aws_subnet.public.id
  ssh_key           = "ssh_key_name"
  allowed_hosts     = ["11.22.33.44/32", "99.88.77.66/24"]
  internal_networks = ["10.0.10.0/24", module.vpc.subnet_internal1_cidr_block]
  disk_size         = 10
  instance_type     = "t2.micro"
  project           = "myProject"
}

## Example Hosts

resource "aws_key_pair" "terraform-demo" {
  key_name   = "terraform-demo"
  public_key = "${file("terraform-demo.pub")}"
}

resource "aws_instance" "my-demo-webinstance" {
	ami                    = "ami-04169656fea786776"
  count                  = 3
	instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id, aws_security_group.allow_web.id]
	key_name               = "${aws_key_pair.terraform-demo.key_name}"
	user_data              = "${file("install_apache.tpl")}"
	tags = {
		Name = "Terraform Webserver"	
		Batch = "5AM"
	}
}
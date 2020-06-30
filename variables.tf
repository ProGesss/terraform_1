#### AWS Creds

variable "aws_access_key" {
  type = string
  description = "AWS access key"
}
variable "aws_secret_key" {
  type = string
  description = "AWS secret key"
}
variable "aws_region" {
  type = string
  description = "AWS region"
}

#### VPC Network
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

#### Public Subnet A
variable "public_subnet_A" {
  default = "10.0.10.0/24"
}
variable "PB_AV_zone_A" {
  default = "euw1-az1"
}

#### Public Subnet B
variable "public_subnet_B" {
  default = "10.0.20.0/24"
}
variable "PB_AV_zone_B" {
  default = "euw1-az2"
}

#### Private Subnet A
variable "private_subnet_A" {
  default = "10.0.11.0/24"
}
variable "PR_AV_zone_A" {
  default = "euw1-az2"
}
#### Private Subnet B
variable "private_subnet_B" {
  default = "10.0.21.0/24"
}
variable "PR_AV_zone_B" {
  default = "euw1-az2"
}
#### DB Subnet A
variable "db_subnet_A" {
  default = "10.0.12.0/24"
}
variable "DB_AV_zone_A" {
  default = "euw1-az2"
}
#### DB Subnet B
variable "db_subnet_B" {
  default = "10.0.22.0/24"
}
variable "DB_AV_zone_B" {
  default = "euw1-az2"
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "zah-terraform"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  name     = "zah-vpc"
  region   = "eu-west-2"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]

  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_ipv6                                   = true
  public_subnet_assign_ipv6_address_on_creation = true

  public_subnet_ipv6_prefixes   = [0, 1, 2]
  private_subnet_ipv6_prefixes  = [3, 4, 5]
  database_subnet_ipv6_prefixes = [6, 7, 8]

  enable_nat_gateway = false
}

module "webserver_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "webserver"
  description = "Security group for the zah webserver"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_ipv6_cidr_blocks = ["::/0"]
  ingress_rules            = ["https-443-tcp", "http-80-tcp", "ssh-tcp"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_ipv6_cidr_blocks  = ["::/0"]
  egress_rules             = ["all-all"]
}

module "webserver_ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name   = "zahws"
  ami    = "ami-0b9932f4918a00c4f"

  availability_zone      = element(local.azs, 0)
  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [module.webserver_security_group.security_group_id]

  instance_type = "t2.micro"

  root_block_device = [
    {
      encrypted   = false
      volume_type = "gp2"
      volume_size = 12
    },
  ]
}

module "zah_bucket" {
  source           = "terraform-aws-modules/s3-bucket/aws"
  bucket           = "zah-storage"
  object_ownership = "BucketOwnerEnforced"

}

resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = element(module.vpc.public_subnets, 0)
  security_group_ids = [module.webserver_security_group.security_group_id]
}

resource "aws_key_pair" "omar" {
  key_name   = "omar-local"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDXBx2MUZYqIbpZWbOwfWEwAuM5J+hVC/unk7gLbYArl44v/CcY6JkWb4DMGN4XXk3dsRLHaIRtcci6d5z5g7opWB43lae/F/ucDRsF0y1hDwqgz9+ZVgvidET1wTe+x68/tLhdx78KofMhV9LI23uQHITYtdc8dhfYD5vInjV4ShhckSU3FVAQSwtJYM5gsAwzR5QbfXDeggamm/NQCFmYu66ShoXZKui1rPYTOK/NMzMUlw9dAafmJcvwUvs95FvAMFANOoZBi0Um7gfIY8OA4WMXFkXo3G0/NYPzt3iXAt61GTs/zJlZODeKYGCy8ZbwyxUcrAKgk9BRF/teaHZjnFhif9RsQ79nK0TK5L0CjsobYGYDK5cgXeATUkF1DVmr5kXHHlWoea1/Cr9u3WuiKv/0/mSgIm5g/R0FTkddJb9mlb/RnsW5FKrwanjMtOLsU8AskQCP2kWwurUU2TyvBWgPOf+25mxva9kuyEhKcFwdwbN+OmCqyirJN28c0l8= omar@omar-ubuntu"
}

resource "cloudflare_zone" "zah" {
  account_id = "c481cd0068116b3efb7c163c8d2a0b38"
  zone       = "zah.org.uk"
}

resource "cloudflare_record" "zah" {
  zone_id = cloudflare_zone.zah.id
  name    = "zah.org.uk"
  type    = "AAAA"
  proxied = true
  value   = module.webserver_ec2_instance.ipv6_addresses[0]
}

resource "cloudflare_record" "socket" {
  zone_id = cloudflare_zone.zah.id
  name    = "socket"
  type    = "AAAA"
  proxied = true
  value   = module.webserver_ec2_instance.ipv6_addresses[0]
}

resource "cloudflare_record" "www" {
  zone_id = cloudflare_zone.zah.id
  name    = "www"
  type    = "AAAA"
  proxied = true
  value   = module.webserver_ec2_instance.ipv6_addresses[0]
}

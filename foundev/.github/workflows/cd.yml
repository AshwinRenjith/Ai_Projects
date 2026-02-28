5. Let's create the Terraform configuration files:

```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "foundev-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}

provider "aws" {
  region = "ap-south-1"
}

# EKS Cluster
resource "aws_eks_cluster" "foundev" {
  name     = "foundev-cluster"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# RDS PostgreSQL
resource "aws_db_instance" "foundev_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "13.4"
  instance_class       = "db.t3.medium"
  name                 = "foundevdb"
  username             = "foundevadmin"
  password             = var.db_password
  parameter_group_name = "default.postgres13"
  skip_final_snapshot  = true
  storage_encrypted    = true
}

# Redis ElastiCache
resource "aws_elasticache_cluster" "foundev_redis" {
  cluster_id           = "foundev-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  engine_version       = "6.x"
  port                 = 6379
}

# S3 Bucket for images
resource "aws_s3_bucket" "foundev_images" {
  bucket = "foundev-images"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
```
```hcl
# outputs.tf
output "eks_cluster_endpoint" {
  value = aws_eks_cluster.foundev.endpoint
}

output "eks_cluster_certificate_authority" {
  value = aws_eks_cluster.foundev.certificate_authority[0].data
}

output "rds_endpoint" {
  value = aws_db_instance.foundev_db.endpoint
}

output "redis_endpoint" {
  value = aws_elasticache_cluster.foundev_redis.cache_nodes[0].address
}

output "s3_bucket_name" {
  value = aws_s3_bucket.foundev_images.bucket
}
```
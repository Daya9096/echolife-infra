output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API Endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "EKS Version"
  value       = module.eks.cluster_version
}

output "public_subnets" {
  description = "Public Subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnets" {
  description = "Private App Subnet IDs"
  value       = module.vpc.private_app_subnet_ids
}

output "private_data_subnets" {
  description = "Private Data Subnet IDs"
  value       = module.vpc.private_data_subnet_ids

}
output "eks_node_security_group_id" {
  description = "EKS worker node security group ID"
  value       = module.vpc.eks_node_security_group_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.vpc.alb_security_group_id
}

output "oidc_provider_arn" {
  description = "OIDC Provider ARN"
  value       = module.eks.oidc_provider_arn
}

output "oidc_provider_url" {
  description = "OIDC Provider URL"
  value       = module.eks.oidc_provider_url
}

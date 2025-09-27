# main.tf: Terraform configuration for AWS EKS Cluster

# Note: This requires the AWS provider to be configured and the VPC module 
# (or custom VPC resources) to be set up beforehand.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# -----------------
# 1. EKS CLUSTER
# -----------------

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.1.0" 

  cluster_name    = "gitops-prod-cluster"
  cluster_version = "1.28"

  # Replace with your actual VPC details
  vpc_id     = "vpc-00692c8395a9054f8"
  subnet_ids = ["subnet-0e05c0dde859f64a7"]

  # EKS Managed Node Group
  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 2
      desired_size = 1
      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
    }
  }

  # Add ability for IAM users/roles to interact with the cluster (ArgoCD will need this)
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::187899929694:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS"
      username = "argocd-manager"
      groups   = ["system:masters"]
    }
  ]

  # Enables public endpoint access for easy setup, restrict as needed in production
  cluster_endpoint_public_access = true 
}

output "kubeconfig" {
  value       = module.eks.kubeconfig
  sensitive   = true
  description = "EKS kubeconfig file content"
}

output "cluster_endpoint" {
  value       = module.eks.cluster_endpoint
}


# EKS cluster creation

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

data "aws_caller_identity" "current" {}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "19.15.3"
  cluster_name                    = "${var.environment}-cluster"
  cluster_version                 = 1.27
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false
  vpc_id                          = module.network.vpc_id
  subnet_ids                      = module.network.vpc_public_subnets
  enable_irsa                     = true


  eks_managed_node_group_defaults = {
    ami_type               = "AL2_x86_64"
    disk_size              = 20
    instance_types         = ["t3.small"]
    vpc_security_group_ids = []
  }

  eks_managed_node_groups = {
    ng-default = {

      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      # Remote access cannot be specified with a launch template
      remote_access = {
        ec2_ssh_key = aws_key_pair.private.id
      }

      desired_size = 1
      max_size     = 3
      min_size     = 1

      subnet_ids = module.network.vpc_public_subnets

      capacity_type = "ON_DEMAND"

    }

  }
}

# IRSA for cluster

module "aws_load_balancer_controller" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "aws_load_balancer_controller-${module.eks.cluster_name}"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

}

module "cluster_autoscaler" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "cluster-autoscaler-${module.eks.cluster_name}"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

}


module "external_secrets" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                      = "external_secrets-${module.eks.cluster_name}"
  attach_external_secrets_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-secrets"]
    }
  }

}

# Subnets tags are required for ALB discovery

resource "aws_ec2_tag" "public_subnet_cluster_tag" {
  count = length(module.network.vpc_public_subnets)
  resource_id = module.network.vpc_public_subnets[count.index]
  key         = "kubernetes.io/cluster/${var.environment}-cluster"
  value       = "shared"

  depends_on = [module.network]
}

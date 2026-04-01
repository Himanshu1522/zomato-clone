provider "aws" {
  region = "eu-west-1"
}


terraform {
  backend "s3" {
    bucket         = "application-deploy-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    use_lockfile   = false
    dynamodb_table = "application-deploy-tfstate-lock"
    encrypt        = true
  }
}

locals {
  name                  = "application-deploy"
  region                = "eu-west-1"
  vpc_cidr_block        = module.vpc.vpc_cidr_block
  additional_cidr_block = "172.16.0.0/16"
  environment           = "test"
  label_order           = ["name", "environment"]
   shared_vpc_cidr = "10.10.0.0/16"
}

################################################################################
# VPC module call
################################################################################
module "vpc" {
  source  = "./modules/vpc"
  name        = "${local.name}-vpc"
  environment = local.environment
  cidr_block  = "10.10.0.0/16"
}
# ################################################################################
# # Subnets moudle call
# ################################################################################
module "subnets" {
  source  = "./modules/subnets"
  name                = "${local.name}-subnet"
  environment         = local.environment
  nat_gateway_enabled = true
  single_nat_gateway  = true
  availability_zones  = ["${local.region}a", "${local.region}b"]
  vpc_id              = module.vpc.vpc_id
  type                = "public-private"
  igw_id              = module.vpc.igw_id
  cidr_block          = local.vpc_cidr_block
  ipv6_cidr_block     = module.vpc.ipv6_cidr_block
  enable_ipv6         = false
  extra_public_tags = {
    "kubernetes.io/role/elb"                           = "1"
  }
  extra_private_tags = {
    "kubernetes.io/role/internal-elb"                  = "1"
  }
  public_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
  private_inbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number     = 101
      rule_action     = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
  ]
}
# ################################################################################
# Security Groups module call
################################################################################
module "ssh" {
  source  = "./modules/security-group"
  name        = "${local.name}-ssh"
  environment = local.environment
  vpc_id      = module.vpc.vpc_id
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = [local.additional_cidr_block]
      description = "Allow Mongodb traffic."
    }
  ]
  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block, local.additional_cidr_block]
    description = "Allow ssh outbound traffic."
    },
    {
      rule_count  = 2
      from_port   = 27017
      protocol    = "tcp"
      to_port     = 27017
      cidr_blocks = [local.additional_cidr_block]
      description = "Allow Mongodb outbound traffic."
  }]
}
module "http_https" {
  source  = "./modules/security-group"
  name        = "${local.name}-http-https"
  environment = local.environment
  vpc_id = module.vpc.vpc_id
  ## INGRESS Rules
  new_sg_ingress_rules_with_cidr_blocks = [{
    rule_count  = 1
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = [local.vpc_cidr_block]
    description = "Allow ssh traffic."
    },
    {
      rule_count  = 2
      from_port   = 80
      protocol    = "tcp"
      to_port     = 80
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow http traffic."
    },
    {
      rule_count  = 3
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
      cidr_blocks = [local.vpc_cidr_block]
      description = "Allow https traffic."
    },
    {
      rule_count  = 4
      from_port   = 5002
      protocol    = "tcp"
      to_port     = 5002
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow public app traffic (Flask)."
    }
  ]
  ## EGRESS Rules
  new_sg_egress_rules_with_cidr_blocks = [{
    rule_count       = 1
    from_port        = 0
    protocol         = "-1"
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow all traffic."
    }
  ]
}
################################################################################
# KMS Module call
################################################################################
module "kms" {
  source  = "./modules/kms"
  name                = "${local.name}-kms"
  environment         = local.environment
  label_order         = local.label_order
  enabled             = true
  description         = "KMS key for EBS of EKS nodes"
  enable_key_rotation = false
  policy              = data.aws_iam_policy_document.kms.json
}
data "aws_iam_policy_document" "kms" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}
data "aws_caller_identity" "current" {}


module "eks" {
  source  = "./modules/eks"


  name        = "${local.name}-eks"
  environment = local.environment
  label_order = local.label_order
  enabled     = true

  # Self Managed Addons
  addons = []

  # EKS
  kubernetes_version     = "1.31"
  endpoint_public_access = true

  vpc_id                            = module.vpc.vpc_id
  subnet_ids                        = module.subnets.private_subnet_id
  allowed_cidr_blocks               = [local.shared_vpc_cidr]

  # AWS Managed Node Group
  # Default Values for all Node Groups
  managed_node_group_defaults = {
    subnet_ids = module.subnets.private_subnet_id
    tags = {
      "kubernetes.io/cluster/${module.eks.cluster_name}" = "owned"
      "k8s.io/cluster/${module.eks.cluster_name}"        = "owned"
    }
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 80
          volume_type = "gp3"
          iops        = 3000
          throughput  = 150
        }
      }
    }
  }
  managed_node_group = {
    critical = {
      name                 = "worker"
      capacity_type        = "ON_DEMAND"
      min_size             = 1
      max_size             = 1
      desired_size         = 1
      force_update_version = true
      ami_type             = "AL2_x86_64"
      instance_types       = ["t3.medium"]
    }
   
  }
  apply_config_map_aws_auth = true
  map_additional_iam_users = [
    {
      userarn  = "arn:aws:iam::7886XXXXXXXX:user/lavanya"
      username = "lavanya_sharma"
      groups   = ["system:masters"]
    }
  
  ]
  map_additional_iam_roles = [
    {
      rolearn  = "arn:aws:iam::78864XXXXXXX:role/GitHubOIDCRole"
      username = "github-oidc-role"
      groups   = ["system:masters"]
    }
  ]
}

data "aws_eks_cluster" "eks_cluster" {
  # this makes downstream resources wait for data plane to be ready
  name = module.eks.cluster_name
  depends_on = [
    module.eks.cluster_id
  ]
}

module "addons" {
  source = "./modules/addons"

  depends_on       = [module.eks]
  eks_cluster_name = module.eks.cluster_name

  # -- Enable Addons
  metrics_server               = true
  metrics_server_helm_config                     = { values = [file("./config/override-metrics-server.yaml")] }
  metrics_server_extra_configs = var.metrics_server_extra_configs
  cluster_autoscaler           = true
  cluster_autoscaler_helm_config                = { values = [file("./config/cluster-autoscaler/override-cluster-autoscaler.yaml")] }
  cluster_autoscaler_extra_configs = var.cluster_autoscaler_extra_configs

  # aws_node_termination_handler   = true
  # aws_node_termination_handler_helm_config              = { values = [file("./config/override-aws-node-termination-handler.yaml")] }
  # aws_node_termination_handler_extra_configs = var.aws_node_termination_handler_extra_configs

  aws_load_balancer_controller           = true
  aws_load_balancer_controller_helm_config = { values = [file("./config/alb-controller/override-aws-load-balancer-controller.yaml")] }
  # aws_load_balancer_controller_extra_configs = var.aws_load_balancer_controller_extra_configs


  # Custom IAM Policies for addons
  aws_load_balancer_controller_iampolicy_json_content = file("./config/alb-controller/iam-policy.json")
  cluster_autoscaler_iampolicy_json_content           = file("./config/cluster-autoscaler/iam-policy.json")

}

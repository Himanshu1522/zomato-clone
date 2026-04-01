variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "application-deploy"
}

variable "nat_gateway_enabled" {
  description = "Flag to enable or disable NAT Gateway"
  type        = bool
  default     = true
}
variable "metrics_server_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default = {
    version = "3.12.1"
    name = "metrics-server"
    namespace = "kube-system"
  }
}
variable "cluster_autoscaler_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default = {
    version = "9.37.0"
    name    = "autoscaler"
    namespace = "kube-system"
  }
}

variable "aws_load_balancer_controller_extra_configs" {
  description = "Override attributes of helm_release terraform resource"
  type        = any
  default = {
    version = "1.8.2"
    name = "alb-controller"
    namespace = "kube-system"
  }
}
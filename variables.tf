#-----------------------------------
# General variables
#-----------------------------------
variable "region" {
  description = "The AWS region to deploy resources."
  default     = "eu-west-1"
  type        = string
  validation {
    condition     = startswith(var.region, "eu-")
    error_message = "The region must be in Europe"
  }

}

variable "name" {
  description = "The name of the application."
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "Variable name must be a string, and cannot be empty."
  }
}

variable "environment" {
  description = "The environment to deploy the application."
  type        = string
  default     = "prod"
  validation {
    condition     = can(regex("^(dev|tst|stg|prod)$", var.environment))
    error_message = "The environment must be dev, tst, stg, or prod."
  }
}

variable "aws_account_id" {
  description = "The AWS account ID."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "The account ID must be a 12-digit number."
  }
}

#-----------------------------------
# VPC variables
#-----------------------------------
variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  validation {
    condition     = can(cidrnetmask(var.cidr_block))
    error_message = "The CIDR block must be a valid IPv4 address range."
  }

}

variable "az_count" {
  default     = 3
  description = "The number of availability zones to use."
  type        = number
  validation {
    condition     = var.az_count > 0 && var.az_count <= 3
    error_message = "The number of availability zones must be between 1 and 3."
  }
}

#-----------------------------------
# EKS variables
#-----------------------------------
variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
  default     = "eks-cluster"
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "The cluster name must be a string, and cannot be empty."
  }
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.29`)"
  type        = string
  default     = "1.29"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.cluster_version))
    error_message = "The cluster version must be in the format `<major>.<minor>`."
  }
}

variable "instance_types" {
  type        = list(string)
  description = "The instance type of the EKS cluster nodes."
  default     = ["t3.large"]

  validation {
    condition     = alltrue([for it in var.instance_types : contains(["t3.large", "t3.xlarge", "t3.2xlarge"], it)])
    error_message = "Each instance type must be one of 't3.large', 't3.xlarge', or 't3.2xlarge'."
  }
}

variable "disk_size" {
  type        = number
  description = "The disk size of the EKS cluster nodes."
  default     = 80
  validation {
    condition     = contains([40, 80, 100], var.disk_size)
    error_message = "The disk size must be greater than 0."
  }
}

variable "node_count" {
  type        = number
  description = "The number of nodes in the EKS cluster."
  default     = 3
  validation {
    condition     = var.node_count > 0
    error_message = "The number of nodes must be greater than 0."
  }
}

variable "node_count_max" {
  type        = number
  description = "The maximum number of nodes in the EKS cluster."
  default     = 6
  validation {
    condition     = var.node_count_max > 0
    error_message = "The maximum number of nodes must be greater than node_count."
  }
}

variable "node_count_min" {
  type        = number
  description = "The minimum number of nodes in the EKS cluster."
  default     = 1
  validation {
    condition     = var.node_count_min >= 0
    error_message = "The minimum number of nodes must be less than node_count."
  }
}

variable "ami_type" {
  type        = string
  description = "The AMI type of the EKS cluster nodes."
  default     = "AL2_x86_64"
  validation {
    condition     = can(regex("^(AL2_x86_64|AL2_x86_64_GPU)$", var.ami_type))
    error_message = "The AMI type must be 'AL2_x86_64' or 'AL2_x86_64_GPU'."
  }
}

variable "coredns_version" {
  type        = string
  description = "The version of the CoreDNS addon to install."
  default     = "v1.11.1-eksbuild.4"
  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+-eksbuild\\.[0-9]+$", var.coredns_version))
    error_message = "The CoreDNS version must be in the format 'v<version>-eksbuild.<build>'."
  }
}

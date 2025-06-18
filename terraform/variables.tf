variable "aws_region" {
  type        = string
  default     = "ap-northeast-2"
}

variable "vpc_id" {
  type        = string
  default     = "vpc-0e8b9d656cd35eeba"
}

variable "public_subnet_ids" {
  type        = list(string)
  default     = [
    "subnet-0c15c864842495f5b",
    "subnet-0f55ba631a25a3410",
  ]
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = [
    "subnet-0bf35f6d79bb54981",
    "subnet-053be3900bfe812a1",
  ]
}

variable "cluster_name" {
  type    = string
  default = "terraform-eks"
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "node_group_min" {
  type    = number
  default = 4
}

variable "node_group_max" {
  type    = number
  default = 5
}

variable "node_group_desired" {
  type    = number
  default = 4
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}


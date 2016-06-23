variable "access_key" {
  description = "The AWS access key."
}

variable "secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "availability_zone" {
  description = "The availability zone"
  default = "us-east-1b"
}

variable "ecs_cluster_name" {
  description = "The name of the Amazon ECS cluster."
  default = "jenkins"
}

variable "amis" {
  description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
  default = {
    us-east-1 = "ami-8f7687e2"
    us-west-1 = "ami-bb473cdb"
    us-west-2 = "ami-84b44de4"
    eu-west-1 = "ami-4e6ffe3d"
    eu-central-1 = "ami-b0cc23df"
    ap-northeast-1 = "ami-095dbf68"
    ap-southeast-1 = "ami-cf03d2ac"
    ap-southeast-2 = "ami-697a540a"
  }
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  default = "devops-tf"
  description = "SSH key name in your AWS account for AWS instances."
}

variable "min_instance_size" {
  default = 1
  description = "Minimum number of EC2 instances."
}

variable "max_instance_size" {
  default = 2
  description = "Maximum number of EC2 instances."
}

variable "desired_instance_capacity" {
  default = 1
  description = "Desired number of EC2 instances."
}

variable "desired_service_count" {
  default = 1
  description = "Desired number of ECS services."
}

variable "s3_bucket" {
  default = "mycompany-jenkins"
  description = "S3 bucket where remote state and Jenkins data will be stored."
}

variable "restore_backup" {
  default = false
  description = "Whether or not to restore Jenkins backup."
}

variable "jenkins_repository_url" {
  default = "jenkins"
  description = "ECR Repository for Jenkins."
}

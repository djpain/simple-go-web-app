variable "environ" {
  default = "dev"
}

variable "appname" {
  default = "simple-go-web-app"
}

variable "azs" {
  default = ["ap-southeast-2a", "ap-southeast-2b"]
}

variable "public_subnets" {
  default = ["10.100.101.0/24", "10.100.102.0/24"]
}

variable "cidr" {
  default = "10.100.0.0/16"
}

variable "privateip" {
  default = ["114.76.212.230/32"]
}

variable "host_port" {
  default = 8080
}

variable "docker_port" {
  default = 8080
}

variable "lb_port" {
  default = 80
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "key_name" {}

variable "dockerimg" {}

# From https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html
variable "ami" {
  description = "AWS ECS AMI id"
  default = "ami-0d28e5e0f13248294"
}

variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type = string
  default = "ap-south-1"
}
variable "pub-count" {
  description = "Number of public subnet"
  default     = "3"
}
variable "db_count" {
  description = "Number of private db subnets"
  default     = "2"
}
variable "env" {
  default = "demo"
}
variable "priv-count" {
  description = "Number of private subnet"
  default     = "3"
}
variable "cidr-block" {
  default = "172.17.0.0/16"
}
variable "environment" {
  default = "demo"
}


variable "environment" {}
variable "region" {}
variable "alarm_actions" {
  type    = list
  default = ["arn:aws:sns:us-east-1:083052042026:HealthCheck"]
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
  default     = "ami-060a84cbcb5c14844"
}
variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t2.micro"

}

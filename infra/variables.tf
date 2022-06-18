variable "region" {
  type = string
  default = "ap-south-1"
}

variable "nodes" {
  default = "3"
}

variable "ami" {
  default = "ami-096b9cd38d837f984"
}

variable "keypair" {
  default = "totem-deployer"
}

variable "instance_name" {
  default = "datanode"
}

variable "vmagent_instances" {
  default = 1
}


output "datanode-instance_ips" {
  value = aws_instance.datanode.*.public_ip
}

output "vmagent-instance_ip" {
  value = aws_instance.vmagent.*.public_ip
}

output "vmagent-sd-role-arn" {
  value = aws_iam_role.vmagent-sd-role.arn
}

output "ec2-trustee-role-arn" {
  value = aws_iam_role.ec2-trustee.arn
}

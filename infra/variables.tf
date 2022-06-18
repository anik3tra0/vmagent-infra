variable "instance_count" {
  default = "3"
}

variable "instance_name" {
  default = "datanode"
}


output "datanode-instance_ips" {
  value = aws_instance.datanode.*.public_ip
}

output "vmagent-instance_ip" {
  value = aws_instance.vmagent.public_ip
}

output "vmagent-sd-role-arn" {
  value = aws_iam_role.vmagent-sd-role.arn
}

output "ec2-trustee-role-arn" {
  value = aws_iam_role.ec2-trustee.arn
}

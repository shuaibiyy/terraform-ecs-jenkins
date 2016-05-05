output "aws_instances_external" {
  value = "[ ${aws_elb.jenkins-elb.dns_name} ]"
}

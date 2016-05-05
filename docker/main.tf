resource "aws_ecr_repository" "jenkins" {
  name = "${var.image_name}"
  provisioner "local-exec" {
    command = "./deploy-image.sh ${self.repository_url} ${var.jenkins_image_name}"
  }
}

variable "jenkins_image_name" {
  default = "mycompany/jenkins"
  description = "Jenkins image name."
}

# ecs-jenkins

This repo contains a [Terraform](https://terraform.io/) module for provisioning a Jenkins server in an [AWS ECS](https://aws.amazon.com/ecs/) cluster.

It also contains Terraform configuration scripts for building and provisioning a Jenkins image in [AWS ECR](https://aws.amazon.com/ecr/).

It is well-suited to be used together with [Amazon EC2 Container Service Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Amazon+EC2+Container+Service+Plugin).

## Usage

To provision a Jenkins image in ECR:

1. `cd` into `docker` directory.
2. Modify `plugins.txt` to your liking.
3. Run `terraform apply`.

To provision Jenkins in ECS:

Run `terraform apply` from the project's root directory.

If you don't want to be prompted your AWS access key and secret access key, you can add the their values to a `terraform.tfvars` file or run the setup using:
```bash
terraform apply -var 'aws_access_key={your_aws_access_key}' \
   -var 'aws_secret_key={your_aws_secret_key}'
```

You will probably want to update the values of variables such as Jenkins ECR repository URL and EC2 instance keypair name in `variables.tf`.

If you provisioned the Jenkins image in ECR, the repository URL would look like: `<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/<jenkins_image_name>:latest`.

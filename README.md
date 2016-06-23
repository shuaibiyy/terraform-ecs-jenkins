# ECS-Powered Jenkins

This repo contains a [Terraform](https://terraform.io/) module for provisioning a Jenkins 2.0 server in an [AWS ECS](https://aws.amazon.com/ecs/) cluster. Jenkins on ECS can be used to achieve a scalable and cost-efficient CI workflow when coupled with the [Jenkins ECS plugin](https://wiki.jenkins-ci.org/display/JENKINS/Amazon+EC2+Container+Service+Plugin) as described in this [blog post](https://shuaib.me/ecs-jenkins/).

It also contains a Terraform configuration for building and provisioning a Jenkins image in [AWS ECR](https://aws.amazon.com/ecr/).

The terraform script stores the terraform state remotely in an S3 bucket. The Makefile by default sets up a copy of the remote state if it doesn’t exist and then runs either `terraform plan` or `terraform apply` depending on the target.

## Usage

### Provision Jenkins in ECS

Run `make apply` from the project's root directory.

Before you run the Makefile, you should set the following environment variables to authenticate with AWS:
```
$ export AWS_ACCESS_KEY_ID= <your key> # to store and retrieve the remote state in s3.
$ export AWS_SECRET_ACCESS_KEY= <your secret>
$ export AWS_DEFAULT_REGION= <your bucket region e.g. us-west-2>
$ export TF_VAR_access_key=$AWS_ACCESS_KEY # exposed as access_key in terraform scripts
$ export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY # exposed as secret_key in terraform scripts
```

You need to change the default values of `s3_bucket` and `key_name` terraform variables defined in `variables.tf` or set them via environment variables:
```
$ export TF_VAR_s3_bucket=<your s3 bucket>
$ export TF_VAR_key_name=<your keypair name>
```
You also need to change the value of `STATEBUCKET` in the Makefile to match that of the `s3_bucket` terraform variable.

#### Run 'terraform plan'

    make

#### Run 'terraform apply'

    make apply
Upon completion, you'll need to access the AWS ECS console to find out the domain name of the Jenkins instance. It'll be something like `ec2-54-235-229-108.compute-1.amazonaws.com`. You can then reach Jenkins via your browser at `http://ec2-54-235-229-108.compute-1.amazonaws.com`.

#### Run 'terraform destroy'

    make destroy

### Provision a Jenkins image in ECR

1. `cd` into `docker` directory.
2. Modify `plugins.txt` to your liking.
3. Run `terraform apply`.

__Note__: If you provisioned the Jenkins image in ECR, the repository URL would look like: `<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/<jenkins_image_name>:latest`.

## Jenkins Data Backup

When an EC2 instance is started in started in the Jenkins autoscaling group, a cronjob is configured on it (see `templates/user_data.tpl`) to back up the Jenkins data directory that resides in the `/ecs/jenkins-home` directory to an S3 bucket set via the `s3_bucket` variable (see `variables.tf`).
There is a `restore_backup` terraform variable, which when set to true attempts to restore the S3 backup when an instance is started. This doesn't work yet because the backup needs to be restored before the Jenkins ECS task is started, which is currently not what happens.
To work around this, you can manually run the restore backup command on the Jenkins EC2 instance and restart the ECS task by terminating the running container.

    docker run \
    --env aws_key=${access_key} \
    --env aws_secret=${secret_key} \
    --env cmd=sync-s3-to-local \
    --env SRC_S3=s3://${s3_bucket}/${ecs_cluster_name}/jenkins-home/  \
    -v /ecs/jenkins-home:/opt/dest \
    garland/docker-s3cmd


## Credits

* The Makefile idea (and the Makefile itself) is taken from this [blog post](http://karlcode.owtelse.com/blog/2015/09/01/working-with-terraform-remote-statefile/).

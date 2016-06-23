# Makefile to kickoff terraform.
#
# Before you run this Makefile, you should set the following environment variables to authenticate with AWS,
# which allows you to store and retrieve the remote state.
#
# export AWS_ACCESS_KEY_ID= <your key>
# export AWS_SECRET_ACCESS_KEY= <your secret>
# export AWS_DEFAULT_REGION= <your bucket region e.g. us-west-2>
# export TF_VAR_access_key=$AWS_ACCESS_KEY # exposed as access_key in the terraform scripts
# export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY

# ####################################################
#
STATEBUCKET = mycompany-terraform
PREFIX = jenkins

# # Before we start test that we have the mandatory executables available
	EXECUTABLES = git terraform
	K := $(foreach exec,$(EXECUTABLES),\
		$(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH, consider apt-get install $(exec)")))
#
#     .PHONY: all s3bucket plan


.PHONY: all plan apply

all: init.txt plan
	echo "All"

plan:
	@echo "running terraform plan"
	terraform plan

apply:
	@echo running terraform apply
	terraform apply

destroy:
	@echo running terraform destroy
	terraform destroy

# little hack target to prevent it running again without need
# for second nested Makefile
init.txt:
	@echo "initialize remote state file"
	terraform remote config -backend=s3 -backend-config="bucket=$(STATEBUCKET)" -backend-config="key=$(PREFIX)/terraform.tfstate"
	echo "ran terraform remote config -backend=s3 -backend-config=\"bucket=$(STATEBUCKET)\" -backend-config=\"key=$(PREFIX)/terraform.tfstate\"" > ./init.txt

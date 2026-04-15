TERRAFORM_DIR := terraform

.PHONY: init validate plan apply destroy fmt

AUTO_APPROVE := $(if $(TF_IN_AUTOMATION),-auto-approve,)

unexport AWS_PROFILE

ifndef TF_IN_AUTOMATION
export AWS_PROFILE := projects
$(info Running locally, using AWS credentials from profile)
else
$(info Running in CI, using OIDC AWS credentials)
endif

init:
	terraform -chdir=$(TERRAFORM_DIR) init

validate:
	terraform -chdir=$(TERRAFORM_DIR) validate

plan:
	terraform -chdir=$(TERRAFORM_DIR) plan

apply:
	terraform -chdir=$(TERRAFORM_DIR) apply $(AUTO_APPROVE)

destroy:
	terraform -chdir=$(TERRAFORM_DIR) destroy $(AUTO_APPROVE)

fmt:
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

TERRAFORM_DIR := terraform
MANUAL_TERRAFORM_DIR := terraform-manual

.PHONY: init validate plan apply destroy fmt

AUTO_APPROVE := $(if $(TF_IN_AUTOMATION),-auto-approve,)

unexport AWS_PROFILE

ifndef TF_IN_AUTOMATION
export AWS_PROFILE := projects
$(info Running locally, using AWS credentials from profile)
else
$(info Running in CI, using OIDC AWS credentials)
endif

check-env:
ifndef TF_IN_AUTOMATION
ifndef AWS_PROFILE
        $(error AWS_PROFILE is not set. Please set it in your shell: export AWS_PROFILE=<aws_profile>)
endif
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
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) fmt -recursive

manual-init: check-env
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) init

manual-validate:
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) validate

manual-plan: check-env
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) plan

manual-apply: check-env
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) apply

manual-destroy: check-env
	terraform -chdir=$(MANUAL_TERRAFORM_DIR) destroy

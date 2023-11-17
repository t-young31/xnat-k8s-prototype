SHELL := /bin/bash
.PHONY: *

define terraform-apply
	. init.sh && \
	echo "Running: terraform apply on $(1)" && \
	cd $(1) && \
	terraform init -upgrade && \
	terraform validate && \
	terraform apply --auto-approve
endef

define terraform-destroy
	. init.sh && \
	echo "Running: terraform destroy on $(1)" && \
	cd $(1) && \
	terraform apply -destroy --auto-approve
endef

help:
	grep '.*[:]$$' Makefile | tr -d ':'

deploy:
	$(call terraform-apply, ./infra)
	cd infra && terraform output -json omero && terraform output -json xnat
	. init.sh && echo "Run: export KUBECONFIG=$$KUBECONFIG"

destroy:
	$(call terraform-destroy, ./infra) || true
	cd infra && terraform state rm module.aws.helm_release.longhorn
	$(call terraform-destroy, ./infra)

aws-login:
	aws configure sso

.SILENT:  # all targets

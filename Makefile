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
	grep '.*[:]$$' Makefile

dev:
	. init.sh && ./dev/create_cluster.sh && \
	export TF_VAR_kubeconfig_path="$$PWD/$$DEV_KUBECONFIG" && \
	$(call terraform-apply, ./infra)

dev-destroy:
	. init.sh && k3d cluster create "$$DEV_CLUSTER_NAME"

.SILENT:  # all targets

ENV ?= dev
TF_VAR_FILE_PATH := ./vars/$(ENV).tfvars
INGRESS_PACKAGE_PATH := ../../packages/ingress
INGRESS_PACKAGE_BUILD_SCRIPT = pnpm --prefix $(INGRESS_PACKAGE_PATH) build

init:
	terraform init -var-file=$(TF_VAR_FILE_PATH)

plan:
	$(INGRESS_PACKAGE_BUILD_SCRIPT) && terraform plan -var-file=$(TF_VAR_FILE_PATH)

apply:
	$(INGRESS_PACKAGE_BUILD_SCRIPT) && terraform apply -var-file=$(TF_VAR_FILE_PATH)
ENV ?= dev
TF_VAR_FILE_PATH := ./vars/$(ENV).tfvars

plan:
	terraform plan -var-file=$(TF_VAR_FILE_PATH)

apply:
	terraform apply -var-file=$(TF_VAR_FILE_PATH)
# Convenience wrapper for Terraform (infra) and Ansible (host config). Run
# apply first, then ansible-run -- Ansible needs the VM IP from Terraform.

.DEFAULT_GOAL := help

.PHONY: help init fmt validate plan apply destroy output \
        ansible-hosts ansible-check ansible-run ansible-idempotency

help: ## Show this help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Terraform ---

init: ## Download Terraform providers
	terraform -chdir=terraform init

fmt: ## Format Terraform configuration
	terraform -chdir=terraform fmt -recursive

validate: ## Validate Terraform configuration
	terraform -chdir=terraform validate

plan: ## Preview infrastructure changes
	terraform -chdir=terraform plan

apply: ## Apply Terraform
	terraform -chdir=terraform apply

destroy: ## Destroy all infrastructure
	terraform -chdir=terraform destroy

output: ## Show Terraform outputs
	terraform -chdir=terraform output

# --- Ansible ---

ansible-hosts: ## Generate inventory/hosts.yaml from Terraform outputs
	@{ \
	  echo "guestbook:"; \
	  echo "  hosts:"; \
	  echo "    guestbook-vm:"; \
	  echo "      ansible_host: \"$$(terraform -chdir=terraform output -raw vm_public_ip)\""; \
	  echo "      ansible_user: \"$$(whoami)\""; \
	  echo "      ansible_ssh_private_key_file: \"~/.ssh/google_compute_engine\""; \
	} > ansible/inventory/hosts.yaml
	@echo "Wrote ansible/inventory/hosts.yaml"

ansible-check: ## Syntax-check the Ansible playbook
	cd ansible && ansible-playbook --syntax-check site.yaml

ansible-run: ## Configure the host with Ansible
	cd ansible && ansible-playbook site.yaml

ansible-idempotency: ## Run the playbook twice
	cd ansible && \
		ansible-playbook site.yaml && \
		echo "--- second run (expect changed=0) ---" && \
		ansible-playbook site.yaml | grep -E 'changed=0.*failed=0'

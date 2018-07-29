.DEFAULT_GOAL := help

inventory ?= environments/$(env)
playbook ?= all
provider-dir = providers/digital_ocean/$(env)
container-image = do-orchestration
tags ?= all
user ?= $(shell whoami)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	docker_ssh_opts =  -e SSH_AUTH_SOCK=$(SSH_AUTH_SOCK) \
	-v $(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK)
endif
ifeq ($(UNAME_S),Darwin)
	docker_ssh_opts = -v $(HOME)/.ssh:/root/.ssh:ro
endif

base-docker-run = docker run \
	--rm \
	-e DO_TOKEN_KEY=$(do_token_key) \
	-e DIGITALOCEAN_TOKEN=$(do_token_key) \
	-v $(shell pwd):/data \
	$(docker_ssh_opts) \

ansible-docker-run = $(base-docker-run) \
	-w  /data/ansible \
	-it $(container-image)

terraform-docker-run = $(base-docker-run) \
	-w  /data/terraform/$(provider-dir) \
	-it $(container-image)

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

.PHONY: ansible-list-host
ansible-list-host: guard-env ## List information about the hosts managed by Ansible
	$(base-docker-run) -it $(container-image) \
		python ansible/environments/$(env)/azure_rm.py --list | \
			jq -c -r '._meta.hostvars[] | "\(.computer_name) \(.private_ip)"' | \
			sort

.PHONY: ansible-playbook
ansible-playbook: guard-env guard-playbook ## Execute Ansible playbooks
	$(ansible-docker-run) \
		ansible-playbook $(playbook).yml \
			-c ssh \
			-e 'env=$(env)' \
			-i $(inventory) \
			-t $(tags) \
			-u $(user) \
			$(ansible-args)

.PHONY: ansible-remote-shell
ansible-remote-shell: guard-env guard-hosts guard-shell ## Execute arbitrary commands inside hosts
	$(ansible-docker-run) \
		ansible $(hosts) \
			-e 'env=$(env)' \
			-i $(inventory) \
			-m shell \
			-b \
			-u $(user) \
			-a '$(shell)' \
			$(ansible-args)

.PHONY: ansible-edit-vault
ansible-edit-vault: guard-vault ## Edit Ansible vault file
	$(ansible-docker-run) \
		ansible-vault edit ../$(vault)

.PHONY: bash
bash: ## Run arbitrary commands inside the container
	$(base-docker-run) -it $(container-image) /bin/bash

.PHONY: clean
clean: ## Clean runtime files, configurations and docker image
	find . -name ".terraform" -exec rm -rf {} +
	docker rmi $(container-image)

.PHONY: help
help: ## Show help
	@IFS=$$'\n' ; \
		help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//'`); \
		printf "%-30s %s\n" Target "Help message" ; \
		printf "%-30s %s\n" ------ ------------ ; \
		for help_line in $${help_lines[@]}; do \
			IFS=$$'#' ; \
			help_split=($$help_line) ; \
			help_command=`echo $${help_split[0]} | echo $${help_split[0]} | cut -d: -f1` ; \
			help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
			printf "%-30s %s\n" $$help_command $$help_info ; \
		done

.PHONY: terraform
terraform: guard-env guard-terraform-command ## Execute arbitrary Terraform commands
	$(terraform-docker-run) \
		terraform $(terraform-command) \
			$(terraform-args)

.PHONY: terraform-apply
terraform-apply: guard-env ## Apply Terraform providers
	$(terraform-docker-run) \
		terraform apply \
			-auto-approve=false \
			-parallelism=100 \
			$(terraform-args) \
			.

.PHONY: terraform-destroy
terraform-destroy: guard-env ## Destroy Terraform providers
	$(terraform-docker-run) \
		terraform destroy \
		-parallelism=100 \
		$(terraform-args) \
		.

.PHONY: terraform-fmt
terraform-fmt: ## Execute Terraform fmt
	@$(base-docker-run) \
		-w /data/terraform \
		-t $(container-image) \
		terraform fmt

.PHONY: terraform-init
terraform-init: guard-env ## Initialize Terraform providers
	$(terraform-docker-run) \
		terraform init \
			-backend-config="key=$(env).tfstate" \
			-backend-config="access_key=$(s3_access_key)" \
			-backend-config="secret_key=$(s3_secret_key)" \
			.

.PHONY: terraform-plan
terraform-plan: guard-env ## Show differences between real infrastructure and Terraform configurations
	$(terraform-docker-run) \
		terraform plan \
			$(terraform-args) \
			.

.PHONY: terraform-output
terraform-output: guard-env ## Show Terraform JSON output values
	$(terraform-docker-run) \
		terraform output \
			-json \
			-no-color

.PHONY: terraform-show
terraform-show: guard-env ## Show Terraform state
	$(terraform-docker-run) \
		terraform show \
			$(terraform-args)

.PHONY: setup
setup: ## Setup development environment
	@echo "Copying user ssh key"
	cp -v $(HOME)/.ssh/id_rsa.pub keys/bootstrap.pub && \
		chmod 0600 keys/bootstrap.pub
	@echo "Copying git hooks"
	cp -v githooks/pre-commit .git/hooks/pre-commit && \
		chmod +x .git/hooks/pre-commit
	@echo "Updating submodules"
	git submodule update --init --recursive
	@echo "Building docker image"
	docker build . -t $(container-image)
	@echo "Done!"

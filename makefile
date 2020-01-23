clean:
	rm -rf .terraform
	rm terraform.tfstate*

apply:
	terraform init && \
	terraform apply -target=module.infrastructure -auto-approve && \
	terraform apply -target=module.rhnregister -auto-approve && \
	terraform apply -target=module.dnscerts -auto-approve && \
	terraform apply -target=module.openshift -auto-approve

plan:
	terraform init && terraform plan

destroy:
	terraform destroy -target=module.rhnregister -auto-approve && \
	terraform destroy -target=module.infrastructure -auto-approve && \
	terraform destroy -auto-approve

sshbastion:
	chmod 600 artifacts/openshift_rsa*
	ssh -i artifacts/openshift_rsa ocpadmin@`terraform output bastion_public_ip`

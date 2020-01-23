#################################################
# Output Bastion Node
#################################################

output "bastion_public_ip" {
  value = "${module.infrastructure.bastion_public_ip}"
}

output "bastion_private_ip" {
  value = "${module.infrastructure.bastion_private_ip}"
}

output "bastion_hostname" {
  value = "${module.infrastructure.bastion_hostname}"
}


#################################################
# Output Master Node
#################################################
output "master_private_ip" {
  value = "${module.infrastructure.master_private_ip}"
}

output "master_hostname" {
  value = "${module.infrastructure.master_hostname}"
}

#################################################
# Output Infra Node
#################################################
output "infra_private_ip" {
  value = "${module.infrastructure.infra_private_ip}"
}

output "infra_hostname" {
  value = "${module.infrastructure.infra_hostname}"
}

#################################################
# Output Worker Node
#################################################
output "worker_private_ip" {
  value = "${module.infrastructure.worker_private_ip}"
}

output "worker_hostname" {
  value = "${module.infrastructure.worker_hostname}"
}

#################################################
# Output Storage Node
#################################################
output "storage_private_ip" {
  value = "${module.infrastructure.storage_private_ip}"
}

output "storage_hostname" {
  value = "${module.infrastructure.storage_hostname}"
}

# #################################################
# # Output OpenShift
# #################################################
# output "kubeconfig" {
#     value = "${module.kubeconfig.config}"
# }

# Azure Stuff
output "azure_client_id" {
    value = "${module.infrastructure.azure_client_id}"
}

output "azure_client_secret" {
    value = "${module.infrastructure.azure_client_secret}"
    # sensitive = true
}

output "azure_tenant_id" {
    value = "${module.infrastructure.azure_tenant_id}"
}

output "azure_subscription_id" {
    value = "${module.infrastructure.azure_subscription_id}"
}

output "azure_storage_account" {
    value = "${module.infrastructure.azure_storage_account}"
}

output "azure_storage_accountkey" {
    value = "${module.infrastructure.azure_storage_accountkey}"
}

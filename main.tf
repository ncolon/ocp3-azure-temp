###########################################################
### Generate Random Tag
###########################################################
resource "random_id" "tag" {
  byte_length = 4
}

resource "tls_private_key" "installkey" {
  algorithm = "RSA"
  rsa_bits = "2048"
}

resource "local_file" "write_private_key" {
    content  = "${tls_private_key.installkey.private_key_pem}"
    filename = "${path.module}/artifacts/openshift_rsa"
}

resource "local_file" "write_public_key" {
    content  = "${tls_private_key.installkey.public_key_openssh}"
    filename = "${path.module}/artifacts/openshift_rsa.pub"
}


###########################################################
### Build Azure Infrastructure
###########################################################

module "infrastructure" {
  source                  = "github.com/ncolon/terraform-openshift-azure"
  datacenter              = "${var.datacenter}"
  cluster_resource_group  = "${var.cluster_resource_group}-${random_id.tag.hex}"
  bastion_private_ssh_key = "${tls_private_key.installkey.private_key_pem}"
  bastion_public_ssh_key  = "${tls_private_key.installkey.public_key_openssh}"
  openshift_vm_admin_user = "${var.ssh_user}"
  bastion                 = "${var.bastion}"
  master                  = "${var.master}"
  infra                   = "${var.infra}"
  worker                  = "${var.worker}"
  storage                 = "${var.storage}"
  hostname_prefix         = "${var.hostname_prefix}-${random_id.tag.hex}"
}

###########################################################
### Register Azure VMs with RHN
###########################################################
locals {
  rhn_all_nodes = "${concat(
        "${list(module.infrastructure.bastion_public_ip)}",
        "${module.infrastructure.master_private_ip}",
        "${module.infrastructure.infra_private_ip}",
        "${module.infrastructure.worker_private_ip}",
        "${module.infrastructure.storage_private_ip}"
    )}"

  rhn_all_count = "${var.bastion["nodes"] + var.master["nodes"] + var.infra["nodes"] + var.worker["nodes"] + var.storage["nodes"]}"
  openshift_node_count = "${var.master["nodes"] + var.worker["nodes"] + var.infra["nodes"] +  var.storage["nodes"]}"
}

module "rhnregister" {
  source             = "github.com/ibm-cloud-architecture/terraform-openshift-rhnregister"

  dependson          = [
    "${module.infrastructure.module_completed}"
  ]

  bastion_ip_address      = "${module.infrastructure.bastion_public_ip}"
  bastion_ssh_user        = "${var.ssh_user}"
  bastion_ssh_password    = "${var.ssh_password}"
  bastion_ssh_private_key = "${tls_private_key.installkey.private_key_pem}"

  ssh_user           = "${var.ssh_user}"
  ssh_private_key    = "${tls_private_key.installkey.private_key_pem}"

  rhn_username       = "${var.rhn_username}"
  rhn_password       = "${var.rhn_password}"
  rhn_poolid         = "${var.rhn_poolid}"
  all_nodes          = "${local.rhn_all_nodes}"
  all_count          = "${local.rhn_all_count}"
}


module "openshift" {
  source = "github.com/ibm-cloud-architecture/terraform-openshift3-deploy"

  dependson = [
    "${module.rhnregister.registered_resource}"
  ]

  # cluster nodes
  node_count              = "${local.openshift_node_count}"
  master_count            = "${var.master["nodes"]}"
  infra_count             = "${var.infra["nodes"]}"
  worker_count            = "${var.worker["nodes"]}"
  storage_count           = "${var.storage["nodes"]}"
  master_private_ip       = "${module.infrastructure.master_private_ip}"
  infra_private_ip        = "${module.infrastructure.infra_private_ip}"
  worker_private_ip       = "${module.infrastructure.worker_private_ip}"
  storage_private_ip      = "${module.infrastructure.storage_private_ip}"
  master_hostname         = "${formatlist("%v", module.infrastructure.master_hostname)}"
  infra_hostname          = "${formatlist("%v", module.infrastructure.infra_hostname)}"
  worker_hostname         = "${formatlist("%v", module.infrastructure.worker_hostname)}"
  storage_hostname        = "${formatlist("%v", module.infrastructure.storage_hostname)}"

  # second disk is docker block device, in VMware it's /dev/sdb, on Azure its /dev/sdc
  docker_block_device     = "/dev/sdc"

  # third disk on storage nodes, in VMware it's /dev/sdc, on Azure its /dev/sdd
  gluster_block_devices   = [ "/dev/sdd" ]
  registry_storage_kind   = "glusterfs"

  # connection parameters
  bastion_ip_address      = "${module.infrastructure.bastion_public_ip}"
  bastion_ssh_user        = "${var.ssh_user}"
  bastion_ssh_password    = "${var.ssh_password}"
  bastion_ssh_private_key = "${tls_private_key.installkey.private_key_pem}"

  ssh_user                = "${var.ssh_user}"
  ssh_private_key         = "${tls_private_key.installkey.private_key_pem}"

  cloudprovider           = {
      kind = "azure"
  }

  ose_version             = "${var.ose_version}"
  ose_deployment_type     = "${var.ose_deployment_type}"
  image_registry          = "${var.image_registry}"
  image_registry_username = "${var.image_registry_username == "" ? var.rhn_username : var.image_registry_username}"
  image_registry_password = "${var.image_registry_password == "" ? var.rhn_password : var.image_registry_password}"

  # internal API endpoint
  master_cluster_hostname = "${module.infrastructure.public_master_vip}"

  # public endpoints - must be in DNS
  cluster_public_hostname = "${var.master_cname}"
  app_cluster_subdomain   = "${var.app_cname}"

  registry_volume_size    = "${var.registry_volume_size}"

  pod_network_cidr        = "${var.network_cidr}"
  service_network_cidr    = "${var.service_network_cidr}"
  host_subnet_length      = "${var.host_subnet_length}"

  # custom_inventory        = [
  #   "osm_use_cockpit=false",
  #   "openshift_storage_glusterfs_storageclass_default=false",
  #   "openshift_cloudprovider_kind=azure",
  #   "openshift_cloudprovider_azure_client_id=${module.infrastructure.azure_client_id}",
  #   "openshift_cloudprovider_azure_client_secret=${module.infrastructure.azure_client_secret}",
  #   "openshift_cloudprovider_azure_tenant_id=${module.infrastructure.azure_tenant_id}",
  #   "openshift_cloudprovider_azure_subscription_id=${module.infrastructure.azure_subscription_id}",
  #   "openshift_cloudprovider_azure_resource_group=${var.cluster_resource_group}-${random_id.tag.hex}",
  #   "openshift_cloudprovider_azure_location=${var.datacenter}",
  #   "# Storage Class change to use managed storage",
  #   "openshift_storageclass_parameters={'kind': 'managed', 'storageaccounttype': 'Premium_LRS'}",
  #   "# Azure Registry Configuration",
  #   "openshift_hosted_registry_replicas=1",
  #   "openshift_hosted_registry_storage_kind=object",
  #   "openshift_hosted_registry_storage_azure_blob_accountkey=${module.infrastructure.azure_storage_accountkey}",
  #   "openshift_hosted_registry_storage_provider=azure_blob",
  #   "openshift_hosted_registry_storage_azure_blob_accountname=${module.infrastructure.azure_storage_account}",
  #   "openshift_hosted_registry_storage_azure_blob_container=registry",
  #   "openshift_hosted_registry_storage_azure_blob_realm=core.windows.net",
  # ]
}

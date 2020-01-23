###########################################################
# SSH Key Module
###########################################################
variable "ssh_private_key_file" {
  default = "artifacts/openshift_rsa"
}

variable "ssh_password" {
  default = ""
}
###########################################################
# Azure Infrastructure Module
###########################################################
variable "datacenter" {
}

variable "cluster_resource_group" {
}

variable "keyvault_resource_group" {
}

variable "keyvault_name" {
}

variable "ssh_user" {
}

variable "bastion" {
  type = "map"

  default = {
    flavor = "Standard_D1"
    nodes  = "1"
    docker_disk_size   = "100" # Specify size for docker disk, default 100.
  }
}

variable "master" {
  type = "map"

  default = {
    flavor             = "Standard_D8s_v3"
    nodes              = "3"
    docker_disk_size   = "100" # Specify size for docker disk, default 100.
    docker_disk_device = "/dev/sdc"
  }
}

variable "infra" {
  type = "map"

  default = {
    flavor             = "Standard_D8s_v3"
    nodes              = "3"
    docker_disk_size   = "100" # Specify size for docker disk, default 100.
    docker_disk_device = "/dev/sdc"
  }
}

variable "worker" {
  type = "map"

  default = {
    flavor             = "Standard_D8s_v3"
    nodes              = "3"
    docker_disk_size   = "100" # Specify size for docker disk, default 100.
    docker_disk_device = "/dev/sdc"
  }
}

variable "storage" {
  type = "map"

  default = {
    flavor = "Standard_D8s_v3"
    nodes  = "3"
    docker_disk_size   = "100" # Specify size for docker disk, default 100.
    docker_disk_device = "/dev/sdc"
    gluster_disk_size   = "500" # Specify size for docker disk, default 100.
    gluster_disk_device = "/dev/sdd"
  }
}

variable "haproxy" {
  type = "map"
  default = {
    nodes = "0"
  }
}

variable "hostname_prefix" {
    default = "ocp-azure"
}

###########################################################
# RedHat Registration Module
###########################################################
variable "rhn_username" {}
variable "rhn_password" {}
variable "rhn_poolid" {}


###########################################################
# DNS and Certificates Module
###########################################################
variable "dnscerts" {default = false}
variable "domain" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "letsencrypt_email" {}
variable "letsencrypt_dns_provider" {}
variable "letsencrypt_api_endpoint" {
    default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "master_cname" {}
variable "app_cname" {}


###########################################################
# OpenShift Deploy Module
###########################################################
variable "storageprovider" {
    default = "glusterfs"
}

variable "network_cidr" {
  default = "10.128.0.0/14"
}

variable "service_network_cidr" {
  default = "172.30.0.0/16"
}

variable "host_subnet_length" {
  default = 9
}

variable "ose_version" {
  default = "3.11"
}

variable "ose_deployment_type" {
  default = "openshift-enterprise"
}

variable "image_registry" {
  default = "registry.redhat.io"
}

variable "image_registry_path" {
  default = "/openshift3/ose-$${component}:$${version}"
}

variable "image_registry_username" {
  default = ""
}

variable "image_registry_password" {
  default = ""
}

variable "registry_volume_size" {
  default = "100"
}

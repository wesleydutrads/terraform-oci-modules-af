locals {
  name_prefix = "oke-af"
  vcn_cidr    = "10.0.0.0/16"
  api_cidr    = "10.0.0.0/28"
  lb_cidr     = "10.0.20.0/24"
  nodes_cidr  = "10.0.10.0/24"
  common_tags = {
    managed-by = "terraform"
    project    = "oci-always-free"
  }
}

resource "random_password" "monitoring_token" {
  length  = 32
  special = false
}

module "foundation" {
  source = "../../modules/foundation"

  tenancy_ocid                  = var.tenancy_ocid
  compartment_name              = "INFRA"
  create_compartment_if_missing = true
  freeform_tags                 = local.common_tags
}

module "network" {
  source = "../../modules/network"

  compartment_ocid  = module.foundation.compartment_ocid
  name_prefix       = local.name_prefix
  vcn_cidr          = local.vcn_cidr
  api_subnet_cidr   = local.api_cidr
  lb_subnet_cidr    = local.lb_cidr
  nodes_subnet_cidr = local.nodes_cidr
  api_allowed_cidrs = var.api_allowed_cidrs
  freeform_tags     = local.common_tags
}

module "dns" {
  source = "../../modules/dns"

  compartment_ocid = module.foundation.compartment_ocid
  zone_name        = var.domain_name
  enabled          = true
  freeform_tags    = local.common_tags
}

module "oke" {
  source = "../../modules/oke"

  compartment_ocid    = module.foundation.compartment_ocid
  region              = var.region
  cluster_name        = local.name_prefix
  vcn_id              = module.network.vcn_id
  vcn_cidr            = local.vcn_cidr
  api_subnet_id       = module.network.api_subnet_id
  api_subnet_cidr     = local.api_cidr
  lb_subnet_id        = module.network.lb_subnet_id
  nodes_subnet_id     = module.network.nodes_subnet_id
  nodes_subnet_cidr   = local.nodes_cidr
  kubernetes_version  = var.kubernetes_version
  api_allowed_cidrs   = var.api_allowed_cidrs
  pods_cidr           = "10.244.0.0/16"
  services_cidr       = "10.96.0.0/16"
  ssh_public_key      = var.ssh_public_key
  node_image_ocid     = var.node_image_ocid
  availability_domain = var.availability_domain
  freeform_tags       = local.common_tags
}

module "platform" {
  source = "../../modules/platform"

  enabled          = var.enable_platform
  domain_name      = var.domain_name
  acme_email       = var.acme_email
  kubeconfig_path  = var.kubeconfig_path
  compartment_ocid = module.foundation.compartment_ocid
  region           = var.region
}

module "observability" {
  source = "../../modules/observability"

  enabled           = var.enable_platform
  gateway_name      = module.platform.gateway_name
  gateway_namespace = module.platform.gateway_namespace
  kubeconfig_path   = var.kubeconfig_path
  monitoring_token  = random_password.monitoring_token.result
  enable_loki       = false
  enable_tempo      = false
  enable_jaeger     = true
  hosts = {
    kiali   = "kiali.${var.domain_name}"
    grafana = "grafana.${var.domain_name}"
    tracing = "tracing.${var.domain_name}"
  }
}

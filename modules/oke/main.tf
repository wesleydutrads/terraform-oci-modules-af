resource "oci_core_network_security_group" "control_plane" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "${var.cluster_name}-nsg-cp"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "control_plane_api" {
  for_each                  = toset(var.api_allowed_cidrs)
  network_security_group_id = oci_core_network_security_group.control_plane.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = each.value
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_core_network_security_group" "nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "${var.cluster_name}-nsg-nodes"
  freeform_tags  = var.freeform_tags
}

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  type               = "BASIC_CLUSTER"
  freeform_tags      = var.freeform_tags

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.api_subnet_id
    nsg_ids              = [oci_core_network_security_group.control_plane.id]
  }

  options {
    service_lb_subnet_ids = [var.lb_subnet_id]

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
  }
}

resource "oci_containerengine_node_pool" "this" {
  cluster_id         = oci_containerengine_cluster.this.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.node_pool_name
  node_shape         = var.node_shape
  ssh_public_key     = var.ssh_public_key
  freeform_tags      = var.freeform_tags

  node_config_details {
    size    = var.node_pool_size
    nsg_ids = [oci_core_network_security_group.nodes.id]

    placement_configs {
      availability_domain = var.availability_domain
      subnet_id           = var.nodes_subnet_id
    }
  }

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_gbs
  }

  node_source_details {
    image_id                = var.node_image_ocid
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = var.node_boot_volume_size_gbs
  }
}

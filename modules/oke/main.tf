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

resource "oci_core_network_security_group_security_rule" "control_plane_worker_api" {
  for_each                  = toset(["6443", "12250"])
  network_security_group_id = oci_core_network_security_group.control_plane.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.nodes_subnet_cidr
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = tonumber(each.value)
      max = tonumber(each.value)
    }
  }
}

resource "oci_core_network_security_group_security_rule" "control_plane_icmp_path_discovery" {
  network_security_group_id = oci_core_network_security_group.control_plane.id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = var.nodes_subnet_cidr
  source_type               = "CIDR_BLOCK"

  icmp_options {
    type = 3
    code = 4
  }
}

resource "oci_core_network_security_group_security_rule" "control_plane_egress" {
  network_security_group_id = oci_core_network_security_group.control_plane.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = var.vcn_cidr
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group" "nodes" {
  compartment_id = var.compartment_ocid
  vcn_id         = var.vcn_id
  display_name   = "${var.cluster_name}-nsg-nodes"
  freeform_tags  = var.freeform_tags
}

resource "oci_core_network_security_group_security_rule" "nodes_egress" {
  network_security_group_id = oci_core_network_security_group.nodes.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "nodes_ingress_vcn" {
  network_security_group_id = oci_core_network_security_group.nodes.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.nodes_subnet_cidr
  source_type               = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "nodes_ingress_control_plane" {
  network_security_group_id = oci_core_network_security_group.nodes.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.api_subnet_cidr
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 1
      max = 65535
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nodes_ingress_icmp_path_discovery" {
  network_security_group_id = oci_core_network_security_group.nodes.id
  direction                 = "INGRESS"
  protocol                  = "1"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"

  icmp_options {
    type = 3
    code = 4
  }
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

  lifecycle {
    precondition {
      condition     = var.node_ocpus * var.node_pool_size <= 4
      error_message = "Total A1 OCPU must stay at or below the 4 OCPU Always Free budget."
    }

    precondition {
      condition     = var.node_memory_gbs * var.node_pool_size <= 24
      error_message = "Total A1 memory must stay at or below the 24 GB Always Free budget."
    }

    precondition {
      condition     = var.node_boot_volume_size_gbs * var.node_pool_size <= 150
      error_message = "Node boot volumes must leave free block volume budget for optional PVCs/admin box."
    }
  }
}

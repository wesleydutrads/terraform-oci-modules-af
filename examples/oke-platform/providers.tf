provider "oci" {
  region              = var.region
  config_file_profile = var.oci_profile
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

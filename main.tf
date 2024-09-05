resource "kubernetes_config_map" "apps_iac_config" {
  metadata {
    namespace = "apps"
    name = "iac-config"
  }

  data = {
    DB_HOSTNAME = var.rds_hostname
    DB_PORT = var.rds_port
  }
}

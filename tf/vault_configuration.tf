# Provider Documentation for HashiCorp Vault:
#  https://registry.terraform.io/providers/hashicorp/vault/latest/docs

variable "managed_clusters" {
  type    = list(string)
  default = ["orion", "vega", "phoenix", "sirius"]
}

resource "vault_mount" "kv" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "kv_mount" {
  mount                = vault_mount.kv.path
  max_versions         = 20
  delete_version_after = 12600
  cas_required         = true
}

resource "vault_policy" "policies" {
  for_each = fileset("${path.module}/policies", "*.hcl")
  name     = each.key
  policy   = templatefile("${path.module}/policies/${each.value}", { managed_clusters = var.managed_clusters })
}

resource "vault_auth_backend" "kubernetes" {
  for_each = toset(var.managed_clusters)
  path     = each.key
  type     = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_config" {
  for_each               = toset(var.managed_clusters)
  backend                = vault_auth_backend.kubernetes[each.key].path
  kubernetes_host        = "https://api.${each.key}.example.com:443"
  disable_iss_validation = true
}

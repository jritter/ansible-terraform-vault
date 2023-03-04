
resource "vault_policy" "policies" {
  for_each = fileset("${path.module}/policies", "*.hcl")
  name = "dev-team"
  policy = file("${path.module}/policies/${each.value}")
}

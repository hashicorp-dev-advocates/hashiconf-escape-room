resource "boundary_worker" "main" {
  scope_id    = "global"
  name        = "main worker"
  description = "main worker"
}

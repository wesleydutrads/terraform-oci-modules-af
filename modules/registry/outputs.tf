output "repositories" {
  description = "Created OCIR repositories keyed by repository name."
  value = {
    for name, repo in oci_artifacts_container_repository.this : name => {
      id           = repo.id
      display_name = repo.display_name
      is_public    = repo.is_public
    }
  }
}

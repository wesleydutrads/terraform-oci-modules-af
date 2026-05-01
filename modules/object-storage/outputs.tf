output "namespace" {
  description = "Object Storage namespace."
  value       = var.enabled ? data.oci_objectstorage_namespace.this[0].namespace : null
}

output "s3_endpoint" {
  description = "OCI Object Storage S3-compatible path-style endpoint."
  value       = var.enabled ? "https://${data.oci_objectstorage_namespace.this[0].namespace}.compat.objectstorage.${var.region}.oraclecloud.com" : null
}

output "buckets" {
  description = "Created buckets keyed by logical purpose."
  value = {
    for key, bucket in oci_objectstorage_bucket.this : key => {
      name      = bucket.name
      namespace = bucket.namespace
      id        = bucket.bucket_id
    }
  }
}

output "customer_secret_access_key_id" {
  description = "Access key ID for OCI S3-compatible API."
  value       = length(oci_identity_customer_secret_key.this) > 0 ? oci_identity_customer_secret_key.this[0].id : null
  sensitive   = true
}

output "customer_secret_access_key" {
  description = "Secret key for OCI S3-compatible API."
  value       = length(oci_identity_customer_secret_key.this) > 0 ? oci_identity_customer_secret_key.this[0].key : null
  sensitive   = true
}

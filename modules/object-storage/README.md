# object-storage

Creates private OCI Object Storage buckets and, optionally, a Customer Secret Key for S3-compatible clients.

Use this module for Loki and Tempo persistence. The generated secret is sensitive and is stored in Terraform state; use a protected remote backend before sharing state.

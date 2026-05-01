# foundation

Creates or discovers the target compartment and exposes common foundation outputs.

When enabled, it can also create a Dynamic Group and IAM policy for compute instances in the compartment. This is used by Kubernetes controllers such as `external-dns` when they authenticate to OCI with instance principals.

Creates or resolves a target compartment and exposes common metadata for downstream modules.

This module does not create paid resources.

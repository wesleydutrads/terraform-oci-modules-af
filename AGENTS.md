# Repository Guidelines

## Project Structure & Module Organization

This repository contains reusable Terraform modules for OCI Always Free environments. Put modules under `modules/<name>/` and runnable examples under `examples/<scenario>/`. Keep root files limited to repository documentation and shared tooling.

## Build, Test, and Development Commands

- `terraform fmt -recursive -check`: checks Terraform formatting.
- `terraform fmt -recursive`: rewrites Terraform files with canonical formatting.
- `terraform init`: initializes providers in an example or module test directory.
- `terraform validate`: validates initialized Terraform configuration.

## Coding Style & Naming Conventions

Use two-space indentation and `snake_case` for variables, locals, outputs, and resource names. Module variables must be explicit, typed, and documented. Avoid hardcoded domains, OCIDs, emails, personal IPs, or tenancy-specific names inside modules.

## Testing Guidelines

Every module should include at least one minimal example before release. Validate examples with `terraform init` and `terraform validate`. Prefer validations that prevent accidental paid resources when the module targets Always Free usage.

## Commit & Pull Request Guidelines

Use concise imperative commit messages, for example `Add OKE module skeleton`. Pull requests should list modules changed, validation commands run, and any cost impact.

## Security & Configuration Tips

Never commit `*.tfvars`, state files, generated credentials, kubeconfigs, or private keys. Paid resources must be opt-in and called out in module documentation.

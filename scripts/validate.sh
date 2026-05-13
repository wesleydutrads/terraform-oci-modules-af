#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/env.sh"

mapfile -t roots < <(find modules -mindepth 1 -maxdepth 1 -type d | sort)

for root in "${roots[@]}"; do
  echo "==> terraform validate ${root}"
  terraform -chdir="${root}" init -backend=false >/dev/null
  terraform -chdir="${root}" validate
done

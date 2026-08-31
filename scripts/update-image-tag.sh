#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/update-image-tag.sh <service> <image-repository> <image-tag> [values-file]

Examples:
  scripts/update-image-tag.sh backend registry.example.com/weer/backend weer-backend-42-a1b2c3d
  scripts/update-image-tag.sh frontend registry.example.com/weer/frontend weer-frontend-42-a1b2c3d charts/weer/values-local.yaml
USAGE
}

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
  usage
  exit 1
fi

service="$1"
image_repository="$2"
image_tag="$3"
values_file="${4:-charts/weer/values-local.yaml}"

if [ "$service" != "backend" ] && [ "$service" != "frontend" ]; then
  echo "service must be backend or frontend" >&2
  exit 1
fi

if [ ! -f "$values_file" ]; then
  echo "values file not found: $values_file" >&2
  exit 1
fi

if command -v yq >/dev/null 2>&1; then
  yq -i ".${service}.image.repository = \"${image_repository}\" | .${service}.image.tag = \"${image_tag}\"" "$values_file"
else
  python3 - "$service" "$image_repository" "$image_tag" "$values_file" <<'PY'
import sys
from pathlib import Path

service, repo, tag, values_file = sys.argv[1:]
path = Path(values_file)
lines = path.read_text().splitlines()

in_service = False
in_image = False
service_indent = None
image_indent = None

for index, line in enumerate(lines):
    stripped = line.strip()
    indent = len(line) - len(line.lstrip(" "))

    if stripped == f"{service}:":
        in_service = True
        in_image = False
        service_indent = indent
        continue

    if in_service and indent <= service_indent and stripped:
        in_service = False
        in_image = False

    if in_service and stripped == "image:":
        in_image = True
        image_indent = indent
        continue

    if in_image and indent <= image_indent and stripped:
        in_image = False

    if in_image and stripped.startswith("repository:"):
        lines[index] = f"{' ' * indent}repository: {repo}"

    if in_image and stripped.startswith("tag:"):
        lines[index] = f"{' ' * indent}tag: \"{tag}\""

path.write_text("\n".join(lines) + "\n")
PY
fi

echo "updated ${service} image to ${image_repository}:${image_tag} in ${values_file}"

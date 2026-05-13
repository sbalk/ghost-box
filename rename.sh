#!/usr/bin/env bash
set -euo pipefail

OLD="ghost-box"
NEW="${1:-$(basename "$(pwd)")}"

if [ "$NEW" = "$OLD" ]; then
    echo "Already named '$OLD' — nothing to do."
    exit 0
fi

if ! [[ "$NEW" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo "Error: '$NEW' is not a valid name." >&2
    echo "Use lowercase letters, digits, and dashes; must start with a letter." >&2
    exit 1
fi

echo "Renaming '$OLD' → '$NEW'..."

FILES=(
    "Dockerfile"
    "compose.yaml"
    ".devcontainer/devcontainer.json"
    "README.md"
)

# Portable sed -i across GNU (Linux) and BSD (macOS).
sed_inplace() {
    if sed --version >/dev/null 2>&1; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
        sed_inplace "s/${OLD}/${NEW}/g" "$f"
        echo "  updated $f"
    fi
done

if [ -f "bin/${OLD}" ]; then
    mv "bin/${OLD}" "bin/${NEW}"
    echo "  renamed bin/${OLD} → bin/${NEW}"
fi

echo
echo "Done. Suggested next steps:"
echo "  1. Review changes:    git diff"
echo "  2. Match folder name: cd .. && mv \"$(basename "$(pwd)")\" \"${NEW}\" && cd \"${NEW}\""
echo "  3. Launch:            ./bin/${NEW}"

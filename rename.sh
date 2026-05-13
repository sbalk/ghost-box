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
    sed_inplace "s/${OLD}/${NEW}/g" "bin/${OLD}"
    mv "bin/${OLD}" "bin/${NEW}"
    echo "  renamed bin/${OLD} → bin/${NEW}"
fi

# Cut ties with the template repo and start a fresh history.
if [ -d .git ]; then
    rm -rf .git
    echo "  removed old .git"
fi
git init -q
git add .
git commit -q -m "Initial commit from ghost-box template"
echo "  initialized fresh git repo with initial commit"

echo
echo "Done. Suggested next steps:"
echo "  1. Match folder name: cd .. && mv \"$(basename "$(pwd)")\" \"${NEW}\" && cd \"${NEW}\""
echo "  2. Push to GitHub:    gh repo create ${NEW} --private --source=. --push"
echo "  3. Launch:            ./bin/${NEW}"

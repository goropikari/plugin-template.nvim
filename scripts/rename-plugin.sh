#!/usr/bin/env bash

set -euo pipefail

placeholder='sample'
plugin_name="${1:-}"

if [[ -z "$plugin_name" ]]; then
  echo "usage: make rename PLUGIN_NAME=<lua-module-name>" >&2
  exit 2
fi

if [[ ! "$plugin_name" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "plugin name must be a lowercase Lua module name: $plugin_name" >&2
  exit 2
fi

if [[ ! -d "lua/$placeholder" ]]; then
  echo "placeholder directory not found: lua/$placeholder" >&2
  exit 1
fi

if [[ "$plugin_name" != "$placeholder" && -e "lua/$plugin_name" ]]; then
  echo "destination already exists: lua/$plugin_name" >&2
  exit 1
fi

script_path='scripts/rename-plugin.sh'
while IFS= read -r -d '' file; do
  [[ "$file" == "$script_path" ]] && continue
  if git grep -Il -e "$placeholder" -- "$file" >/dev/null 2>&1; then
    perl -0pi -e 's/\Qsample\E/'"$plugin_name"'/g' -- "$file"
  fi
done < <(git ls-files -z)

if [[ "$plugin_name" != "$placeholder" ]]; then
  git mv "lua/$placeholder" "lua/$plugin_name"
fi

echo "renamed plugin placeholder '$placeholder' to '$plugin_name'"

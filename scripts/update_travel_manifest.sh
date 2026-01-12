#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
travel_dir="$root_dir/assets/images/travel"
manifest="$travel_dir/manifest.json"
index_file="$root_dir/index.html"

if [[ ! -d "$travel_dir" ]]; then
  echo "Travel directory not found: $travel_dir" >&2
  exit 1
fi

files=("$travel_dir"/*)

printf '[\n' > "$manifest"
count=0
for path in "${files[@]}"; do
  filename="$(basename "$path")"
  if [[ "$filename" == "manifest.json" ]]; then
    continue
  fi
  if [[ -f "$path" ]]; then
    if [[ $count -gt 0 ]]; then
      printf ',\n' >> "$manifest"
    fi
    printf '  "%s"' "$filename" >> "$manifest"
    count=$((count + 1))
  fi
done
printf '\n]\n' >> "$manifest"

echo "Wrote $count entries to $manifest"

if [[ -f "$index_file" ]]; then
  json_block="$(sed 's/^/          /' "$manifest")"
  export TRAVEL_BLOCK=$'<!-- travel-manifest:start -->\n        <script type="application/json" id="travel-manifest">\n'"${json_block}"$'\n        </script>\n        <!-- travel-manifest:end -->'
  perl -0777 -i -pe 's/<!-- travel-manifest:start -->.*?<!-- travel-manifest:end -->/$ENV{TRAVEL_BLOCK}/s' "$index_file"
  echo "Updated inline manifest in $index_file"
fi

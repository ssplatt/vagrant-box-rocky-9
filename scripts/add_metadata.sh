#!/usr/bin/env bash
set -e

PROVIDER=${PROVIDER:-"vmware_desktop"}
ARCHITECTURE=${ARCHITECTURE:-$(uname -m)}

if [[ "$ARCHITECTURE" == "x86_64" ]]; then
  ARCHITECTURE="amd64"
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/"
PROJECT_ROOT="$(dirname "$DIR")"

cd "$PROJECT_ROOT"

cat > "./$PROVIDER/metadata.json" <<EOL
{
  "provider": "$PROVIDER",
  "architecture": "$ARCHITECTURE"
}
EOL

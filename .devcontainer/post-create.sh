#!/usr/bin/env bash

set -euo pipefail

echo "== Flutter toolchain =="
flutter --version

echo "== Enable Flutter Web =="
flutter config --enable-web

echo "== Install project dependencies =="
flutter pub get

echo "== Environment summary =="
flutter doctor -v || true

cat <<'EOF'

Rumi Codespace is ready.

Run all checks:
  flutter analyze && flutter test

Start the web preview:
  flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000

Then open port 3000 from the Codespaces Ports panel.
EOF

#!/usr/bin/env bash
# Copia la app web (../index.html, fuentes e íconos) al bundle de iOS. Xcode lo corre antes de cada build.
set -euo pipefail
cd "$(dirname "$0")"
DEST=VorticeAureo/web
rm -rf "$DEST"; mkdir -p "$DEST"
cp ../index.html ../manifest.webmanifest "$DEST/"
cp -R ../fonts ../icons "$DEST/"

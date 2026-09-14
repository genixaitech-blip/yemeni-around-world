#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is required: https://docs.flutter.dev/get-started/install"
  exit 1
fi

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

flutter create --platforms=android,ios --org com.yemeniworld --project-name yemeni_world .
flutter pub get
flutter analyze
flutter test

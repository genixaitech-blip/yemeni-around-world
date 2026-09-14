#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

required=(
  pubspec.yaml
  lib/main.dart
  lib/core/app_router.dart
  lib/data/app_repository.dart
  lib/features/home/home_screen.dart
  lib/features/search/search_screen.dart
  lib/features/listings/listing_detail_screen.dart
  lib/features/requests/create_request_screen.dart
  lib/features/chat/chat_screen.dart
  supabase/migrations/202609140001_initial_schema.sql
  supabase/seed.sql
  test/mock_repository_test.dart
)

for path in "${required[@]}"; do
  test -s "$path" || { echo "Missing or empty: $path"; exit 1; }
done

if rg -n '(SUPABASE_SERVICE_ROLE(_KEY)?\s*[:=]|service_role\s*=|sk_live_|BEGIN (RSA|OPENSSH) PRIVATE KEY)' --glob '!tool/structure_check.sh' .; then
  echo "Potential secret found"
  exit 1
fi

test "$(rg -l 'enable row level security' supabase/migrations/*.sql | wc -l)" -ge 1
echo "Structure and secret scan passed."

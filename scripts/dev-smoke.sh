#!/usr/bin/env sh
set -euo pipefail

fail() { echo "[SMOKE] $1" >&2; exit 1; }

BACKEND_URL=${BACKEND_URL:-http://localhost:8080}
FRONTEND_URL=${FRONTEND_URL:-http://localhost:3000}

printf '[SMOKE] Checking backend /health... '
code=$(curl -s -o /dev/null -w '%{http_code}' "$BACKEND_URL/health" || echo 000)
[ "$code" = "200" ] || fail "Backend health failed (code=$code)"
echo OK

printf '[SMOKE] Checking backend /artists... '
code=$(curl -s -o /dev/null -w '%{http_code}' "$BACKEND_URL/artists" || echo 000)
[ "$code" = "200" ] || fail "/artists failed (code=$code)"
echo OK

printf '[SMOKE] Checking frontend root... '
code=$(curl -s -o /dev/null -w '%{http_code}' "$FRONTEND_URL/" || echo 000)
[ "$code" = "200" ] || fail "Frontend root failed (code=$code)"
echo OK

echo '[SMOKE] All checks passed.'

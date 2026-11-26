#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
pids=()
trap '[ ${#pids[@]} -eq 0 ] || kill "${pids[@]}" 2>/dev/null; rm -rf "$tmp"' EXIT

cap=10
sentence="Rendered by the page script"
append='document.body.append(["Rendered", "by", "the", "page", "script"].join(" "))'

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

free_port() {
  python3 -c 'import socket; s = socket.socket(); s.bind(("127.0.0.1", 0)); print(s.getsockname()[1]); s.close()'
}

read_page() {
  local out
  out="$(timeout $((cap + 5)) node "$tmp/read-page.mjs" "$url/$1")" || fail "$1 did not print within $((cap + 5)) s"
  grep -qF "$2" <<<"$out" || fail "$1 did not print its text: $out"
  ! grep -qF "document.body" <<<"$out" || fail "$1 printed its script source, not its visible text: $out"
}

cp "$root/skills/super-review/read-page.mjs" "$root/skills/super-review/package.json" "$tmp/"
(cd "$tmp" && npm install --no-audit --no-fund >/dev/null && npx patchright install chromium >/dev/null)

stalled="$(free_port)"
python3 -c 'import socket, sys, time; s = socket.socket(); s.bind(("127.0.0.1", int(sys.argv[1]))); s.listen(); time.sleep(3600)' "$stalled" &
pids+=($!)

mkdir "$tmp/site"
echo pong >"$tmp/site/ping"
printf '<!doctype html><body><script>%s</script></body>\n' "$append" >"$tmp/site/script.html"
printf '<!doctype html><body><script>fetch("ping").then(() => setTimeout(() => %s, 200))</script></body>\n' "$append" \
  >"$tmp/site/async.html"
printf '<!doctype html><body><script>setInterval(() => fetch("ping?" + Date.now()), 100); %s</script></body>\n' "$append" \
  >"$tmp/site/busy.html"
printf '<!doctype html><body><p>Static text beside a stalled image</p><img src="http://127.0.0.1:%s/stalled.png"></body>\n' "$stalled" \
  >"$tmp/site/stalled.html"

port="$(free_port)"
python3 -m http.server "$port" --bind 127.0.0.1 --directory "$tmp/site" >/dev/null 2>&1 &
pids+=($!)
url="http://127.0.0.1:$port"
ready=""
for _ in $(seq 50); do
  if curl -sf "$url/ping" >/dev/null; then
    ready=1
    break
  fi
  sleep 0.1
done
[ -n "$ready" ] || fail "the test server did not start on port $port"

html="$(curl -sf "$url/script.html")" || fail "curl could not fetch script.html"
! grep -qF "$sentence" <<<"$html" || fail "the sentence is in the served HTML, so the page proves nothing"
read_page script.html "$sentence"
read_page async.html "$sentence"
read_page busy.html "$sentence"

for target in "$url/missing.html" "http://127.0.0.1:$(free_port)/" "file://$tmp/site/script.html"; do
  if node "$tmp/read-page.mjs" "$target" >"$tmp/out" 2>"$tmp/err"; then fail "$target exited zero"; fi
  [ ! -s "$tmp/out" ] || fail "$target printed to stdout: $(cat "$tmp/out")"
  [ -s "$tmp/err" ] || fail "$target gave no reason on stderr"
done

read_page stalled.html "Static text beside a stalled image"

echo "read-page: all checks passed"

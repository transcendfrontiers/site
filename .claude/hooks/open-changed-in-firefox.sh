#!/bin/bash
# Stop hook: open pages changed during this turn in Firefox via the local server.
# A UserPromptSubmit hook touches $MARK at the start of each turn; anything newer than it changed this turn.
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
MARK="${TMPDIR:-/tmp}/tf-site-turn-start"
PORT=7777

[ -f "$MARK" ] || exit 0
changed=$(cd "$REPO" && find . -type f \( -name '*.html' -o -name '*.css' -o -name '*.js' \) -newer "$MARK" \
  -not -path './.git/*' -not -path './.playwright-mcp/*' -not -path './.claude/*')
rm -f "$MARK"
[ -z "$changed" ] && exit 0

if ! curl -s -o /dev/null "http://localhost:$PORT/"; then
  (cd "$REPO" && nohup python3 -m http.server "$PORT" >/tmp/halo-server.log 2>&1 &)
  sleep 1
fi

urls=$(echo "$changed" | while read -r f; do
  f="${f#./}"
  case "$f" in
    (*.html) p="${f%index.html}"; echo "http://localhost:$PORT/$p" ;;
    (*)      echo "http://localhost:$PORT/" ;;
  esac
done | sort -u | head -5)

for u in $urls; do open -a Firefox "$u"; done
echo "{\"systemMessage\": \"Opened in Firefox: $(echo $urls)\"}"

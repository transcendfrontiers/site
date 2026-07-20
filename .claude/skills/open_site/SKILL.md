---
description: Open the site locally — kills any existing server, starts a fresh Python static server from the repo root, and opens the correct URL in the browser.
trigger: open_site
---

# open_site skill

When the user types `/open_site` or asks to open the site, run the site locally and open it in the browser.

## How this site is built

Plain static HTML/CSS — no build step, no bundler. Everything is served directly from the repo root (`/Users/jessicatruong/Code/transcend-frontiers-site`). Python's built-in HTTP server is all that's needed.

## Steps to follow exactly

1. **Kill any previous instance** on the target port so re-runs are clean:
   ```bash
   pkill -f "python3 -m http.server 7777" 2>/dev/null; sleep 0.3
   ```

2. **Start the server** from the repo root on port 7777, logging to a temp file:
   ```bash
   cd /Users/jessicatruong/Code/transcend-frontiers-site && python3 -m http.server 7777 &>/tmp/halo-server.log &
   sleep 1
   ```

3. **Verify it's up** — check HTTP 200:
   ```bash
   curl -s -o /dev/null -w "%{http_code}" http://localhost:7777/
   ```
   If not 200, show the log: `cat /tmp/halo-server.log`

4. **Determine which URL to open:**
   - If the user typed a path hint (e.g. `/open_site halo` or "open the halo page"), open `http://localhost:7777/<hint>/`
   - If no hint given, look for the most recently modified HTML file to guess the right page. Check: `find . -name 'index.html' -not -path '*/.git/*' | xargs ls -t | head -5`
   - Default fallback: `http://localhost:7777/`

5. **Open** the URL:
   ```bash
   open <url>
   ```

6. **Report** the URL you opened and confirm the server is running. Mention that the server stays alive for the session (killing the terminal stops it).

## Port

Always use **7777**. This avoids conflicts with common dev servers (3000, 8080, etc.).

## Notes

- This is a GitHub Pages site with CNAME `transcendfrontiers.com`. The local server mirrors production exactly — no build needed.
- Pages live at directory paths: `/halo/`, `/apps/halo/privacy/`, `/apps/fabric-lens/privacy/`, etc.
- The root `index.html` is the main Transcend Frontiers landing page.

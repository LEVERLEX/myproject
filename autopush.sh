#!/data/data/com.termux/files/usr/bin/bash

set -e

REPO="$HOME/myproject"
DOCS="$REPO/docs"

cd "$REPO"

# Ensure docs directory exists
mkdir -p "$DOCS"

# Stage changes
git add .

# Commit if needed
if ! git diff --cached --quiet; then
    git commit -m "auto: system update $(date '+%Y-%m-%d %H:%M:%S')"
fi

# Versioning
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
PATCH=$((PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"

git tag $NEW_TAG 2>/dev/null || true

# Changelog
CHANGELOG="$REPO/CHANGELOG.md"
touch "$CHANGELOG"

echo -e "\n## $NEW_TAG - $(date +'%Y-%m-%d')" >> "$CHANGELOG"
git log $LAST_TAG..HEAD --pretty=format:"- %s" >> "$CHANGELOG" || true

# Dashboard files
echo "$NEW_TAG" > "$DOCS/version.txt"
git log -n 10 --pretty=format:"%h - %s (%ar)" > "$DOCS/commits.txt"
echo "Last deployment: $(date)" > "$DOCS/push.log"

# Ensure index.html exists
if [ ! -f "$DOCS/index.html" ]; then
cat > "$DOCS/index.html" <<EOF
<!DOCTYPE html>
<html>
<head>
<title>Production Dashboard</title>
<meta http-equiv="refresh" content="60">
<style>
body { font-family: Arial; padding: 20px; background: #111; color: #eee; }
h1 { color: #00ffcc; }
pre { background: #222; padding: 10px; }
</style>
</head>
<body>
<h1>Live Production Dashboard</h1>
<h2>Version</h2>
<pre id="version"></pre>
<h2>Recent Commits</h2>
<pre id="commits"></pre>
<h2>Status</h2>
<pre id="status"></pre>

<script>
async function loadData() {
  document.getElementById("version").innerText =
    await fetch("version.txt").then(r => r.text());
  document.getElementById("commits").innerText =
    await fetch("commits.txt").then(r => r.text());
  document.getElementById("status").innerText =
    await fetch("push.log").then(r => r.text());
}
loadData();
</script>
</body>
</html>
EOF
fi

git add .
git commit -m "auto: dashboard sync" || true

git push origin main --tags

echo "PRODUCTION DEPLOYMENT COMPLETE"

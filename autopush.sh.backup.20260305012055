#!/bin/bash
# ===== Ultimate Autopush =====
REPO="$HOME/myproject"
cd "$REPO" || exit

# ------------------------------
# Stage all changes
# ------------------------------
git add .

# ------------------------------
# Determine commit message
# ------------------------------
if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
    COMMIT_MSG="docs: updated documentation"
elif git diff --cached --name-only | grep -qE '\.(sh|bash)$'; then
    COMMIT_MSG="scripts: updated shell scripts"
elif git diff --cached --name-only | grep -qE '\.(js|ts|py|html)$'; then
    COMMIT_MSG="feat: updated code files"
else
    COMMIT_MSG="chore: miscellaneous changes"
fi

# Commit if there are changes
if git diff --cached --quiet; then
    echo "✅ No changes detected."
else
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
fi

# ------------------------------
# Tag new version (increment patch)
# ------------------------------
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
PATCH=$((PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
git tag $NEW_TAG 2>/dev/null || echo "🔖 Tag $NEW_TAG already exists"

# ------------------------------
# Update CHANGELOG.md
# ------------------------------
CHANGELOG_FILE="CHANGELOG.md"
[ ! -f "$CHANGELOG_FILE" ] && echo "# Changelog" > "$CHANGELOG_FILE"

if [ -n "$LAST_TAG" ]; then
    NEW_COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s")
else
    NEW_COMMITS=$(git log --pretty=format:"- %s")
fi

if [ -n "$NEW_COMMITS" ]; then
    echo -e "\n## $(date +'%Y-%m-%d') - $NEW_TAG" >> "$CHANGELOG_FILE"
    echo "$NEW_COMMITS" >> "$CHANGELOG_FILE"
    git add "$CHANGELOG_FILE"
    git commit -m "docs: update changelog" || true
fi

# ------------------------------
# Update Dashboard
# ------------------------------
DASHBOARD_DIR="dashboard"
mkdir -p "$DASHBOARD_DIR"

# Update dashboard files
git describe --tags --abbrev=0 2>/dev/null > "$DASHBOARD_DIR/version.txt"
git log -n 10 --pretty=format:"%h - %s (%ar)" > "$DASHBOARD_DIR/commits.txt"
echo "Last autopush: $(date)" > "$DASHBOARD_DIR/push.log"

git add "$DASHBOARD_DIR/version.txt" "$DASHBOARD_DIR/commits.txt" "$DASHBOARD_DIR/push.log"
git commit -m "chore: update dashboard" || true

# ------------------------------
# Push everything to GitHub
# ------------------------------
git push origin main --tags
echo "✅ Autopush complete!"

#!/bin/bash
# ===== Ultimate Autopush =====
git add .
if git diff --cached --name-only | grep -q '.'; then
    FILES_CHANGED=$(git diff --cached --name-only)
    COMMIT_MSG="Update: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/, $//')"
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else
    echo "✅ No changes detected."
fi

# Version tagging
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
PATCH=$((PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
git tag $NEW_TAG 2>/dev/null || echo "🔖 Tag $NEW_TAG already exists"

# CHANGELOG
CHANGELOG_FILE="CHANGELOG.md"
[ ! -f "$CHANGELOG_FILE" ] && echo "# Changelog" > "$CHANGELOG_FILE"
if [ -n "$LAST_TAG" ]; then
    NEW_COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s")
else
    NEW_COMMITS=$(git log --pretty=format:"- %s")
fi
if ! grep -q "$(date +'%Y-%m-%d')" "$CHANGELOG_FILE"; then
    echo -e "\n## $(date +'%Y-%m-%d') - $NEW_TAG" >> "$CHANGELOG_FILE"
    echo "$NEW_COMMITS" >> "$CHANGELOG_FILE"
    git add "$CHANGELOG_FILE"
    git commit -m "docs: update changelog" || true
fi

# Dashboard export
DASHBOARD_DIR="dashboard"
mkdir -p "$DASHBOARD_DIR"
git describe --tags --abbrev=0 2>/dev/null > "$DASHBOARD_DIR/version.txt"
git log -n 10 --pretty=format:"%h - %s (%ar)" > "$DASHBOARD_DIR/commits.txt"
echo "Last autopush: $(date)" > "$DASHBOARD_DIR/push.log"

# Push
git push origin main --tags
echo "✅ Autopush complete!"

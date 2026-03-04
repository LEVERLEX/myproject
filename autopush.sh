#!/bin/bash
# ===========================================
# LEVERLEX: Ultimate Autopush Script
# Features:
# - Smart commit messages
# - Automatic CHANGELOG.md creation/update
# - Version tagging
# - Autopush to GitHub
# - Dashboard export for GitHub Pages
# ===========================================

# ------------------------------
# Stage all changes
# ------------------------------
git add .

# ------------------------------
# Determine smart commit message
# ------------------------------
if git diff --cached --name-only | grep -q '.'; then
    FILES_CHANGED=$(git diff --cached --name-only)
    COMMIT_MSG="Update: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/, $//')"
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else
    echo "✅ No changes detected, skipping commit."
fi

# ------------------------------
# Version tagging
# ------------------------------
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
PATCH=$((PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
git tag $NEW_TAG || echo "🔖 Tag $NEW_TAG already exists or first commit."

# ------------------------------
# Auto CHANGELOG
# ------------------------------
CHANGELOG_FILE="CHANGELOG.md"

# Ensure changelog exists
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > $CHANGELOG_FILE
fi

# Get new commits since last tag or all commits if no tag
if [ -n "$LAST_TAG" ]; then
    NEW_COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s")
else
    NEW_COMMITS=$(git log --pretty=format:"- %s")
fi

# Append changelog only if today's date not present
if ! grep -q "$(date +'%Y-%m-%d')" $CHANGELOG_FILE; then
    echo -e "\n## $(date +'%Y-%m-%d') - $NEW_TAG" >> $CHANGELOG_FILE
    echo "$NEW_COMMITS" >> $CHANGELOG_FILE
    git add $CHANGELOG_FILE
    git commit -m "docs: initialize/update changelog" || echo "✅ No new changelog changes"
fi

# ------------------------------
# Export dashboard data
# ------------------------------
DASHBOARD_DIR="dashboard"
mkdir -p $DASHBOARD_DIR

git describe --tags --abbrev=0 2>/dev/null > $DASHBOARD_DIR/version.txt
git log -n 10 --pretty=format:"%h - %s (%ar)" > $DASHBOARD_DIR/commits.txt
echo "Last autopush completed on $(date)" > $DASHBOARD_DIR/push.log
# CHANGELOG.md already exists

# ------------------------------
# Push to GitHub
# ------------------------------
echo "🚀 Pushing commits, tags, and changelog to remote..."
git push origin main --tags

echo "✅ Autopush complete! Dashboard data updated in $DASHBOARD_DIR/"

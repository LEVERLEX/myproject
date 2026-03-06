#!/data/data/com.termux/files/usr/bin/bash

# ==============================
# MyProject Autopush Engine v2
# Fully Automated Git System
# ==============================

PROJECT_DIR="$HOME/myproject"
DOCS_DIR="$PROJECT_DIR/docs"
LOG_DIR="$PROJECT_DIR/logs"

VERSION_FILE="$DOCS_DIR/version.txt"
COMMITS_FILE="$DOCS_DIR/commits.txt"
CHANGELOG_FILE="$DOCS_DIR/CHANGELOG.md"
PUSH_LOG="$LOG_DIR/push.log"

cd "$PROJECT_DIR" || exit

mkdir -p "$DOCS_DIR"
mkdir -p "$LOG_DIR"

echo "===== AUTOPUSH RUN $(date) =====" >> "$PUSH_LOG"

# ==============================
# Detect Changes
# ==============================

git add .

if git diff --cached --quiet
then
    echo "No changes detected." >> "$PUSH_LOG"
    exit 0
fi

# ==============================
# Smart Commit Message
# ==============================

FILES=$(git diff --cached --name-only)

if echo "$FILES" | grep -qE '\.md$'; then
    COMMIT_MSG="docs: documentation update"
elif echo "$FILES" | grep -qE '\.html$'; then
    COMMIT_MSG="ui: dashboard update"
elif echo "$FILES" | grep -qE '\.sh$'; then
    COMMIT_MSG="scripts: automation update"
elif echo "$FILES" | grep -qE '\.(js|ts|py)$'; then
    COMMIT_MSG="feat: code improvements"
else
    COMMIT_MSG="chore: miscellaneous changes"
fi

echo "Commit message: $COMMIT_MSG" >> "$PUSH_LOG"

git commit -m "$COMMIT_MSG"

# ==============================
# Version System
# ==============================

if [ ! -f "$VERSION_FILE" ]; then
    echo "v0.1.0" > "$VERSION_FILE"
fi

CURRENT=$(cat "$VERSION_FILE")
BASE=${CURRENT%.*}
PATCH=${CURRENT##*.}

PATCH=$((PATCH+1))
NEW_VERSION="$BASE.$PATCH"

echo "$NEW_VERSION" > "$VERSION_FILE"

echo "Version bumped to $NEW_VERSION" >> "$PUSH_LOG"

git add "$VERSION_FILE"
git commit -m "chore: bump version to $NEW_VERSION"

# ==============================
# Update Commits Log
# ==============================

git log -n 10 --pretty=format:"%h - %s (%cd)" --date=short > "$COMMITS_FILE"

git add "$COMMITS_FILE"
git commit -m "chore: update commits log"

# ==============================
# Update Changelog
# ==============================

if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
fi

echo "" >> "$CHANGELOG_FILE"
echo "## $NEW_VERSION - $(date)" >> "$CHANGELOG_FILE"
echo "- $COMMIT_MSG" >> "$CHANGELOG_FILE"

git add "$CHANGELOG_FILE"
git commit -m "docs: update changelog"

# ==============================
# Push to GitHub
# ==============================

git push origin main >> "$PUSH_LOG" 2>&1

echo "Push completed at $(date)" >> "$PUSH_LOG"

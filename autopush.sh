#!/data/data/com.termux/files/usr/bin/bash

cd ~/myproject || exit

LOCKFILE=".autopush.lock"

# Prevent multiple instances
if [ -f "$LOCKFILE" ]; then
    echo "⚠ Autopush already running, skipping..."
    exit 0
fi

touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

echo "-----"
echo "AUTOPUSH RUN $(date)"

# Remove broken git lock if it exists
if [ -f ".git/index.lock" ]; then
    echo "Removing stale git lock"
    rm -f .git/index.lock
fi

# Sync with remote repository
git pull --rebase origin main

# Detect changes
if [ -n "$(git status --porcelain)" ]; then

    git add .

    # Smart commit detection
    if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
        COMMIT_MSG="docs: documentation update"

    elif git diff --cached --name-only | grep -qE '\.html$'; then
        COMMIT_MSG="ui: dashboard update"

    elif git diff --cached --name-only | grep -qE '\.sh$'; then
        COMMIT_MSG="scripts: automation update"

    elif git diff --cached --name-only | grep -qE '\.(js|ts|py)$'; then
        COMMIT_MSG="feat: code improvements"

    else
        COMMIT_MSG="chore: miscellaneous changes"
    fi

    echo "📝 Committing changes: $COMMIT_MSG"

    git commit -m "$COMMIT_MSG"

    # Version bump
    if [ ! -f docs/version.txt ]; then
        echo "v0.1.0" > docs/version.txt
    fi

    CURRENT=$(cat docs/version.txt)
    BASE=${CURRENT%.*}
    PATCH=${CURRENT##*.}

    PATCH=$((PATCH+1))
    NEW_VERSION="$BASE.$PATCH"

    echo "$NEW_VERSION" > docs/version.txt

    git add docs/version.txt
    git commit -m "chore: bump version to $NEW_VERSION"

    # Update commits log
    git log -n 10 --pretty=format:"%h - %s (%cd)" --date=short > docs/commits.txt
    git add docs/commits.txt
    git commit -m "chore: update commits log"

    # Update changelog
    if [ ! -f docs/CHANGELOG.md ]; then
        echo "# Changelog" > docs/CHANGELOG.md
    fi

    echo "" >> docs/CHANGELOG.md
    echo "## $NEW_VERSION - $(date)" >> docs/CHANGELOG.md
    echo "- $COMMIT_MSG" >> docs/CHANGELOG.md

    git add docs/CHANGELOG.md
    git commit -m "docs: update changelog"

    # Push to GitHub
    git push origin main

    echo "✅ Push completed $(date)"

else
    echo "⚡ No changes detected."
fi

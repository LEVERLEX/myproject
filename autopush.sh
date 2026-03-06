#!/data/data/com.termux/files/usr/bin/bash

cd ~/myproject || exit

LOCKFILE=".autopush.lock"

# Prevent multiple instances
if [ -f "$LOCKFILE" ]; then
    echo "⚠ Autopush already running, skipping..."
    exit 0
fi

touch "$LOCKFILE"

echo "-----"
echo "AUTOPUSH RUN $(date)"

# Remove broken git lock if it exists
if [ -f ".git/index.lock" ]; then
    echo "Removing stale git lock"
    rm -f .git/index.lock
fi

# Sync with remote
git pull --rebase origin main

# Detect changes
if [ -n "$(git status --porcelain)" ]; then

    git add .

    # Smart commit detection
    if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
        COMMIT_MSG="docs: update documentation"
    elif git diff --cached --name-only | grep -qE '\.(sh|bash)$'; then
        COMMIT_MSG="scripts: automation update"
    elif git diff --cached --name-only | grep -qE '\.(js|html|css)$'; then
        COMMIT_MSG="feat: frontend update"
    else
        COMMIT_MSG="chore: miscellaneous changes"
    fi

    echo "📝 Committing: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"

    # Update version
    VERSION_FILE="version.txt"
    if [ ! -f "$VERSION_FILE" ]; then
        echo "v0.1.0" > "$VERSION_FILE"
    fi

    VERSION=$(cat "$VERSION_FILE")
    NUM=${VERSION#v}
    MAJOR=$(echo $NUM | cut -d. -f1)
    MINOR=$(echo $NUM | cut -d. -f2)
    PATCH=$(echo $NUM | cut -d. -f3)

    PATCH=$((PATCH + 1))

    NEW_VERSION="v$MAJOR.$MINOR.$PATCH"
    echo $NEW_VERSION > $VERSION_FILE

    git add version.txt
    git commit -m "chore: bump version to $NEW_VERSION"

    # Update commit log
    git log -5 --pretty=format:"%h - %s (%cr)" > commits.txt
    git add commits.txt
    git commit -m "chore: update commits log"

    # Push
    git push origin main

    echo "🚀 Pushed successfully at $(date)"

else
    echo "⚡ No changes detected."
fi

# Release lock
rm -f "$LOCKFILE"

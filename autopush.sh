#!/data/data/com.termux/files/usr/bin/bash

PROJECT_DIR="$HOME/myproject"
cd "$PROJECT_DIR" || exit

LOCKFILE=".autopush.lock"
LOGFILE="$PROJECT_DIR/push.log"

# Prevent multiple instances
if [ -f "$LOCKFILE" ]; then
    echo "⚠ Autopush already running, skipping..." >> "$LOGFILE"
    exit 0
fi

touch "$LOCKFILE"
trap "rm -f $LOCKFILE" EXIT

echo "-----------------------------" >> "$LOGFILE"
echo "AUTOPUSH RUN $(date)" >> "$LOGFILE"

# Remove stale git lock
if [ -f ".git/index.lock" ]; then
    echo "Removing stale git lock" >> "$LOGFILE"
    rm -f .git/index.lock
fi

# Detect local changes
if [ -n "$(git status --porcelain)" ]; then

    git add .

    if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
        COMMIT_MSG="docs: documentation update"
    elif git diff --cached --name-only | grep -qE '\.html$'; then
        COMMIT_MSG="ui: dashboard update"
    elif git diff --cached --name-only | grep -qE '\.sh$'; then
        COMMIT_MSG="scripts: automation update"
    else
        COMMIT_MSG="chore: miscellaneous changes"
    fi

    echo "Committing: $COMMIT_MSG" >> "$LOGFILE"
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

    # Update commit log
    git log -n 10 --pretty=format:"%h - %s (%cd)" --date=short > docs/commits.txt
    git add docs/commits.txt
    git commit -m "chore: update commits log"

fi

# Sync with remote
echo "Syncing with remote..." >> "$LOGFILE"
git pull --rebase origin main >> "$LOGFILE" 2>&1

# Retry push up to 3 times
for i in 1 2 3
do
    git push origin main >> "$LOGFILE" 2>&1 && break
    echo "Push failed, retry $i..." >> "$LOGFILE"
    sleep 5
done

echo "Autopush cycle complete $(date)" >> "$LOGFILE"

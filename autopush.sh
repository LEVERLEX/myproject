#!/data/data/com.termux/files/usr/bin/bash
# ~/myproject/autopush.sh
# Fully automated Git autopush for MyProject

set -e

# Navigate to project
cd ~/myproject

# ===== DETERMINE SMART COMMIT MESSAGE =====
if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
    COMMIT_MSG="docs: update documentation"
elif git diff --cached --name-only | grep -qE '\.(sh|bash)$'; then
    COMMIT_MSG="scripts: update shell scripts"
elif git diff --cached --name-only | grep -qE '\.(js|ts|py|html|css)$'; then
    COMMIT_MSG="feat: update code/dashboard"
else
    COMMIT_MSG="chore: miscellaneous changes"
fi

# ===== AUTO-DETECT CHANGES =====
git add .

# Only commit if there are changes
if ! git diff --cached --quiet; then
    echo "📝 Committing changes: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"

    # ===== UPDATE VERSION =====
    if [ ! -f version.txt ]; then
        echo "v0.1.0" > version.txt
    fi

    OLD_VERSION=$(cat version.txt)
    # Increment patch version
    PATCH=$(echo $OLD_VERSION | awk -F. '{print $3+1}')
    NEW_VERSION="$(echo $OLD_VERSION | awk -F. '{print $1"."$2}').$PATCH"
    echo "$NEW_VERSION" > version.txt
    git add version.txt
    git commit -m "chore: bump version to $NEW_VERSION"

    # ===== UPDATE COMMITS LOG =====
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $COMMIT_MSG" >> commits.txt
    git add commits.txt
    git commit -m "chore: update commits log"

    # ===== UPDATE PUSH LOG =====
    echo "Pushed at $(date '+%Y-%m-%d %H:%M:%S')" >> push.log
    git add push.log
    git commit -m "chore: update push log"

    # ===== PUSH TO GITHUB =====
    git push origin main
    echo "✅ Push completed at $(date '+%Y-%m-%d %H:%M:%S')"

else
    echo "⚡ No changes detected."
fi

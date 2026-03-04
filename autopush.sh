#!/bin/bash

PROJECT_DIR="$HOME/myproject"
BRANCH="main"
REMOTE="origin"
VERSION_FILE="VERSION"

cd "$PROJECT_DIR" || exit 1

echo "🔄 Syncing with remote..."
git pull $REMOTE $BRANCH --no-rebase

if [[ -z $(git status --porcelain) ]]; then
    echo "✅ No changes detected."
    exit 0
fi

echo "📦 Adding changes..."
git add .

# ===== VERSION AUTO INCREMENT =====

if [ ! -f "$VERSION_FILE" ]; then
    echo "1.0.0" > $VERSION_FILE
fi

CURRENT_VERSION=$(cat $VERSION_FILE)

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

PATCH=$((PATCH + 1))

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "$NEW_VERSION" > $VERSION_FILE

git add $VERSION_FILE

echo "📝 Committing version $NEW_VERSION"
git commit -m "Release v$NEW_VERSION"

echo "🏷 Tagging version..."
git tag "v$NEW_VERSION"

echo "🚀 Pushing to GitHub..."
git push $REMOTE $BRANCH
git push $REMOTE --tags

echo "✅ Version $NEW_VERSION deployed successfully."

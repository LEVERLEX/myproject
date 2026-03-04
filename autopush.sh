#!/bin/bash

# ===============================
# ULTIMATE AUTOPUSH SYSTEM
# ===============================

PROJECT_DIR="$HOME/myproject"
BRANCH="main"
REMOTE="origin"

cd "$PROJECT_DIR" || {
    echo "❌ Project directory not found."
    exit 1
}

echo "🔄 Checking for updates from remote..."
git pull $REMOTE $BRANCH --no-rebase

echo "🔍 Checking for local changes..."

if [[ -z $(git status --porcelain) ]]; then
    echo "✅ No changes detected. Nothing to commit."
    exit 0
fi

echo "📦 Adding changes..."
git add .

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "📝 Committing changes..."
git commit -m "AutoSync: $TIMESTAMP"

echo "🚀 Pushing to GitHub..."
git push $REMOTE $BRANCH

if [ $? -eq 0 ]; then
    echo "✅ AUTOPUSH SUCCESSFUL at $TIMESTAMP"
else
    echo "❌ Push failed. Resolve conflicts manually."
fi

# ===== AUTOPUSH MAIN SECTION =====

# Stage all changes
git add .

# ===== DETERMINE SMART/AI-STYLE COMMIT MESSAGE =====
if git diff --cached --name-only | grep -q '.'; then
    FILES_CHANGED=$(git diff --cached --name-only)
    COMMIT_MSG="Update: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/, $//')"
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else
    echo "✅ No changes detected, skipping commit."
fi

# ===== TAGGING =====
# Optional: increment patch version automatically
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
IFS='.' read -r MAJOR MINOR PATCH <<< "${LAST_TAG#v}"
PATCH=$((PATCH + 1))
NEW_TAG="v${MAJOR}.${MINOR}.${PATCH}"
git tag $NEW_TAG || echo "🔖 Tag $NEW_TAG already exists or first commit."

# ===== AUTO CHANGELOG =====
CHANGELOG_FILE="CHANGELOG.md"

# Ensure the changelog file exists
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > $CHANGELOG_FILE
fi

# Get new commits since last tag or all if no tag
if [ -n "$LAST_TAG" ]; then
    NEW_COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s")
else
    NEW_COMMITS=$(git log --pretty=format:"- %s")
fi

# Append to changelog only if today's date not already present
if ! grep -q "$(date +'%Y-%m-%d')" $CHANGELOG_FILE; then
    echo -e "\n## $(date +'%Y-%m-%d') - $NEW_TAG" >> $CHANGELOG_FILE
    echo "$NEW_COMMITS" >> $CHANGELOG_FILE
    git add $CHANGELOG_FILE
    git commit -m "docs: initialize/update changelog" || echo "✅ No new changelog changes"
fi

# ===== PUSH TO REMOTE =====
echo "🚀 Pushing commits, tags, and changelog to remote..."
git push origin main --tags

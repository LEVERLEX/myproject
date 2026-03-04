# ===== AI-STYLE COMMIT SUMMARY =====
git add .

# Generate a concise description of changes
if git diff --cached --name-only | grep -q '.'; then
    FILES_CHANGED=$(git diff --cached --name-only)
    COMMIT_MSG="Update: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/, $//')"
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else

# ===== AUTO CHANGELOG =====
CHANGELOG_FILE="CHANGELOG.md"

# Create file if it doesn't exist
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > $CHANGELOG_FILE
fi

# Get the latest tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

# Get new commits since last tag
if [ -n "$LAST_TAG" ]; then
    NEW_COMMITS=$(git log $LAST_TAG..HEAD --pretty=format:"- %s")
else
    NEW_COMMITS=$(git log --pretty=format:"- %s")
fi

# Append to CHANGELOG.md if there are new commits
if [ -n "$NEW_COMMITS" ]; then
    echo -e "\n## $(date +'%Y-%m-%d') - $(git describe --tags --abbrev=0 2>/dev/null || echo 'v1.0.0')" >> $CHANGELOG_FILE
    echo "$NEW_COMMITS" >> $CHANGELOG_FILE
    git add $CHANGELOG_FILE
    git commit -m "docs: update changelog"
fi
    echo "✅ No changes detected."
fi

# ===== AI-STYLE COMMIT SUMMARY =====
git add .

# Generate a concise description of changes
if git diff --cached --name-only | grep -q '.'; then
    FILES_CHANGED=$(git diff --cached --name-only)
    COMMIT_MSG="Update: $(echo "$FILES_CHANGED" | tr '\n' ', ' | sed 's/, $//')"
    echo "📝 Committing changes with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else
    echo "✅ No changes detected."
fi

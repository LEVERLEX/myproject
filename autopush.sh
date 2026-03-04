# ===== DETERMINE SMART COMMIT MESSAGE =====
if git diff --cached --name-only | grep -qE '\.(md|txt)$'; then
    COMMIT_MSG="docs: updated documentation"
elif git diff --cached --name-only | grep -qE '\.(sh|bash)$'; then
    COMMIT_MSG="scripts: updated shell scripts"
elif git diff --cached --name-only | grep -qE '\.(js|ts|py)$'; then
    COMMIT_MSG="feat: updated code files"
else
    COMMIT_MSG="chore: miscellaneous changes"
fi

echo "📝 Committing changes with message: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

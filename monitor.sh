#!/bin/bash

#############################################
# EXTREME PRODUCTION AUTOPUSH SYSTEM
#############################################

PROJECT_DIR=~/myproject
LOGFILE=$PROJECT_DIR/autopush.log
LOCKFILE=$PROJECT_DIR/autopush.lock
VERSION_FILE=$PROJECT_DIR/VERSION
COMMITS_FILE=$PROJECT_DIR/COMMITS.md

cd $PROJECT_DIR || exit 1

#############################################
# COLORS
#############################################

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

#############################################
# LOCK SYSTEM (prevents double execution)
#############################################

if [ -f "$LOCKFILE" ]; then
    echo -e "${RED}⚠ Autopush already running${RESET}"
    exit 1
fi

touch $LOCKFILE

#############################################
# DASHBOARD HEADER
#############################################

echo ""
echo "-------------------------------------"
echo -e "${BLUE}AUTOPUSH PRODUCTION ENGINE${RESET}"
date
echo "-------------------------------------"

echo "Running diagnostics..."

#############################################
# VERIFY GIT REPOSITORY
#############################################

git rev-parse --is-inside-work-tree > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "${RED}Not a git repository${RESET}"
    rm -f $LOCKFILE
    exit 1
fi

#############################################
# FETCH REMOTE STATE
#############################################

echo "Syncing with remote..."
git fetch origin

#############################################
# DETECT CHANGES
#############################################

CHANGES=$(git status --porcelain)

if [ -z "$CHANGES" ]; then
    echo -e "${YELLOW}No changes detected${RESET}"
else

    echo -e "${GREEN}Changes detected${RESET}"

    #############################################
    # STAGE FILES
    #############################################

    git add .

    #############################################
    # AUTO COMMIT
    #############################################

    MESSAGE="auto: system update $(date '+%Y-%m-%d %H:%M:%S')"

    git commit -m "$MESSAGE"

fi

#############################################
# VERSION BUMP SYSTEM
#############################################

if [ -f "$VERSION_FILE" ]; then

    CURRENT=$(cat $VERSION_FILE)

    IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

    PATCH=$((PATCH+1))

    NEW="$MAJOR.$MINOR.$PATCH"

    echo $NEW > $VERSION_FILE

    git add $VERSION_FILE

    git commit -m "chore: bump version to v$NEW"

    echo -e "${GREEN}Version updated → $NEW${RESET}"

fi

#############################################
# COMMITS LOG
#############################################

git log --oneline -10 > $COMMITS_FILE
git add $COMMITS_FILE
git commit -m "chore: update commits log" 2>/dev/null

#############################################
# CHANGELOG UPDATE
#############################################

echo "Update $(date)" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs: update changelog" 2>/dev/null

#############################################
# PULL SAFE
#############################################

echo "Pulling latest remote updates..."
git pull --rebase origin main

#############################################
# PUSH SYSTEM
#############################################

echo "Pushing to remote..."

git push origin main

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Push successful${RESET}"
else
    echo -e "${RED}Push failed${RESET}"
fi

#############################################
# LOGGING
#############################################

echo "AUTOPUSH RUN $(date)" >> $LOGFILE
git status >> $LOGFILE

#############################################
# CLEANUP
#############################################

rm -f $LOCKFILE

echo ""
echo -e "${GREEN}Automation cycle complete${RESET}"
echo "-------------------------------------"

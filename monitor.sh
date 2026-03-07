#!/bin/bash

PROJECT=~/myproject
LOG=$PROJECT/autopush.log

clear

echo "===================================="
echo "   AUTOPUSH AUTOMATION DASHBOARD"
echo "===================================="
echo ""

echo "Project directory:"
echo $PROJECT
echo ""

echo "Git status:"
git -C $PROJECT status -s
echo ""

echo "Latest version:"
cat $PROJECT/VERSION
echo ""

echo "Last 5 commits:"
git -C $PROJECT log --oneline -5
echo ""

echo "Automation log:"
tail -n 10 $LOG
echo ""

echo "Running processes:"
pgrep crond
echo ""

echo "===================================="
echo "Dashboard refresh: $(date)"
echo "===================================="

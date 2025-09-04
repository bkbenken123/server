#!/bin/bash

# Configuration
REPO_DIR="/app"                      # Path to your repository inside container
BRANCH="main"                        # Branch to push to
GIT_EMAIL="kenxinqiliang@gmail.com"  # Your GitHub email
GIT_NAME="bkbenken123"               # Your GitHub username
GIT_REMOTE="origin"

# Argument: fast = check for changes, force = push anyway
MODE=$1

cd $REPO_DIR || exit 1

# Configure git identity
git config user.email "$GIT_EMAIL"
git config user.name "$GIT_NAME"

# Pull latest changes to avoid conflicts
git pull $GIT_REMOTE $BRANCH --rebase

# Check for changes
CHANGES=$(git status --porcelain)

if [[ "$MODE" == "force" || -n "$CHANGES" ]]; then
    git add Dockerfile server/
    git commit -m "Auto backup: $(date +'%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"
    git push $GIT_REMOTE $BRANCH
fi

#!/bin/bash

REPO_NAME=$1
USERNAME=$2
TOKEN=$GITHUB_TOKEN

# Validation
if [ -z "$REPO_NAME" ]; then
  echo "Error: repo name is required"
  exit 1
fi

if [ -z "$USERNAME" ]; then
  echo "Error: username is required"
  exit 1
fi

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is not set"
  exit 1
fi

echo "Starting setup..."
echo "Repo: $REPO_NAME | User: $USERNAME"

# Create repository
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: token $TOKEN" \
  -H "User-Agent: bash" \
  -H "Accept: application/vnd.github+json" \
  -d "{\"name\":\"$REPO_NAME\",\"private\":false}" \
  https://api.github.com/user/repos)

if [ "$HTTP_CODE" -eq 201 ]; then
  echo "Repository created"
elif [ "$HTTP_CODE" -eq 422 ]; then
  echo "Repository may already exist, continuing"
else
  echo "GitHub API failed with status $HTTP_CODE"
  exit 1
fi

# Initialize git if needed
if [ ! -d ".git" ]; then
  git init
fi

# Ensure git identity
git config user.name >/dev/null 2>&1 || git config --global user.name "Bicky"
git config user.email >/dev/null 2>&1 || git config --global user.email "your-email@example.com"

# Commit if changes exist
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "Initial commit"
else
  echo "No changes to commit"
fi

# Set branch
git branch -M main

# Configure remote
REMOTE_URL="https://github.com/$USERNAME/$REPO_NAME.git"
git remote remove origin 2>/dev/null
git remote add origin "$REMOTE_URL"

echo "Remote set to $REMOTE_URL"

# Push
git push -u origin main
if [ $? -ne 0 ]; then
  echo "Push failed"
  exit 1
fi

echo "Done"
echo "Repository URL: https://github.com/$USERNAME/$REPO_NAME"
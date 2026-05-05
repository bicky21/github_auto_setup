#!/bin/bash

REPO_NAME=$1
USERNAME=$2
TOKEN=$GITHUB_TOKEN

if [ -z "$TOKEN" ]; then
  echo "❌ GITHUB_TOKEN not set!"
  exit 1
fi

echo "Creating GitHub repository..."

curl -s -H "Authorization: token $TOKEN" \
     -H "User-Agent: bash" \
     -d "{\"name\":\"$REPO_NAME\",\"private\":false}" \
     https://api.github.com/user/repos

echo "Repo created"

git init
git add .
git commit -m "Initial commit"
git branch -M main

git remote add origin https://github.com/$USERNAME/$REPO_NAME.git

# Use credential manager
git config --global credential.helper store

git push -u origin main

echo "Done!"
echo "https://github.com/$USERNAME/$REPO_NAME"
#!/bin/bash

# Script to help set up GitHub repository for your blog
# Usage: ./setup-github.sh YOUR_GITHUB_USERNAME

if [ -z "$1" ]; then
    echo "Usage: ./setup-github.sh YOUR_GITHUB_USERNAME"
    echo "Example: ./setup-github.sh johndoe"
    exit 1
fi

USERNAME=$1
REPO_NAME="${USERNAME}.github.io"

echo "🚀 Setting up GitHub repository for your blog..."
echo ""
echo "Repository name: $REPO_NAME"
echo ""

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
fi

# Add all files
echo "Adding files to git..."
git add .

# Create initial commit
echo "Creating initial commit..."
git commit -m "Initial commit: Jekyll blog setup"

# Check if remote already exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "Remote 'origin' already exists. Updating..."
    git remote set-url origin "https://github.com/${USERNAME}/${REPO_NAME}.git"
else
    echo "Adding remote repository..."
    git remote add origin "https://github.com/${USERNAME}/${REPO_NAME}.git"
fi

# Rename branch to main
git branch -M main

echo ""
echo "✅ Git setup complete!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Create the repository on GitHub:"
echo "   - Go to https://github.com/new"
echo "   - Repository name: $REPO_NAME"
echo "   - Make it Public"
echo "   - DO NOT initialize with README, .gitignore, or license"
echo "   - Click 'Create repository'"
echo ""
echo "2. Push your code:"
echo "   git push -u origin main"
echo ""
echo "3. Enable GitHub Pages:"
echo "   - Go to Settings > Pages"
echo "   - Source: Deploy from a branch"
echo "   - Branch: main, folder: / (root)"
echo "   - Click Save"
echo ""
echo "4. Update _config.yml with your URL:"
echo "   url: \"https://${USERNAME}.github.io\""
echo ""
echo "Your blog will be available at: https://${USERNAME}.github.io"
echo ""
echo "Note: It may take a few minutes for the site to be available."


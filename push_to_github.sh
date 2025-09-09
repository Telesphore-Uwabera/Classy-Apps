#!/bin/bash

echo "🚀 Pushing Classy Apps Firebase Migration to GitHub..."
echo ""
echo "This script will help you push your Firebase migration to GitHub."
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository. Please run this from the project root."
    exit 1
fi

# Check if we have commits
if [ -z "$(git log --oneline -1 2>/dev/null)" ]; then
    echo "❌ No commits found. Please commit your changes first."
    exit 1
fi

echo "✅ Git repository found with commits."
echo ""

# Try HTTPS method first
echo "🔄 Attempting to push via HTTPS..."
git remote set-url origin https://github.com/Telesphore-Uwabera/Classy-Apps.git

echo "📝 When prompted for credentials:"
echo "   Username: Telesphore-Uwabera"
echo "   Password: Use your Personal Access Token (NOT your GitHub password)"
echo ""
echo "💡 If you don't have a Personal Access Token:"
echo "   1. Go to GitHub.com → Settings → Developer settings → Personal access tokens"
echo "   2. Generate new token with 'repo' permissions"
echo "   3. Copy the token and use it as password"
echo ""

read -p "Press Enter to continue with push..."
git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Your Firebase migration has been pushed to GitHub!"
    echo "🔗 Repository: https://github.com/Telesphore-Uwabera/Classy-Apps"
    echo ""
    echo "✅ What was pushed:"
    echo "   • Complete Firebase migration for all 3 apps"
    echo "   • Removed all Laravel dependencies"
    echo "   • Updated README with Firebase-only architecture"
    echo "   • Fixed all compilation errors"
    echo "   • Added fallback mechanisms for web compatibility"
    echo ""
else
    echo ""
    echo "❌ Push failed. This is usually due to authentication issues."
    echo ""
    echo "🔧 Troubleshooting options:"
    echo "   1. Make sure you have a Personal Access Token for Telesphore-Uwabera account"
    echo "   2. Try running: git config --global credential.helper store"
    echo "   3. Or use SSH: git remote set-url origin git@github.com:Telesphore-Uwabera/Classy-Apps.git"
    echo ""
fi

#!/bin/bash

echo "🧹 Cleaning up Laravel dependencies for Firebase-only setup..."

# Remove Laravel-specific files
echo "📁 Removing Laravel backend files..."
rm -rf Backend/
rm -f composer.json
rm -f composer.lock

# Remove database files
echo "🗄️ Removing SQLite database files..."
rm -rf database/
rm -f *.sqlite
rm -f *.db

# Remove Laravel storage
echo "💾 Removing Laravel storage..."
rm -rf storage/

# Remove Laravel config files
echo "⚙️ Removing Laravel config files..."
rm -f .env.example
rm -f artisan
rm -f phpunit.xml
rm -f webpack.mix.js
rm -f package.json
rm -f package-lock.json

# Remove vendor directory if exists
echo "📦 Removing vendor directory..."
rm -rf vendor/

# Remove node_modules if exists
echo "📦 Removing node_modules..."
rm -rf node_modules/

# Remove Laravel-specific directories
echo "📁 Removing Laravel directories..."
rm -rf bootstrap/
rm -rf config/
rm -rf resources/
rm -rf routes/
rm -rf tests/

# Clean up any remaining Laravel files
echo "🧽 Cleaning up remaining Laravel files..."
find . -name "*.php" -not -path "./Apps/*" -delete
find . -name "artisan" -delete
find . -name "composer.json" -delete
find . -name "composer.lock" -delete

echo "✅ Laravel cleanup completed!"
echo ""
echo "🔥 Your project is now Firebase-only!"
echo "📋 Next steps:"
echo "   1. Update .env file with Firebase configuration"
echo "   2. Generate real Firebase config files for all apps"
echo "   3. Test Firebase connectivity"
echo ""
echo "📁 Remaining structure:"
echo "   - Apps/ (Customer, Vendor, Driver, Admin)"
echo "   - README.md"
echo "   - Firebase configuration files"
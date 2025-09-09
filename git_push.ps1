# Disable git pager
$env:GIT_PAGER = ""

# Add all files
Write-Host "Adding files..."
git add .

# Commit changes
Write-Host "Committing changes..."
git commit -m "Clean up repository - keep only current local files"

# Push to main branch
Write-Host "Pushing to main branch..."
git push origin main

Write-Host "Done!"

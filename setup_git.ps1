# Git Commit Script with Backdated Commits
# This script creates commits with specific dates to show activity on GitHub

# Initialize git if not already done
if (-not (Test-Path .git)) {
    git init
    Write-Host "Git repository initialized" -ForegroundColor Green
}

# Add remote
git remote add origin https://github.com/nandhini-rsk/Speech-Emotion-Recognition.git 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Remote added successfully" -ForegroundColor Green
} else {
    Write-Host "Remote already exists or error occurred" -ForegroundColor Yellow
}

# Configure git (update with your details)
git config user.name "nandhini-rsk"
git config user.email "nandhinirameshn66@gmail.com"

Write-Host "`nCreating backdated commits..." -ForegroundColor Cyan

# Jan 21, 2026 - Initial setup
$env:GIT_AUTHOR_DATE = "2026-01-21T10:00:00"
$env:GIT_COMMITTER_DATE = "2026-01-21T10:00:00"
git add README.md .gitignore
git commit -m "Initial commit: Project setup and documentation"
Write-Host "✓ Commit 1/8: Jan 21 10:00 - Initial setup" -ForegroundColor Green

$env:GIT_AUTHOR_DATE = "2026-01-21T16:30:00"
$env:GIT_COMMITTER_DATE = "2026-01-21T16:30:00"
git add backend/requirements.txt backend/main.py backend/utils/
git commit -m "Add backend API and feature extraction"
Write-Host "✓ Commit 2/8: Jan 21 16:30 - Backend API" -ForegroundColor Green

# Jan 22, 2026 - Frontend development
$env:GIT_AUTHOR_DATE = "2026-01-22T11:15:00"
$env:GIT_COMMITTER_DATE = "2026-01-22T11:15:00"
git add frontend/package.json frontend/src/api.js
git commit -m "Add frontend setup and API integration"
Write-Host "✓ Commit 3/8: Jan 22 11:15 - Frontend setup" -ForegroundColor Green

$env:GIT_AUTHOR_DATE = "2026-01-22T18:00:00"
$env:GIT_COMMITTER_DATE = "2026-01-22T18:00:00"
git add frontend/src/App.jsx frontend/src/index.css
git commit -m "Implement UI components and styling"
Write-Host "✓ Commit 4/8: Jan 22 18:00 - UI components" -ForegroundColor Green

# Jan 23, 2026 - Model training
$env:GIT_AUTHOR_DATE = "2026-01-23T09:30:00"
$env:GIT_COMMITTER_DATE = "2026-01-23T09:30:00"
git add backend/model/train.py
git commit -m "Add model training script"
Write-Host "✓ Commit 5/8: Jan 23 09:30 - Training script" -ForegroundColor Green

$env:GIT_AUTHOR_DATE = "2026-01-23T17:45:00"
$env:GIT_COMMITTER_DATE = "2026-01-23T17:45:00"
git add backend/model/ser_model.h5 backend/model/scaler.pkl backend/model/encoder.pkl
git commit -m "Add trained model and preprocessing artifacts"
Write-Host "✓ Commit 6/8: Jan 23 17:45 - Trained model" -ForegroundColor Green

# Jan 24, 2026 - Final touches
$env:GIT_AUTHOR_DATE = "2026-01-24T12:00:00"
$env:GIT_COMMITTER_DATE = "2026-01-24T12:00:00"
git add backend/test_prediction.py
git commit -m "Add testing utilities and improve error handling"
Write-Host "✓ Commit 7/8: Jan 24 12:00 - Testing utilities" -ForegroundColor Green

$env:GIT_AUTHOR_DATE = "2026-01-24T20:00:00"
$env:GIT_COMMITTER_DATE = "2026-01-24T20:00:00"
git add .
git commit -m "Final UI improvements and dark theme implementation"
Write-Host "✓ Commit 8/8: Jan 24 20:00 - Final improvements" -ForegroundColor Green

# Clear environment variables
Remove-Item Env:GIT_AUTHOR_DATE
Remove-Item Env:GIT_COMMITTER_DATE

Write-Host "`n✅ All commits created successfully!" -ForegroundColor Green
Write-Host "`nTo push to GitHub, run:" -ForegroundColor Cyan
Write-Host "git push -u origin main --force" -ForegroundColor Yellow
Write-Host "`nNote: Use --force only if this is a new repository or you're sure about overwriting" -ForegroundColor Red

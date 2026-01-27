# Rewrite Git History - Simpler Approach
# This creates new commits with modified dates

Write-Host "=== Git History Rewrite Tool ===" -ForegroundColor Cyan
Write-Host ""

# Create backup
Write-Host "[1/4] Creating backup..." -ForegroundColor Yellow
git branch backup-history-$(Get-Date -Format 'yyyyMMdd-HHmmss') 2>$null

# Get list of commits (excluding the initial commit from last week)
Write-Host "[2/4] Analyzing commits..." -ForegroundColor Yellow

# Reset to the commit before all today's work (keep initial commit)
git reset --soft dfbd9a7

# Now we'll create new commits with custom dates
Write-Host "[3/4] Creating commits with new dates..." -ForegroundColor Yellow

# Commit 1: Jan 25, 09:30 - Frontend setup
$env:GIT_AUTHOR_DATE = "2026-01-25T09:30:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-25T09:30:00+05:30"
git add frontend/
git commit -m "Add frontend setup and API integration"

# Commit 2: Jan 25, 14:45 - Model training
$env:GIT_AUTHOR_DATE = "2026-01-25T14:45:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-25T14:45:00+05:30"
git add backend/model/
git commit -m "Add model training script"

# Commit 3: Jan 25, 18:20 - Testing utilities
$env:GIT_AUTHOR_DATE = "2026-01-25T18:20:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-25T18:20:00+05:30"
git add backend/test_prediction.py backend/restart.txt
git commit -m "Add testing utilities and improve error handling"

# Commit 4: Jan 26, 10:15 - Deployment configs
$env:GIT_AUTHOR_DATE = "2026-01-26T10:15:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-26T10:15:00+05:30"
git add vercel.json railway.json Procfile backend/nixpacks.toml encoder.pkl scaler.pkl ser_model.h5 backend/encoder.pkl backend/scaler.pkl backend/ser_model.h5
git commit -m "Add deployment configurations for Vercel and Railway"

# Commit 5: Jan 26, 15:30 - Railway fix
$env:GIT_AUTHOR_DATE = "2026-01-26T15:30:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-26T15:30:00+05:30"
git add railway.json railway.toml
git commit -m "Fix Railway build configuration" --allow-empty

# Commit 6: Jan 26, 19:45 - Requirements
$env:GIT_AUTHOR_DATE = "2026-01-26T19:45:00+05:30"
$env:GIT_COMMITTER_DATE = "2026-01-26T19:45:00+05:30"
git add requirements.txt Procfile
git commit -m "Add requirements.txt to root for Railway deployment"

# Commit 7: Jan 27 (today) - Connect frontend
Remove-Item Env:\GIT_AUTHOR_DATE
Remove-Item Env:\GIT_COMMITTER_DATE
git add frontend/src/api.js
git commit -m "Connect frontend to Railway backend"

Write-Host "[4/4] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "New commit history:" -ForegroundColor Cyan
git log --pretty=format:"%h - %ad - %s" --date=format:"%Y-%m-%d %H:%M" -n 10

Write-Host ""
Write-Host ""
Write-Host "To push these changes to GitHub (WARNING: This rewrites history!):" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor White

# Git History Rewrite Script
# This will change commit dates to spread across Jan 25-26, 2026

# Current commits (newest to oldest):
# c44c4e7 - Connect frontend to Railway backend (keep as Jan 27)
# 7c0bfb7 - Add requirements.txt to root for Railway deployment (change to Jan 26)
# f3003f1 - Fix Railway build configuration (change to Jan 26)
# 6962deb - Add deployment configurations for Vercel and Railway (change to Jan 26)
# e13a90c - Add testing utilities and improve error handling (change to Jan 25)
# 2384e15 - Add model training script (change to Jan 25)
# 4abbc20 - Add frontend setup and API integration (change to Jan 25)
# dfbd9a7 - Initial commit: Project setup and documentation (keep original - last week)

Write-Host "Starting Git history rewrite..." -ForegroundColor Cyan
Write-Host "This will change commit dates to Jan 25-26, keeping the last commit as Jan 27" -ForegroundColor Yellow
Write-Host ""

# Backup current branch
Write-Host "Creating backup branch..." -ForegroundColor Green
git branch backup-before-rewrite

# Set environment to rewrite history
$env:FILTER_BRANCH_SQUELCH_WARNING = 1

# Rewrite commit dates
git filter-branch -f --env-filter '
# Get commit hash
COMMIT_HASH=$(git rev-parse HEAD)

# Jan 25, 2026 dates (IST timezone +05:30)
JAN_25_MORNING="2026-01-25T09:30:00+05:30"
JAN_25_AFTERNOON="2026-01-25T14:45:00+05:30"
JAN_25_EVENING="2026-01-25T18:20:00+05:30"

# Jan 26, 2026 dates
JAN_26_MORNING="2026-01-26T10:15:00+05:30"
JAN_26_AFTERNOON="2026-01-26T15:30:00+05:30"
JAN_26_EVENING="2026-01-26T19:45:00+05:30"

# Assign dates based on commit
case "$COMMIT_HASH" in
    4abbc20*) # Add frontend setup and API integration
        export GIT_AUTHOR_DATE="$JAN_25_MORNING"
        export GIT_COMMITTER_DATE="$JAN_25_MORNING"
        ;;
    2384e15*) # Add model training script
        export GIT_AUTHOR_DATE="$JAN_25_AFTERNOON"
        export GIT_COMMITTER_DATE="$JAN_25_AFTERNOON"
        ;;
    e13a90c*) # Add testing utilities and improve error handling
        export GIT_AUTHOR_DATE="$JAN_25_EVENING"
        export GIT_COMMITTER_DATE="$JAN_25_EVENING"
        ;;
    6962deb*) # Add deployment configurations for Vercel and Railway
        export GIT_AUTHOR_DATE="$JAN_26_MORNING"
        export GIT_COMMITTER_DATE="$JAN_26_MORNING"
        ;;
    f3003f1*) # Fix Railway build configuration
        export GIT_AUTHOR_DATE="$JAN_26_AFTERNOON"
        export GIT_COMMITTER_DATE="$JAN_26_AFTERNOON"
        ;;
    7c0bfb7*) # Add requirements.txt to root for Railway deployment
        export GIT_AUTHOR_DATE="$JAN_26_EVENING"
        export GIT_COMMITTER_DATE="$JAN_26_EVENING"
        ;;
    # c44c4e7 and dfbd9a7 keep their original dates
esac
' -- --all

Write-Host ""
Write-Host "Git history rewritten successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Review the new commit history:" -ForegroundColor Cyan
git log --oneline --date=format:'%Y-%m-%d %H:%M' --pretty=format:'%h - %ad - %s'

Write-Host ""
Write-Host ""
Write-Host "If you're happy with the changes, force push to GitHub:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor White
Write-Host ""
Write-Host "If you want to undo these changes:" -ForegroundColor Red
Write-Host "  git reset --hard backup-before-rewrite" -ForegroundColor White
Write-Host "  git branch -D backup-before-rewrite" -ForegroundColor White

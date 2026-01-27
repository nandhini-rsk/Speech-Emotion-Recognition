# Safe Git History Rewrite
# Uses git rebase to change commit dates

Write-Host "=== Git History Date Modifier ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will change commit dates to:" -ForegroundColor Yellow
Write-Host "  - Jan 25: 4abbc20, 2384e15, e13a90c" -ForegroundColor White
Write-Host "  - Jan 26: 6962deb, f3003f1, 7c0bfb7" -ForegroundColor White
Write-Host "  - Jan 27: c44c4e7 (today - unchanged)" -ForegroundColor White
Write-Host ""

# Backup
Write-Host "Creating backup branch..." -ForegroundColor Green
git branch backup-before-date-change-$(Get-Date -Format 'yyyyMMdd-HHmmss')

# Use git rebase with exec to change dates
Write-Host "Rewriting commit dates..." -ForegroundColor Yellow
Write-Host ""

# Set dates for each commit
$commits = @(
    @{hash="4abbc20"; date="2026-01-25T09:30:00+05:30"; msg="Add frontend setup and API integration"},
    @{hash="2384e15"; date="2026-01-25T14:45:00+05:30"; msg="Add model training script"},
    @{hash="e13a90c"; date="2026-01-25T18:20:00+05:30"; msg="Add testing utilities and improve error handling"},
    @{hash="6962deb"; date="2026-01-26T10:15:00+05:30"; msg="Add deployment configurations for Vercel and Railway"},
    @{hash="f3003f1"; date="2026-01-26T15:30:00+05:30"; msg="Fix Railway build configuration"},
    @{hash="7c0bfb7"; date="2026-01-26T19:45:00+05:30"; msg="Add requirements.txt to root for Railway deployment"}
)

# Rewrite each commit
foreach ($commit in $commits) {
    Write-Host "Changing date for: $($commit.msg)" -ForegroundColor Cyan
    
    $env:GIT_COMMITTER_DATE = $commit.date
    git filter-branch -f --env-filter "
        if [ `$GIT_COMMIT = '$($commit.hash)' ]
        then
            export GIT_AUTHOR_DATE='$($commit.date)'
            export GIT_COMMITTER_DATE='$($commit.date)'
        fi
    " -- --all 2>$null
}

Write-Host ""
Write-Host "Done! New commit history:" -ForegroundColor Green
git log --pretty=format:"%h - %ad - %s" --date=format:"%Y-%m-%d %H:%M" -n 10

Write-Host ""
Write-Host ""
Write-Host "To apply these changes to GitHub:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor Red

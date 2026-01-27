# Git History Date Modifier - Only Jan 27 Commits
# This will ONLY change commits made on Jan 27, keeping older commits unchanged

Write-Host "=== Git Commit Date Modifier ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will change ONLY Jan 27 commits to Jan 25-26" -ForegroundColor Yellow
Write-Host "Commits before Jan 25 will NOT be touched" -ForegroundColor Green
Write-Host ""

# Backup
Write-Host "Creating backup branch..." -ForegroundColor Green
$backupBranch = "backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
git branch $backupBranch
Write-Host "Backup created: $backupBranch" -ForegroundColor Gray
Write-Host ""

Write-Host "Rewriting commit dates..." -ForegroundColor Yellow

$env:FILTER_BRANCH_SQUELCH_WARNING = "1"

git filter-branch -f --env-filter '
COMMIT_HASH=$(git log -1 --format="%H")

case "$COMMIT_HASH" in
    4abbc20*) 
        export GIT_AUTHOR_DATE="2026-01-25T09:30:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-25T09:30:00+05:30"
        ;;
    2384e15*) 
        export GIT_AUTHOR_DATE="2026-01-25T14:45:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-25T14:45:00+05:30"
        ;;
    e13a90c*) 
        export GIT_AUTHOR_DATE="2026-01-25T18:20:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-25T18:20:00+05:30"
        ;;
    6962deb*) 
        export GIT_AUTHOR_DATE="2026-01-26T10:15:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-26T10:15:00+05:30"
        ;;
    f3003f1*) 
        export GIT_AUTHOR_DATE="2026-01-26T15:30:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-26T15:30:00+05:30"
        ;;
    7c0bfb7*) 
        export GIT_AUTHOR_DATE="2026-01-26T19:45:00+05:30"
        export GIT_COMMITTER_DATE="2026-01-26T19:45:00+05:30"
        ;;
esac
' HEAD~7..HEAD 2>&1 | Out-Null

Write-Host ""
Write-Host "Done! New commit history:" -ForegroundColor Green
Write-Host ""
git log --pretty=format:"%h - %ad - %s" --date=format:"%Y-%m-%d %H:%M" -n 10

Write-Host ""
Write-Host ""
Write-Host "Summary of changes:" -ForegroundColor Cyan
Write-Host "  Commits before Jan 25: UNCHANGED" -ForegroundColor Green
Write-Host "  Jan 25: 3 commits" -ForegroundColor White
Write-Host "  Jan 26: 3 commits" -ForegroundColor White
Write-Host "  Jan 27: 1 commit" -ForegroundColor White
Write-Host ""
Write-Host "To push to GitHub:" -ForegroundColor Yellow
Write-Host "  git push origin main --force" -ForegroundColor Red
Write-Host ""
Write-Host "To undo:" -ForegroundColor Gray
Write-Host "  git reset --hard $backupBranch" -ForegroundColor Gray

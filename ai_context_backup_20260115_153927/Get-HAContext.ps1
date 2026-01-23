# HAC PowerShell Companion - View HA diagnostic sessions from Windows
param(
    [switch]$Latest,
    [switch]$ListSessions,
    [string]$SessionID,
    [switch]$Baseline
)

$HAPath = "\\homeassistant.local\config\ai_context"

if ($Baseline) {
    Write-Host "`n=== BASELINE SUMMARY ===" -ForegroundColor Cyan
    Get-Content "$HAPath\BASELINE_SUMMARY.txt"
    exit
}

if ($ListSessions) {
    Write-Host "`n=== AVAILABLE SESSIONS ===" -ForegroundColor Cyan
    Get-ChildItem "$HAPath\sessions" -Directory |
        Sort-Object Name -Descending |
        Select-Object -First 10 |
        ForEach-Object { 
            $size = (Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1KB
            Write-Host "$($_.Name) - $([math]::Round($size, 2)) KB"
        }
    exit
}

if ($Latest) {
    $SessionPath = "$HAPath\latest_session"
} elseif ($SessionID) {
    $SessionPath = "$HAPath\sessions\$SessionID"
} else {
    Write-Host "HAC PowerShell Companion" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  Get-HAContext -Latest              # View latest diagnostic"
    Write-Host "  Get-HAContext -ListSessions        # List all sessions"
    Write-Host "  Get-HAContext -SessionID 20260106_215431"
    Write-Host "  Get-HAContext -Baseline            # View baseline summary"
    Write-Host ""
    Write-Host "Learnings:" -ForegroundColor Cyan
    Get-Content "$HAPath\session_learnings.txt" -Tail 5
    exit
}

if (Test-Path $SessionPath) {
    Write-Host "`n=== SESSION: $(Split-Path $SessionPath -Leaf) ===" -ForegroundColor Green
    
    # Check for new HAC format
    if (Test-Path "$SessionPath\config_check.txt") {
        Write-Host "`n📊 Config Status:" -ForegroundColor Cyan
        Get-Content "$SessionPath\config_check.txt"
        
        Write-Host "`n⚠️  Recent Errors:" -ForegroundColor Cyan
        Get-Content "$SessionPath\recent_errors.txt"
        
        Write-Host "`n🤖 Sample Automations:" -ForegroundColor Cyan
        Get-Content "$SessionPath\automation_names.txt"
    }
    # Fallback to old format
    elseif (Test-Path "$SessionPath\ai_summary.txt") {
        Get-Content "$SessionPath\ai_summary.txt"
    }
    
    Write-Host "`n📁 Available Files:" -ForegroundColor Cyan
    Get-ChildItem $SessionPath -File | ForEach-Object {
        Write-Host "  • $($_.Name) - $([math]::Round($_.Length/1KB, 2)) KB"
    }
    
    Write-Host "`n💡 View file: Get-Content '$SessionPath\[filename]'" -ForegroundColor Yellow
} else {
    Write-Host "❌ Session not found: $SessionPath" -ForegroundColor Red
}

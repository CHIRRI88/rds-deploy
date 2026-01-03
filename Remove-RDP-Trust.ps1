# =============================================================================
# Remove-RDP-Trust.ps1
# Purpose: Resets RDP certificate trust entries for CHIRRI RDS servers
# Usage:   irm 'https://raw.githubusercontent.com/CHIRRI88/rds-deploy/main/Remove-RDP-Trust.ps1' | iex
# =============================================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CHIRRI RDP Certificate Trust Reset" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$servers = @("192.168.1.18", "192.168.1.218")

# Remove Servers key entries (contains CertHash)
foreach ($server in $servers) {
    $path = "HKCU:\Software\Microsoft\Terminal Server Client\Servers\$server"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
        Write-Host "[OK] Removed CertHash entry for $server" -ForegroundColor Green
    } else {
        Write-Host "[--] No CertHash entry found for $server" -ForegroundColor Yellow
    }
}

# Remove LocalDevices entries
$localDevicesPath = "HKCU:\Software\Microsoft\Terminal Server Client\LocalDevices"
if (Test-Path $localDevicesPath) {
    foreach ($server in $servers) {
        $props = Get-ItemProperty -Path $localDevicesPath -ErrorAction SilentlyContinue
        if ($props.$server) {
            Remove-ItemProperty -Path $localDevicesPath -Name $server -ErrorAction SilentlyContinue
            Write-Host "[OK] Removed LocalDevices entry for $server" -ForegroundColor Green
        } else {
            Write-Host "[--] No LocalDevices entry found for $server" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Reset Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This endpoint will now prompt for certificate trust" -ForegroundColor White
Write-Host "on the next RDP connection to either RDS server." -ForegroundColor White
Write-Host ""

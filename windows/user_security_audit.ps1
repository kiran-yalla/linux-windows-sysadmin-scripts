<#
.SYNOPSIS
    windows/user_security_audit.ps1

    Audits local/domain user accounts on a Windows server for common
    security hygiene issues: stale accounts, accounts with passwords
    that never expire, and members of privileged groups.

.EXAMPLE
    .\user_security_audit.ps1 -InactiveDays 90
#>

param(
    [int]$InactiveDays = 90
)

Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "=== Windows User Security Audit ===" -ForegroundColor Cyan
Write-Host "Inactive threshold: $InactiveDays days"

# 1. Local accounts with passwords set to never expire
Write-Host "-- Local accounts with non-expiring passwords --"
Get-LocalUser | Where-Object { $_.PasswordExpires -eq $null -and $_.Enabled -eq $true } |
    Select-Object Name, Enabled, PasswordExpires | Format-Table -AutoSize

# 2. Stale local accounts (no logon within threshold)
Write-Host "-- Local accounts inactive for $InactiveDays+ days --"
$cutoff = (Get-Date).AddDays(-$InactiveDays)
Get-LocalUser | Where-Object {
    $_.Enabled -eq $true -and $_.LastLogon -ne $null -and $_.LastLogon -lt $cutoff
} | Select-Object Name, LastLogon | Format-Table -AutoSize

# 3. Members of the local Administrators group
Write-Host "-- Members of local Administrators group --"
Get-LocalGroupMember -Group "Administrators" | Select-Object Name, PrincipalSource | Format-Table -AutoSize

# 4. Domain accounts (if AD module available) inactive beyond threshold
if (Get-Module -ListAvailable -Name ActiveDirectory) {
    Write-Host "-- Domain accounts inactive for $InactiveDays+ days --"
    Search-ADAccount -AccountInactive -TimeSpan ([TimeSpan]::FromDays($InactiveDays)) -UsersOnly |
        Select-Object Name, LastLogonDate | Format-Table -AutoSize
}

Write-Host "Audit complete." -ForegroundColor Green


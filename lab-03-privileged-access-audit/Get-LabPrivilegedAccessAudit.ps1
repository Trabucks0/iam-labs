# Get-LabPrivilegedAccessAudit.ps1 — STARTER. Dev tenant only.
# Flags permanent privileged role assignments, admins with no MFA registered,
# and dormant privileged accounts. Exports a dated CSV findings report.
Connect-MgGraph -Scopes "RoleManagement.Read.Directory","User.Read.All","AuditLog.Read.All"

$report = @()

# 1. Permanent privileged role assignments (the big one)
$privRoles = @("Global Administrator","Privileged Authentication Administrator","Privileged Role Administrator")
foreach ($roleName in $privRoles) {
    $role = Get-MgDirectoryRole -Filter "displayName eq '$roleName'"
    if (-not $role) { continue }
    $members = Get-MgDirectoryRoleMember -DirectoryRoleId $role.Id
    foreach ($m in $members) {
        $user = Get-MgUser -UserId $m.Id -Property "displayName,userPrincipalName,signInActivity,accountEnabled" -ErrorAction SilentlyContinue
        $report += [pscustomobject]@{
            Finding     = "Permanent assignment: $roleName"
            Identity    = $user.UserPrincipalName
            Risk        = "HIGH"
            Remediation = "Convert to PIM-eligible; require activation with MFA + justification + approval"
        }
    }
}

# 2. Admins with no MFA registered
$admins = $report.Identity | Select-Object -Unique
foreach ($upn in $admins) {
    $methods = Get-MgUserAuthenticationMethod -UserId $upn -ErrorAction SilentlyContinue
    if (($methods | Measure-Object).Count -le 1) {
        $report += [pscustomobject]@{
            Finding     = "Admin with no MFA methods registered"
            Identity    = $upn
            Risk        = "CRITICAL"
            Remediation = "Enforce CA-01 (Lab 2) and require MFA registration via Conditional Access registration campaign"
        }
    }
}

# 3. Dormant admin accounts (no sign-in in 30 days)
foreach ($upn in $admins) {
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'" -Property "signInActivity,displayName"
    $last = $user.SignInActivity.LastSignInDateTime
    if (-not $last -or $last -lt (Get-Date).AddDays(-30)) {
        $report += [pscustomobject]@{
            Finding     = "Dormant privileged account (last sign-in: $last)"
            Identity    = $upn
            Risk        = "HIGH"
            Remediation = "Remove assignment; re-provision via PIM if access is ever needed again"
        }
    }
}

$report | Format-Table -AutoSize
$report | Export-Csv -Path ".\privileged-access-audit-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
Write-Output "`nWrote dated CSV evidence file. Commit it (sanitized) to your repo."

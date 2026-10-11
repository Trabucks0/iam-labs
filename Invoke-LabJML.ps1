# Invoke-LabJML.ps1 — STARTER. Review and adapt before running.
# Requires: Microsoft.Graph PowerShell SDK v2. Lab tenant only — never run against a production tenant.

param(
    [Parameter(Mandatory)][string]$CsvPath,
    [Parameter(Mandatory)][ValidateSet("onboard","mover","offboard")][string]$Action
)

# Map departments to group display names in YOUR tenant
$DepartmentGroups = @{
    "IT"      = @("GRP-IT-Standard", "GRP-VPN-Access")
    "Finance" = @("GRP-Finance-Standard")
    "HR"      = @("GRP-HR-Standard")
}

function New-LabUser {
    param($Row)
    $upn = ("{0}.{1}@trabucks.onmicrosoft.com" -f $Row.firstName, $Row.lastName).ToLower()
    $passwordProfile = @{ Password = "Lab#Temp2026!"; ForceChangePasswordNextSignIn = $true }
    $user = New-MgUser -DisplayName "$($Row.firstName) $($Row.lastName)" `
        -UserPrincipalName $upn -MailNickname ($Row.firstName + $Row.lastName).ToLower() `
        -Department $Row.department -JobTitle $Row.jobTitle `
        -AccountEnabled:$true -PasswordProfile $passwordProfile
    foreach ($g in $DepartmentGroups[$Row.department]) {
        $group = Get-MgGroup -Filter "displayName eq '$g'"
        if ($group) { New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id }
    }
    Write-Output "ONBOARDED: $upn"
}

function Move-LabUser {
    param($Row)
    $upn = ("{0}.{1}@trabucks.onmicrosoft.com" -f $Row.firstName, $Row.lastName).ToLower()
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if (-not $user) { Write-Warning "Not found: $upn"; return }
    # 1. Update department + job title to the new values from the CSV
    Update-MgUser -UserId $user.Id -Department $Row.department -JobTitle $Row.jobTitle
    # 2. Strip ALL current group memberships — this kills stale access from the
    #    old department. Movers are where real companies bleed privilege.
    $groups = Get-MgUserMemberOf -UserId $user.Id | Where-Object { $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.group" }
    foreach ($g in $groups) { Remove-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $user.Id }
    # 3. Add to the NEW department's groups from the map above
    foreach ($gName in $DepartmentGroups[$Row.department]) {
        $group = Get-MgGroup -Filter "displayName eq '$gName'"
        if ($group) { New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $user.Id }
    }
    Write-Output "MOVED: $upn"
}

function Disable-LabUser {
    param($Row)
    $upn = ("{0}.{1}@trabucks.onmicrosoft.com" -f $Row.firstName, $Row.lastName).ToLower()
    $user = Get-MgUser -Filter "userPrincipalName eq '$upn'"
    if (-not $user) { Write-Warning "Not found: $upn"; return }
    # 1. Disable sign-in  2. Revoke sessions/tokens  3. Strip group memberships
    Update-MgUser -UserId $user.Id -AccountEnabled:$false
    Invoke-MgGraphRequest -Method POST -Uri "https://graph.microsoft.com/v1.0/users/$($user.Id)/revokeSignInSessions" | Out-Null
    $groups = Get-MgUserMemberOf -UserId $user.Id | Where-Object { $_.AdditionalProperties["@odata.type"] -eq "#microsoft.graph.group" }
    foreach ($g in $groups) { Remove-MgGroupMemberByRef -GroupId $g.Id -DirectoryObjectId $user.Id }
    Write-Output "OFFBOARDED: $upn (disabled, sessions revoked, groups removed)"
}

Import-Csv $CsvPath | ForEach-Object {
    $row = $_  # capture the CSV row: inside switch, $_ means the Action value, not the row
    switch ($Action) {
        "onboard"  { New-LabUser $row }
        "offboard" { Disable-LabUser $row }
        "mover"    { Move-LabUser $row }
    }
}

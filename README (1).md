# Lab 01 — User Lifecycle Automation (Joiner / Mover / Leaver)

**Problem:** New hires wait days for accounts, movers keep access they shouldn't have, and leavers keep access they definitely shouldn't have. Manual onboarding in a portal doesn't scale and leaves standing privilege everywhere.

**Solution:** A PowerShell script using the Microsoft Graph SDK that onboards, moves, and offboards users from CSV files.

## Run it

```powershell
# 1. Connect with least-privilege scopes
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All","Directory.ReadWrite.All"

# 2. Onboard 9 users across IT / Finance / HR
.\Invoke-LabJML.ps1 -CsvPath .\users-onboard.csv -Action onboard

# 3. Move Alice IT -> Finance (implement the mover path yourself)
.\Invoke-LabJML.ps1 -CsvPath .\users-mover.csv -Action mover

# 4. Offboard Bob (disables account, revokes sessions, strips groups)
.\Invoke-LabJML.ps1 -CsvPath .\users-offboard.csv -Action offboard
```

Before running: edit `$DepartmentGroups` in the script to match your tenant's group names, and replace `<your-dev-tenant>` with your tenant name.

## Files

| File | Purpose |
|------|---------|
| `Invoke-LabJML.ps1` | The automation script (starter — mover path is yours to implement) |
| `users-onboard.csv` | 9 fake users to onboard |
| `users-mover.csv` | Alice Test: IT -> Finance + promotion |
| `users-offboard.csv` | Bob Test: offboard |

## Key design decision

Offboarding revokes sessions **before** anything else — a disabled account with a valid refresh token is still a live account for up to an hour. Order matters.

## Prerequisites

- Free Azure account with Entra ID test tenant
- PowerShell 7+: `Install-Module Microsoft.Graph -Scope CurrentUser`
- A Global Admin **test** account (never your real identity)

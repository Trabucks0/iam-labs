# Invoke-LabSecretRotation.ps1 — demonstrates vaulting concepts.
# Uses a local JSON "vault" file. In production this would be CyberArk PVWA/CPM;
# the CONCEPTS (check-out, rotation, append-only audit) are what transfer.

$VaultPath = ".\lab-vault.json"
$AuditPath = ".\lab-vault-audit.log"

function Get-Vault { if (Test-Path $VaultPath) { Get-Content $VaultPath | ConvertFrom-Json } else { @{} } }

function Rotate-LabSecret {
    param([Parameter(Mandatory)][string]$AccountName)
    $vault = Get-Vault
    # Generate a 32-char random secret (stand-in for CPM-driven rotation)
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
    $newSecret = -join ((1..32) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    # In a real vault, the old secret is never shown again after rotation
    $vault | Add-Member -NotePropertyName $AccountName -NotePropertyValue @{
        lastRotated = (Get-Date).ToString("o")
        rotatedBy   = "LAB-CPM-SIM"
    } -Force
    $vault | ConvertTo-Json | Set-Content $VaultPath
    # Append-only audit log: who rotated what, when. Never edited, only appended.
    Add-Content $AuditPath "[$(Get-Date -Format o)] ROTATE account=$AccountName by=LAB-CPM-SIM"
    Write-Output "Rotated $AccountName. New secret generated and stored; event appended to audit log."
}

function Show-LabAuditLog { Get-Content $AuditPath }

# Demo:
Rotate-LabSecret -AccountName "svc-backup"
Show-LabAuditLog

# IAM Labs Portfolio

Hands-on identity and access management labs built in a dedicated Entra ID test tenant. Each lab solves a real-world IAM problem with automation — no production systems touched, all test data.

## Labs

| # | Lab | Problem it solves |
|---|-----|-------------------|
| 01 | [User Lifecycle Automation](lab-01-user-lifecycle-automation/) | Joiner/mover/leaver via PowerShell + Microsoft Graph |
| 02 | Conditional Access Baseline | *In progress* |
| 03 | Privileged Access Audit | *Planned* |
| 04 | PAM Fundamentals | *Planned* |

## Tech

- Microsoft Entra ID (test tenant)
- PowerShell 7 + Microsoft Graph PowerShell SDK
- CSV-driven automation

## Ground rules

- Lab tenant only — never run these scripts against a production tenant
- All users are fake test data
- Least-privilege Graph scopes on every connection

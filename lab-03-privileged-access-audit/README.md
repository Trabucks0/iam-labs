# Lab 03 — Privileged Access Audit (Least Privilege Enforcement)

**Problem:** In every tenant, privilege creeps: someone got Global Admin "temporarily" in 2022, a service account has a role it never uses, an ex-contractor's admin assignment was never revoked. Auditors find it, attackers exploit it. This lab hunts it.

**Solution:** A PowerShell audit script using Microsoft Graph that produces a least-privilege findings report — formatted the way real audit reports are: finding → risk rating → remediation → re-test.

**Status:** Audit script written and published here. Tenant run (against deliberately planted "bad" assignments) in progress.

## What the audit checks

- All privileged role assignments (Global Admin, Privileged Authentication Admin, etc.) — who has them, and whether they're **permanent** or **PIM-eligible**
- Admin accounts with no MFA registered
- Admin accounts dormant 30+ days
- Service principals with high-privilege app role assignments

## Step-by-step build

Prerequisites: free Azure account with Entra ID tenant + P2 trial (PIM is included in P2); Microsoft Graph PowerShell SDK.

1. Deliberately create 2–3 "bad" assignments first: make one test user permanent Global Admin, leave another dormant. You're building the mess, then catching it.
2. In the tenant, convert one admin to **PIM-eligible** (Privileged Identity Management → Entra roles → make eligible instead of permanent). Leave the other as permanent — that's your finding.
3. Run the audit script: `.\Get-LabPrivilegedAccessAudit.ps1`. It outputs a findings list and exports a dated CSV.
4. For each finding, write the **remediation**: convert to PIM-eligible with approval + justification, require MFA, remove dormant assignment.
5. Implement the remediations, re-run the script, and compare reports — findings before, clean after.
6. Present the result as an audit: findings table, risk rating per finding, remediation, re-test result.

## Files

| File | Purpose |
|------|---------|
| `Get-LabPrivilegedAccessAudit.ps1` | The audit script (starter — dev tenant only) |

## Stretch goals

- Add **Access Reviews** in Entra ID Governance: create a quarterly review of Global Admins and document the reviewer workflow (see also Lab 05)
- Extend the script to flag service principals with `RoleManagement.ReadWrite.Directory` app permissions (effectively Global Admin for an app)

## What this proves in an interview

"How do you enforce least privilege?" → you don't recite the definition; you describe permanent-vs-eligible assignments, MFA registration gaps, dormancy checks, and evidence exports. Then you show this repo.

## Free sources for this lab

- Microsoft Learn: [SC-300 learning path](https://learn.microsoft.com/en-us/training/paths/implement-identity-management-solution/)
- Official SC-300 lab exercises: [microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/)

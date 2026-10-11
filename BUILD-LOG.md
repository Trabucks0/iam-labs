# Lab 01 — Build Log

## Day 1 — 2026-10-10

**Done**
- Created Microsoft Entra ID test tenant (`trabucks.onmicrosoft.com`)
- Bulk-created 9 test users across IT, Finance, and HR via portal CSV import
  (portal requires Microsoft's template format: `version:v1.0` row + `[property]` headers)
- Created 4 department security groups: `GRP-IT-Standard`, `GRP-VPN-Access`,
  `GRP-Finance-Standard`, `GRP-HR-Standard`
- Installed PowerShell 7 + Microsoft Graph PowerShell SDK
- Wrote `Invoke-LabJML.ps1`: CSV-driven joiner/mover/leaver automation
- Fixed a real bug: inside `switch ($Action)`, `$_` refers to the action string,
  not the pipeline row — captured `$row = $_` before the switch

**Pending**
- Run mover: Alice Test, IT → Finance (Senior Helpdesk Analyst)
- Run offboard: Bob Test (disable, revoke sessions, strip groups)
- Verify results in Entra admin center

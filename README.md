# IAM Labs Portfolio

Hands-on identity and access management labs built in a dedicated Microsoft Entra ID test tenant. Each lab solves a real-world IAM problem — designs, scripts, and step-by-step build guides included. No production systems touched, all test data.

**Author:** Tracey Moore — IAM career changer, studying for Microsoft SC-300 (target Jan 2027), then CyberArk Defender (PAM-DEF).

## Labs

| # | Lab | What it proves | Status |
|---|-----|----------------|--------|
| 01 | [User Lifecycle Automation](lab-01-user-lifecycle-automation/) | Joiner/mover/leaver automation with PowerShell + Microsoft Graph | Built — live in lab tenant |
| 02 | [Conditional Access Baseline](lab-02-conditional-access-baseline/) | Zero Trust policy design: MFA, legacy-auth block, device trust | Guide published — tenant build in progress |
| 03 | [Privileged Access Audit](lab-03-privileged-access-audit/) | Hunting over-privilege with Graph; PIM remediation | Script + guide published |
| 04 | [PAM Fundamentals](lab-04-pam-fundamentals/) | CyberArk-style Safe design, rotation, vaulting concepts | Design + demo published |
| 05 | [Entitlement Management & Access Reviews](lab-05-entitlement-management-access-reviews/) | Identity governance: access packages, approvals, recurring reviews | Step-by-step guide — build queued |
| 06 | [SAML SSO App Integration](lab-06-saml-sso-app-integration/) | Enterprise app SSO: SAML config, claims, assignment, testing | Step-by-step guide — build queued |

## Tech

- Microsoft Entra ID (dedicated test tenant)
- PowerShell 7 + Microsoft Graph PowerShell SDK
- Entra ID Governance (entitlement management, access reviews, PIM)
- CyberArk PAM concepts (Vault / PVWA / CPM / PSM)

## Ground rules

- Lab tenant only — never run these scripts against a production tenant
- All users are fake test data; no real people, no real credentials
- Least-privilege Graph scopes on every connection
- No secrets committed — placeholders only

## Free learning sources behind these labs

- [Microsoft Learn — SC-300 modules](https://learn.microsoft.com/en-us/training/modules/plan-implement-manage-access/) (free, official)
- [Microsoft's official SC-300 lab instructions](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/) (free, GitHub)
- [CyberArk PAM overview + Blueprint framework](https://www.cyberark.com/products/privileged-access-management) (free)

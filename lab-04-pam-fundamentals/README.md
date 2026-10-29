# Lab 04 — PAM Fundamentals (CyberArk-Aligned)

**Problem:** Admin passwords in spreadsheets. Shared root credentials nobody rotates. A compromised helpdesk account that can reach the domain controllers. Privileged Access Management exists because **admin credentials are the keys to the kingdom** — CyberArk's business is vaulting them, rotating them, and making sure no human ever knows the real password. This lab teaches the concepts with a working demo, no CyberArk license required.

**Solution:** (A) a CyberArk-style Safe design for a fictional 200-person company, (B) a working password-rotation demo script with an append-only audit log, (C) a CyberArk architecture study (Vault, PVWA, CPM, PSM).

> Honest framing: this is a "PAM concepts lab (CyberArk-aligned)". It does not claim CyberArk product experience — hiring managers check. What it does claim: vaulting, rotation, check-out workflows, and dual control, understood well enough to design and defend them.

## Part A — Safe design

For each safe: **purpose, who gets access, who approves check-out, rotation policy** — plus a defense of the rotation interval (interviewers ask "why 30 days and not 7?" — the answer involves operational friction vs. exposure window; defending a position beats reciting one).

| Safe | Contents | Access model |
|------|----------|--------------|
| `Windows-Domain-Admins` | Domain admin credentials | Break-glass only; dual approval; 24h rotation after use |
| `Server-Local-Admins` | Local admin per server | IT ops team; auto-rotation every 30 days via CPM |
| `Service-Accounts` | App/service credentials | No human access — application retrieval via API only |
| `Network-Devices` | Switch/firewall admin | Network team; rotation on team-member departure |
| `Break-Glass` | Emergency tenant admin | Sealed; any use pages the security team immediately |

## Part B — Rotation demo script

`Invoke-LabSecretRotation.ps1` (in this folder) demonstrates the vaulting concepts with a local JSON "vault": check-out, automatic rotation of a 32-char secret, and an append-only audit log. In production this would be CyberArk PVWA/CPM; the **concepts** are what transfer.

```powershell
.\Invoke-LabSecretRotation.ps1   # demo rotates "svc-backup" and shows the audit log
```

## Part C — CyberArk architecture study

In my own words, from CyberArk's public documentation:

- **Vault** — the encrypted credential store; the core of the platform. Secrets live here, nowhere else.
- **PVWA** — the web portal where users request and check out credentials.
- **CPM** (Central Policy Manager) — the engine that automatically rotates passwords on schedule and after use.
- **PSM** (Privileged Session Manager) — isolates and records privileged sessions; the user connects *through* PSM and never sees the actual password.

Check-out flow: request → approval → check-out → use via PSM (password never revealed) → auto-rotation on check-in.

## Files

| File | Purpose |
|------|---------|
| `Invoke-LabSecretRotation.ps1` | Rotation demo (local JSON vault stand-in) |

## What this proves in an interview

"What's the difference between PIM and PAM?" → PIM = just-in-time *Entra ID role* elevation; PAM = vaulting and rotating the *actual credentials*, session isolation, check-out workflows. Naming that distinction with this Safe design open is a strong junior-PAM signal — and it pre-builds CyberArk Defender (PAM-DEF) studies.

## Free sources for this lab

- CyberArk Blueprint — CyberArk's free privileged-access architecture framework (cyberark.com)
- Official SC-300 lab exercises: [microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/)

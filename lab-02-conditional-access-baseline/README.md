# Lab 02 — Conditional Access Baseline (Zero Trust Policy Design)

**Problem:** Passwords get phished. Standing access gets abused. "Trust the network" is dead. Conditional Access is how modern companies enforce *verify explicitly, assume breach* — and misconfigured CA policies are one of the most common real-world findings. This lab designs a sane baseline.

**Solution:** Three Conditional Access policies in a Microsoft Entra ID tenant (P2), rolled out the way professionals do it: report-only first, sign-in log review, What-If validation, break-glass account documented — *then* enforcement.

**Status:** Policy designs and rollout procedure complete (below). Tenant build in progress on the P2 trial; report-only findings will be appended to the build log as they land.

## The policies

| # | Policy | Signal → Control |
|---|--------|------------------|
| 1 | **CA-01: Require MFA for administrators** | Any admin role sign-in → require phishing-resistant MFA |
| 2 | **CA-02: Block legacy authentication** | Legacy auth protocols (IMAP, POP, old Office clients) → block, all users |
| 3 | **CA-03: Require compliant or hybrid-joined device for Finance** | Finance group accessing any cloud app → require compliant device |

## Step-by-step build

Prerequisites: free Azure account with Entra ID tenant + P2 trial; 3–4 test users (one in a fake "Finance" group, one with a fake admin role like Helpdesk Administrator — never Global Admin for daily use).

1. In Entra admin center → Protection → Conditional Access, create each policy with a clear naming convention: `CA-01-Require-MFA-Admins`, etc. (Naming conventions are a real enterprise discipline — document yours.)
2. For each policy, configure: **Users** (who), **Target resources** (what), **Conditions** (signals: device platform, client app type, locations), **Grant** (control).
3. **CA-02 detail:** under Conditions → Client apps, select "Exchange ActiveSync clients" and "Other clients" — that's where legacy auth hides. Grant: Block access.
4. Before enabling: set each policy to **Report-only** first. Check the sign-in logs for "what would have happened." This is how professionals roll out CA without locking out the company.
5. After 24h of clean report-only data, enable. Then deliberately test: try signing in with a legacy protocol (or simulate via the "What If" tool in Conditional Access) and screenshot the block.
6. Document all three: the threat each policy stops, why it is scoped that way, and the report-only findings.

## Design notes (the part interviewers probe)

- **Why block legacy auth first?** It's the cheapest high-impact win: legacy protocols bypass MFA entirely, and attackers know it. One policy closes an entire phishing-resale channel.
- **Why report-only before enforce?** Because a bad CA policy can lock every admin out of the tenant simultaneously. Recovery then requires the break-glass account (documented as part of this lab: one cloud-only Global Admin, MFA via FIDO2, credentials sealed, alert on any sign-in).
- **Least privilege in scoping:** CA-03 targets only Finance, not everyone — over-scoping CA causes helpdesk tickets and shadow IT.

## Stretch goals

- CA-04: risk-based policy using Identity Protection (require password change on medium+ sign-in risk)
- Named Locations: define an "office" IP range and exclude it from MFA for low-risk users — then write the tradeoff analysis

## What this proves in an interview

"How would you roll out MFA to 5,000 users without breaking the business?" → report-only mode, phased scoping, break-glass account, What-If validation. That's a senior answer from a junior candidate.

## Free sources for this lab

- Microsoft Learn, SC-300: [Plan and implement Conditional Access](https://learn.microsoft.com/en-us/training/modules/plan-implement-manage-access/)
- Official SC-300 lab exercises: [microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/)

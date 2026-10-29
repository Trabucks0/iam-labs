# Lab 06 — SAML SSO Enterprise App Integration

**Problem:** Every SaaS app with its own password is a phishing target, an offboarding gap, and a helpdesk ticket factory. Federating apps to Entra ID with SAML single sign-on centralizes authentication — one identity, one MFA policy, one place to cut access when someone leaves.

**Solution:** Register an enterprise application in Entra ID, configure SAML-based SSO end-to-end (identifiers, reply URL, claims mapping), assign users, and validate the full sign-in flow in the sign-in logs.

**Status:** Step-by-step build guide (below) — tenant build queued behind the P2 trial activation. Progress will be appended as a build log.

## Prerequisites

- Entra ID tenant (SSO configuration for one app works on the free tier; group claims and some features need P1)
- Global Administrator or Application Administrator test account
- 2–3 test users + one group from Lab 01
- A test service provider: a free public SAML test SP (e.g. a SAML request decoder / test IdP page) or a second app registration acting as the SP — the Entra-side configuration is the skill being proven

## Step-by-step build

### 1. Register the enterprise application
1. Entra admin center → **Identity → Applications → Enterprise applications → New application → Create your own application**.
2. Name: `Lab SAML App`. Choose *Integrate any other application you don't find in the gallery (Non-gallery)*.
3. Note the distinction for interviews: an **app registration** is the identity you create; the **enterprise application** (service principal) is that identity's instance in your tenant — SSO and assignment live on the service principal.

### 2. Configure SAML single sign-on
1. In the app → **Single sign-on → SAML**.
2. **Basic SAML Configuration** (values come from the service provider):
   - **Identifier (Entity ID):** the SP's unique audience URI, e.g. `https://samltest.example/lab-app`
   - **Reply URL (ACS URL):** where Entra posts the assertion, e.g. `https://samltest.example/lab-app/acs`
   - **Sign-on URL:** the SP-initiated start URL (optional for IdP-initiated testing)
3. Save. A mismatch in either value is the #1 cause of failed SAML sign-ins — the assertion is rejected before any user setting matters.

### 3. Map the attributes & claims
| Claim | Source value | Why |
|-------|--------------|-----|
| NameID | `user.userprincipalname` (format: emailAddress) | The SP's primary user key |
| `department` | `user.department` | Lets the SP apply its own role logic |
| `jobtitle` | `user.jobtitle` | Display + provisioning context |

Note: keep the claim set minimal — every attribute sent is data shared with a third party.

### 4. Certificates and metadata
1. **SAML Certificates**: download the **Federation Metadata XML** — this single file is how the SP learns your signing certificate, entity ID, and SSO endpoints.
2. Write down the certificate thumbprint and expiry. In production, certificate rollover is a scheduled event: an expired signing cert breaks sign-in for *every* user of the app at once.

### 5. Assign users and test
1. **Users and groups** → assign the Lab 01 Finance test group. Set *User assignment required* = yes — unassigned users must get "not assigned" rather than silent access.
2. Test IdP-initiated sign-in from **myapps.microsoft.com** as a test user.
3. Test SP-initiated sign-in from the test SP's login page (this exercises the full redirect chain).
4. Validate in **Entra sign-in logs**: filter by the application, confirm success entries, and deliberately produce one failure (sign in as an *unassigned* user) to learn what the rejection looks like in the logs.

## Troubleshooting table (learned the standard way — by breaking it)

| Symptom | Likely cause | Check |
|---------|--------------|-------|
| Assertion rejected immediately | Entity ID or ACS URL mismatch between IdP and SP | Basic SAML Configuration vs. the SP's metadata, character for character |
| "User not assigned" | Assignment required + user not in an assigned group | Users and groups blade |
| Sign-in works, app shows wrong user | NameID format mismatch (persistent vs. emailAddress) | Attributes & Claims → NameID format |
| Everything broke at once, no changes made | Signing certificate expired | SAML Certificates → expiry date |

## What this proves in an interview

"Walk me through adding SSO to a new app" → register the service principal, exchange metadata, match Entity ID + ACS exactly, map NameID and a minimal claim set, assign by group, test both IdP- and SP-initiated flows, and verify in the sign-in logs. Plus the operational point juniors miss: certificate expiry is an outage with a date on it.

## Free sources for this lab

- Microsoft Learn: [What is single sign-on?](https://learn.microsoft.com/en-us/entra/identity/enterprise-apps/what-is-single-sign-on)
- Official SC-300 lab exercises: [microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/)

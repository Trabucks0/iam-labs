# Lab 05 — Entitlement Management & Access Reviews (Identity Governance)

**Problem:** Access at most companies is granted by whoever shouts loudest in a ticket queue — and it's never taken back. Nobody can answer "who approved this, and when does it expire?" Entitlement management fixes the front door (request → approval → time-boxed grant) and access reviews fix the back door (periodic re-certification).

**Solution:** An Entra ID Governance build: a catalog and access package with approval and expiration policies, an attribute-based auto-assignment policy, an end-to-end request test, and a recurring access review with auto-apply results.

**Status:** Step-by-step build guide (below) — tenant build queued behind the P2 trial activation (see repo README ground rules). Progress will be appended as a build log.

## Prerequisites

- Entra ID tenant with P2 / Entra ID Governance trial (access packages and reviews are governance features)
- Global Administrator or Identity Governance Administrator test account
- Existing objects from Lab 01: test users and `GRP-Finance-Standard` group
- Optional: Microsoft Graph PowerShell SDK for the evidence queries in step 6

## Step-by-step build

### 1. Create the catalog
1. Entra admin center → **Identity governance → Entitlement management → Catalogs → New catalog**.
2. Name: `Lab Catalog — Business Apps`. Description: who it's for and who owns it.
3. **Add resources**: add the group `GRP-Finance-Standard` (from Lab 01). Note the rule: a resource must be in a catalog before any access package can grant it.

### 2. Create the access package
1. **Access packages → New access package**: name `Finance Onboarding`.
2. **Resource roles**: add `GRP-Finance-Standard` with role **Member**.
3. Baseline settings: hide from My Access = off (users must be able to find it), require approval = on (configured in the policy next).

### 3. Policy 1 — request with approval
1. **Requests**: who can request = *Specific users and groups* → the HR test group (managers request for new hires).
2. **Approval**: require approval = yes, one stage, approver = the Finance lead test user, decisions expire in 14 days, requestor must provide a business justification.
3. **Lifecycle**: assignments expire after **30 days**; require an access review for continued use = off (reviews are step 5); allow requestors to extend = off — expiration without renewal is the point.

### 4. Policy 2 — auto-assignment by attribute
1. Add a second policy to the same package: **auto-assignment** based on user attribute `department = Finance`.
2. Observe: when a Lab 01 user with department Finance is created or moved, the assignment appears with no request and no approver — and *disappears* when the attribute changes. This is the JML mover problem from Lab 01 solved by governance instead of by hand.

### 5. Test the request flow end-to-end
1. Sign in as an HR test user at **myaccess.microsoft.com** → request `Finance Onboarding` for a test user, with justification.
2. Sign in as the approver → approve.
3. Verify the grant: Entra admin center → the user → Groups (shows `GRP-Finance-Standard`), and note the assignment's expiration date in the package's assignments list.

### 6. Evidence via Microsoft Graph
```powershell
Connect-MgGraph -Scopes "EntitlementManagement.Read.All"
# Who holds assignments for the package, and when do they expire?
Get-MgIdentityGovernanceEntitlementManagementAssignment -All |
  Select-Object @{n='User';e={$_.Target.ObjectId}}, AccessPackageId, AssignmentState, ExpiredDateTime
```
Sanitize any output before committing it here — IDs and UPNs of the *test* tenant only.

### 7. Create the recurring access review
1. **Identity governance → Access reviews → New**: scope = group `GRP-Finance-Standard` membership.
2. Reviewers = **group owners** (fallback: tenant admins). Duration 14 days, recurrence **quarterly**.
3. **Auto-apply results = on**; if reviewers don't respond, default = *remove access* (safe default — silence is not consent).
4. Run the first review against the Lab 01/05 test membership; approve one user, deny one, let one lapse — then verify all three outcomes in group membership.

## Design notes (the part interviewers probe)

- **Why expiration by default?** Standing access is standing risk. A 30-day grant that must be re-justified beats a permanent grant nobody remembers approving.
- **Request policy vs. auto-assignment policy:** requests fit *exceptions* (a person needs access outside their role); auto-assignment fits *role-based* access (attribute proves the need). Mixing them up is how packages rot.
- **Auto-apply + deny-by-default:** a review nobody acts on must fail closed, or the review is theater.

## What this proves in an interview

"How do you make sure access doesn't pile up?" → access packages with approval and expiry at grant time, attribute-driven assignment so movers don't drag access behind them, and quarterly reviews that auto-remove unreviewed access. Governance as a system, not a cleanup project.

## Free sources for this lab

- Microsoft Learn: [Entitlement management overview](https://learn.microsoft.com/en-us/entra/id-governance/entitlement-management-overview)
- Official SC-300 lab exercises: [microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator](https://microsoftlearning.github.io/SC-300-Identity-and-Access-Administrator/)

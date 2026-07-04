---
name: attack-surface
description: Maintain attacksurface.md — the running inventory of every system, host, vendor, site, and technology in this org and its total attack surface. Use when adding a newly deployed service, changing a system's exposure/auth, recording an assessment result, or answering "what's our attack surface for X". Pairs with the AssessAttackSurface workflow, which produces the assessed data this file records.
---

# AttackSurface — maintaining `attacksurface.md`

`attacksurface.md` (repo root) is a **living, continuously-updated** security
inventory. This skill defines its schema and the rules for keeping it accurate.
It is a **defensive asset-management** resource for systems the operator owns or
is authorized to assess — never a target list for third parties.

## When to touch the file
- A new system/host/vendor/site/tech is proposed or deployed → add an entry.
- A system's exposure, auth, or defenses change → update its entry + bump `Last reviewed`.
- An assessment runs (via the `AssessAttackSurface` workflow) → fold findings in, set `Last assessed`.
- Something is decommissioned → move it to the **Retired** section (don't delete — keep history).

## Entry schema (every system gets all fields; use `UNKNOWN — needs input` when you don't know, never a guess)
```
### <System name>
- **Classification:** web property | database | API | embedded/IoT | repo/VCS | local tooling | data store | cloud host | network
- **Technology:** <concrete stack — language, framework, platform, versions>
- **Hosting:** self-hosted | third-party (<vendor>) | hybrid | ephemeral
- **Deployed assets:** <what actually lives here — apps, endpoints, tables, devices, files>
- **Authentication:** <how you auth IN — none | password | SSH key | API token | OAuth (<provider>) | mTLS | SSO>
- **Exposure / audience:** public | internal | behind VPN | token-required | OAuth-gated | physical-only | local-only
  - reachable by: <who/what path — internet, LAN, USB, RF, teammates>
- **Security mechanisms (defenses in place):** <TLS, WAF, branch protection, MFA, secure boot, input validation, rate limiting, secrets mgmt, ...>
- **Common issues / misconfigurations for this platform:** <the well-known failure modes for THIS tech — cite the class, note whether we're exposed>
- **Known gaps / findings:** <verified findings, most severe first, with severity>
- **Test cadence:** <recommended frequency + methods> (from AssessAttackSurface)
- **Criticality:** low | medium | high | critical  — **Test cost:** low | medium | high
- **Last reviewed:** <date>  **Last assessed:** <date or "never">
```

## Rules
1. **Never fabricate.** Only record systems with evidence (a repo, a config, a
   vendor account the operator named). If a category (cloud, DB, domains) has no
   known members, keep its **placeholder** heading with `— none recorded yet` so
   the gap is visible rather than implied-complete.
2. **Evidence over assertion.** Findings should cite `file:line`, a config, or an
   assessment run. Mark design-level/latent items as such.
3. **Severity honesty.** Don't inflate. A latent radio that's compiled-out is
   `info`/`low`, not `high`, until it's enabled.
4. **Keep the maintenance log** at the bottom current (date — what changed — who/what triggered it).
5. **Scope note:** if visibility is limited (e.g. one repo in scope), say so at
   the top so readers know the inventory is partial, and list how to widen it
   (`list_repos` / `add_repo`, or the operator filling placeholders).

## Running an assessment
Use the workflow to (re)assess a surface and get verified findings + a cadence:
```
Workflow({ name: 'AssessAttackSurface',
           args: { surfaces: [{ name, type, root, notes }] } })
```
Omit `surfaces` to auto-discover from the working tree. Then transcribe its
CONFIRMED/PLAUSIBLE findings and cadence into the matching entry here, and update
`Last assessed`. The workflow is read-only and defensive — it never exploits.

## Adding a new attack surface — checklist
- [ ] Placed under the right classification heading (create it if new)
- [ ] All schema fields filled (or `UNKNOWN — needs input`)
- [ ] Exposure + audience explicit
- [ ] Common-misconfig list is platform-specific, not generic
- [ ] Criticality/cost set; cadence recommended
- [ ] Maintenance log line appended

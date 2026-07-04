// AssessAttackSurface — defensive attack-surface assessment workflow.
//
// Assesses one or more of YOUR OWN attack surfaces: enumerates concrete
// assets, analyzes them across five security lenses, adversarially verifies
// each finding, and recommends a testing cadence from criticality x cost.
//
// This is a DEFENSIVE, READ-ONLY assessment: it inventories and reasons about
// configuration and exposure. It does not exploit, attack, or send traffic to
// anything. Point it only at systems you own or are authorized to assess.
//
// Invoke:
//   Workflow({ name: 'AssessAttackSurface', args: { surfaces: [ ... ] } })
//   Workflow({ scriptPath: '.../AssessAttackSurface.js', args: { surfaces: [...] } })
//
// args.surfaces: [{ name, type, root, notes }]  (omit to auto-discover from cwd)
//   type: 'repo/vcs' | 'embedded/iot' | 'web' | 'api' | 'database'
//         | 'local-tooling/supply-chain' | 'data/privacy' | 'cloud/host' | ...

export const meta = {
  name: 'AssessAttackSurface',
  description: 'Defensively assess owned attack surfaces: enumerate assets, analyze auth/misconfig/input/exposure/supply-chain, adversarially verify, recommend test cadence.',
  whenToUse: 'Populating or refreshing attacksurface.md; periodic security review of your own systems.',
  phases: [
    { title: 'Discover' },
    { title: 'Enumerate' },
    { title: 'Analyze' },
    { title: 'Verify' },
    { title: 'Cadence' },
  ],
}

// ---- schemas ----
const ENUM_SCHEMA = {
  type: 'object',
  required: ['assets'],
  properties: {
    tech_stack: { type: 'array', items: { type: 'string' } },
    hosting: { type: 'string', description: 'self-hosted | third-party | hybrid | ephemeral' },
    classification: { type: 'string', description: 'web | database | api | embedded | repo | tooling | data | mixed' },
    assets: {
      type: 'array',
      items: {
        type: 'object',
        required: ['asset', 'detail'],
        properties: {
          asset: { type: 'string' },
          detail: { type: 'string' },
          evidence: { type: 'string', description: 'file:line or command output grounding this' },
        },
      },
    },
    auth_points: { type: 'array', items: { type: 'string' } },
    network_interfaces: { type: 'array', items: { type: 'string' }, description: 'ports, radios, sockets, remotes' },
  },
}

const FINDINGS_SCHEMA = {
  type: 'object',
  required: ['findings'],
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['title', 'severity', 'detail'],
        properties: {
          title: { type: 'string' },
          severity: { type: 'string', enum: ['info', 'low', 'medium', 'high', 'critical'] },
          detail: { type: 'string' },
          evidence: { type: 'string', description: 'file:line or concrete grounding; empty if latent/design-level' },
          recommendation: { type: 'string' },
        },
      },
    },
  },
}

const VERDICT_SCHEMA = {
  type: 'object',
  required: ['verdict'],
  properties: {
    verdict: { type: 'string', enum: ['CONFIRMED', 'PLAUSIBLE', 'REFUTED'] },
    reasoning: { type: 'string' },
  },
}

const CADENCE_SCHEMA = {
  type: 'object',
  required: ['criticality', 'test_cost', 'recommended_frequency', 'rationale'],
  properties: {
    criticality: { type: 'string', enum: ['low', 'medium', 'high', 'critical'] },
    test_cost: { type: 'string', enum: ['low', 'medium', 'high'] },
    recommended_frequency: { type: 'string', description: 'e.g. "on every change + quarterly", "annually", "continuous/automated"' },
    recommended_methods: { type: 'array', items: { type: 'string' } },
    rationale: { type: 'string' },
  },
}

const EXPOSURE_SCHEMA = {
  type: 'object',
  required: ['audience'],
  properties: {
    audience: { type: 'string', enum: ['public', 'internal', 'vpn', 'token-required', 'oauth', 'physical-only', 'local-only', 'none'] },
    reachable_by: { type: 'string' },
    defenses_present: { type: 'array', items: { type: 'string' } },
    defenses_missing: { type: 'array', items: { type: 'string' } },
  },
}

const LENSES = [
  { key: 'authn-authz', ask: 'Authentication & access control: how does one authenticate and authorize to this surface? What auth is missing, default, or weak? Cite evidence.' },
  { key: 'platform-misconfig', ask: 'Known platform-specific misconfigurations and vulnerability CLASSES for this exact technology (name the platform, list its common misconfigs and whether this deployment is exposed to them). Cite evidence where checkable.' },
  { key: 'input-data', ask: 'Input handling & memory/data safety: parsing of untrusted input, injection, buffer/bounds issues, unsafe deserialization, output handling. Cite file:line.' },
  { key: 'secrets-supplychain', ask: 'Secrets & supply chain: grep for committed credentials/tokens/keys; assess dependency pinning and provenance, build/CI integrity. Report only grounded results; cite evidence.' },
]

const RULES = 'You are doing a DEFENSIVE, read-only security assessment of a system the operator owns. Do NOT attempt exploitation or send network traffic. Ground every claim in evidence (file:line or command output). Prefer FEWER, high-confidence findings over speculation. If you cannot verify something, say so rather than asserting it.'

// ---- discovery (when no surfaces passed) ----
async function discover(root) {
  const r = await agent(
    `${RULES}\nMap the attack surfaces present under ${root}. Read the tree and key files. ` +
    `Return one entry per DISTINCT surface (a repo/vcs, an embedded device, a web app, an API, a database, a local toolchain, a sensitive-data store, a cloud host, etc.). ` +
    `Do not invent systems that are not evidenced in the files.`,
    {
      schema: {
        type: 'object', required: ['surfaces'],
        properties: { surfaces: { type: 'array', items: {
          type: 'object', required: ['name', 'type', 'root'],
          properties: { name: { type: 'string' }, type: { type: 'string' }, root: { type: 'string' }, notes: { type: 'string' } },
        } } },
      },
      phase: 'Discover', label: 'discover',
    })
  return (r && r.surfaces) || []
}

// ---- main ----
const root = (args && args.root) || '/home/user/Module9'
const surfaces = (args && Array.isArray(args.surfaces) && args.surfaces.length)
  ? args.surfaces
  : await discover(root)

log(`Assessing ${surfaces.length} attack surface(s).`)

const assessed = await pipeline(
  surfaces,

  // Stage 1 — enumerate concrete assets
  (s) => agent(
    `${RULES}\nEnumerate the attack surface of: ${s.name} (type: ${s.type}). Root: ${s.root}. Notes: ${s.notes || 'n/a'}.\n` +
    `List concrete assets (endpoints, interfaces, ports, radios, files, protocols, deps, auth points), the tech stack, whether self-hosted/third-party/ephemeral, and classify it (web/db/api/embedded/repo/tooling/data).`,
    { schema: ENUM_SCHEMA, phase: 'Enumerate', label: `enum:${s.name}` }),

  // Stage 2 — analyze across lenses (+ a dedicated exposure/audience read), barrier per-surface only
  async (enumRes, s) => {
    const assets = enumRes || { assets: [] }
    const ctx = JSON.stringify(assets).slice(0, 4000)
    const lensRuns = LENSES.map(L => () =>
      agent(`${RULES}\nSurface: ${s.name} (${s.type}). Enumerated assets: ${ctx}\n\nLENS — ${L.ask}`,
        { schema: FINDINGS_SCHEMA, phase: 'Analyze', label: `${s.name}:${L.key}` }))
    const exposureRun = () =>
      agent(`${RULES}\nSurface: ${s.name} (${s.type}). Assets: ${ctx}\n\n` +
        `Determine EXPOSURE: which audience can reach this (public / internal / vpn / token-required / oauth / physical-only / local-only / none), by what path, what security mechanisms defend it, and what defenses are missing.`,
        { schema: EXPOSURE_SCHEMA, phase: 'Analyze', label: `${s.name}:exposure` })
    const [lensResults, exposure] = await Promise.all([
      parallel(lensRuns),
      exposureRun(),
    ])
    const findings = (lensResults || []).filter(Boolean).flatMap(r => (r && r.findings) || [])
    return { assets, exposure, findings }
  },

  // Stage 3 — adversarially verify each finding; drop REFUTED
  async (state, s) => {
    const verified = await parallel((state.findings || []).map(f => () =>
      agent(`${RULES}\nAdversarially verify this finding about ${s.name}. Try to REFUTE it. ` +
        `Only CONFIRMED if evidence clearly supports it; PLAUSIBLE if design-level/likely but not directly evidenced; REFUTED if wrong or not applicable.\n\n` +
        `Finding: ${JSON.stringify(f).slice(0, 1500)}`,
        { schema: VERDICT_SCHEMA, phase: 'Verify', label: `verify:${s.name}` })
        .then(v => ({ ...f, verdict: (v && v.verdict) || 'PLAUSIBLE', verify_reasoning: v && v.reasoning }))))
    const kept = verified.filter(Boolean).filter(f => f.verdict !== 'REFUTED')
    return { ...state, findings: kept }
  },

  // Stage 4 — testing cadence from criticality x cost
  async (state, s) => {
    const summary = (state.findings || []).map(f => `${f.severity}:${f.title}`).join('; ').slice(0, 2000)
    const cadence = await agent(
      `${RULES}\nRecommend a security TESTING CADENCE for ${s.name} (${s.type}).\n` +
      `Exposure: ${JSON.stringify(state.exposure)}\nFindings: ${summary}\n` +
      `Weigh criticality (blast radius, data sensitivity, safety impact) against test cost (effort, tooling, disruption). ` +
      `Give a concrete frequency and the methods that fit (e.g. automated dep scan on every push, manual review quarterly, pentest annually).`,
      { schema: CADENCE_SCHEMA, phase: 'Cadence', label: `cadence:${s.name}` })
    return { surface: s, assets: state.assets, exposure: state.exposure, findings: state.findings, cadence }
  },
)

const clean = (assessed || []).filter(Boolean)
log(`Assessment complete: ${clean.length} surface(s), ` +
    `${clean.reduce((n, a) => n + (a.findings ? a.findings.length : 0), 0)} verified finding(s).`)
return { assessed: clean }

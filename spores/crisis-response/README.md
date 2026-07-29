# `crisis-response` — reconstruct a cyber crisis, record custody, propose remediation

A shareable cosmon mission that, given a live security incident, **reconstructs**
what happened along two independent blind lines of inquiry, **records** an
auditable chain of custody, runs the **parallel regulatory clock-tree**, and
**proposes** remediation for a human to authorize. It **never acts on production
by itself.**

This spore is data, not code: it ships as plain configuration and never requires
building cosmon. Fill two required parameters, run `cs spore run`, and the whole
mission germinates.

Built by [Noogram](https://noogram.org). Licensing: see the repository root.

---

## 0. Read this first — **what a green seal does NOT mean**

The spore carries a `[spore.seal]`: a TLA+ model a model checker (**TLC**)
verifies before germination. It converts a class of *process* failures into
states the graph can never reach. It says **nothing** about the *content* any
node produces. Before anything else, read these five clauses — they are the
boundary of what a structural proof is, and they are reproduced verbatim in every
dossier this spore emits:

> **What a green seal does NOT mean:**
>
> 1. It does **not** mean any output is true, correct, complete, or safe.
> 2. It does **not** mean any regulatory deadline was met — only that the deadline
>    step cannot be silently skipped.
> 3. It proves properties **of a model** of the DAG; it is vacuous if the runtime
>    diverges from that model.
> 4. It is blind to any channel that is not a declared typed edge (shared disk,
>    shared context, side effects on the target system).
> 5. Every gate it protects is proven *present and unbypassable*, never proven to
>    *judge correctly*.

**TLC checks the model, not the system.** Its verdict is always of the form: *IF
the runtime obeys the typed DAG exactly as modeled, THEN property P holds on every
permitted execution.* Every "the seal proves…" below is silently prefixed by that
IF.

### Admissibility posture — an auditable dossier, never "admissible evidence"

This spore produces **an auditable analytic dossier on which a human expert can
rely.** It is **never** "admissible evidence," and it never says "the evidence is
sound" or "the seal certifies admissibility." "Admissible" is a legal conclusion
the seal cannot reach; asserting it is the single overclaim that discredits the
whole thesis on first contact with a regulator or a court. The AI is the expert's
**tool**, never an autonomous witness. Where the dossier would say "the evidence
is sound," it says instead: *"the process by which the evidence was produced is
complete, continuous, and integrity-protected."*

---

## 1. The classification-preserving invariant — why `drill-only` is the default

Under the EU AI Act (Reg. (EU) 2024/1689) a tool that **reconstructs, records, and
*proposes*, with a human acting** is *advisory* — not a safety component
*operating* critical infrastructure, and therefore **outside the Annex III
high-risk classification.**

> **The absence of autonomous remediation is what maintains the tool outside the
> Annex III high-risk classification. The shipped default `delivery = drill-only`
> is therefore a *compliance boundary*, not a preference.**

The instant the spore acts autonomously on a live estate it plausibly becomes
high-risk and inherits the full provider regime. So the actuator is gated four
ways at once (§3, the floor), and the default refuses a live actuator outright.
Two boundaries would independently flip the tool and are both held: it never
attributes the attack to a named natural person (Art. 5 profiling boundary,
defamation, presumption of innocence), and it never operates the estate
autonomously.

---

## 2. The topology — the "Custody Spine" and the legal clock-tree

Two branches fork at `intake` and rejoin only at `verdict`.

```
  trace (always-on sidecar, root+leaf — the flight recorder)

  intake ──► sensitivity-gate ──► evidence-capture ──► evidence-preservation-gate
                (fail-closed)                              (fail-closed, SEALS custody)
                                                                │
             ┌──────────────────────────────────────────────────┼───────────────┐
             ▼                                                    ▼               ▼
      red-reconstruct                                     blue-investigate   corroboration
      (attacker's eye)                                    (defender's eye)   (non-LLM, independent)
             │   two BLIND lines — NO edge between them        │               │
             └───────────────────┬────────────────────────────┘               │
                                 ▼                                             │
                          confrontation  (labels; NEVER votes)                 │
                                 ▼                                             │
                     re-investigate  (bounded epistemic loop —                 │
                        confrontation ⇄ re-investigate only;                   │
                        exits on reconciliation, BLOCKS at the cap)            │
                                 ▼                                             │
                          containment-plan  (PLAN only)                        │
                                 ▼                                             │
                             dissent  (assigned devil's advocate)              │
                                 ▼                                             │
                           second-look  (unavoidable pause)                    │
                                 ▼                                             │
                        remediation-gate  ◄───────────────────────────────────┘
                        (BLOCKING human countersign, fail-closed)
                                 ▼
                          remediation  (SINGLE shot; live actuator only if delivery=live)
                                 │
  intake ──► regime-route ──► classification-ratification ──► notice(regime)…  │
                (DORA-over-NIS2)   (human leg, fail-closed)   (DISJOINT sinks)  │
                                                                    │          │
                                                       cross-notice-consistency │
                                                                    │          │
                                                                    ▼          ▼
                                                                  verdict ◄─────┘
                                                                    ▼
                                                                chronicle
```

**The blinding is edge-disjointness between the two lines, checked by TLC.** The
comparative value of two independent lines rests on their being independent when
they seal. A rule in a brief does not hold that; against a live adversary present
in the estate during the run, convergence is the *most forgeable* signal (a single
universal injection can steer both lines identically). So the blinding is a
property of the dependency graph — the two lines are mutually unreachable along
blocked-by, and every confrontation node depends on both. Wiring one line
downstream of the other (the "cheap" simplification that silently forges
convergence) is a seal **violation**, not a judgement call. **Convergence informs
a human; it never gates an irreversible action.**

**The epistemic loop is confined to the epistemic sub-graph.** `re-investigate`
re-opens the two blind lines forward, up to `epistemic_rounds`, until the disputed
set is empty (reconciled) or it BLOCKS and escalates at the ceiling. It never
re-opens evidence capture, never re-seals custody, and has no edge to the actuator
path — reconstructing "what happened" can iterate safely; acting on a live estate
cannot.

---

## 3. The floor — four seal edges, or `drill-only`

Four controls are *actual seal edges*, checked by TLC, before this spore may act
against a real crisis. For these four, a documented convention is not a mitigation;
it is a substitution that turns an incident-response tool into an attacker's
demolition contractor.

| # | Floor property (seal edge) | Forbids |
|---|---|---|
| 1 | **EvidenceBeforeRemediation** | any remediation while custody is unsealed — never touch the wreckage before the recorder is secured |
| 2 | **ActionRequiresSealedProvenance** | remediation on anything but an AUTHORIZED gate, which (via ArtifactFlow) rests on the sealed manifest — no injected byte reaches the actuator around it |
| 3 | **CorroborationBeforeAction** | an AUTHORIZED gate without a present, independent, **non-LLM** corroboration — the countersign never rests on agent agreement alone |
| 4 | **TwoLegCountersign** | an AUTHORIZED gate without **two distinct signers** — no single-signer rubber-stamp |

Until all four hold **and** the escrow holders are pre-provisioned, the spore ships
`delivery = "drill-only"`: it reconstructs, records, and proposes on a drill, and
**refuses to touch a live actuator.** All four are wired and checked in this
package (see `spore.tla` and §7).

The remediation gate additionally requires a **RECONCILED** epistemic loop, a
present **dissent record**, and an unavoidable **second-look** — an EXHAUSTED loop
means block-and-escalate, never authorize. The countersign attests to **specific
facts** (which host, which evidence hash, which irreversible effect), never a
global "approve," so the clock cannot degrade it to a rubber-stamp.

---

## 4. The live-phase custody escrow — declared out loud

During an active compromise **the client estate is the least trustworthy storage
that exists** — the attacker may already own it, and the crown-jewels
reconstruction stored there becomes a real-time map handed to the adversary. Yet
the trace belongs to the client. Those two virtues silently contradict during the
live phase.

The reconciliation is an **out-of-band escrow of the forensic trace for the
duration of the live phase**, restored to full client ownership at closure. This
is stated here, out loud, because it bends pure "the client owns the trace" and a
bend left silent reads as nervousness after the fact.

**Custody therefore has two declared phases** — *live* (out-of-band escrow, keys
off the compromised estate) and *closed* (full client ownership restored). The
transition between them is **an event attested from outside the system under
audit and anchored externally** — never self-attested, never a silent setting. An
unattested escrow *fabricates* the very discontinuity it was meant to prevent: the
two transitions are either the strongest link in the chain or the break, with no
neutral middle.

The escrow is **out-of-band by design and outside the seal** (the seal is blind to
any channel that is not a typed edge). Its integrity comes from: a data key split
**M-of-N with at least one holder independent of both the client IR team and the
tool provider**; the trace's **Merkle root carried across the boundary to an
external, non-rewritable anchor** (RFC 3161 trusted timestamp / transparency log —
never a public blockchain, whose crisis-time latency and permanent metadata leak
disqualify it); an **externally-attested** transition; **integrity kept separate
from confidentiality** (encryption gives confidentiality, never integrity); and
**every live-phase access logged to the anchor.** One anchors a *root*, never
*content* — the anchor sees a hash and a time, never a byte of the incident.

**Pre-provision the holders before a live germination.** A crisis is the worst
time to recruit a custodian, so a `delivery = live` germination with an empty
`escrow_holders` set **refuses** at the preservation gate. Set
`escrow_holders`, `escrow_m`, `escrow_n` (floor: N ≥ 3, M ≥ 2, ≥ 1 independent
holder), and `external_anchor` first.

---

## 5. The red line is **two** things — never sell the second as the first

**Part one — a sealed type-gate.** `NoOffensiveArtifact` closes the emission-*type*
axis: no node can be configured to emit an artifact whose type is
`offensive-playbook` or `attack-procedure`. This has real legal teeth (Directive
2013/40/EU Art. 7 — producing a tool primarily designed for illegal access;
dual-use export control, Reg. (EU) 2021/821). It is drawn on the *irreversibility /
artifact-type* axis, never on severity — severity is a label an attacker can write.

**Part two — an unsealed content discipline.** A *permitted* type (an
`attack_reconstruction`) can still carry a reproducible offensive procedure, and
content danger is undecidable — no seal reaches it. This discipline is **NOT
sealed**, and this document does not claim otherwise. It is a **convention that
holds only as far as human discipline holds**, presented here as exactly that:
reconstruct only at the granularity needed for remediation and attribution ("the
attacker exploited the auth bypass on host H") — **never a working payload** — and
**default reconstructions to TLP:AMBER/RED** so the recipient's forwarding is a
governed act under its own norms.

> **The two are different things, and the difference is legally costly to blur.**
> The sealed type-gate (`NoOffensiveArtifact`, P8) closes **only the artifact-TYPE
> emission axis** — it is a TLC-checked seal edge with real teeth (Directive
> 2013/40/EU Art. 7; dual-use export control, Reg. (EU) 2021/821). The
> content-reproduction discipline above is an **unsealed convention** on a
> *permitted* type. **Never phrase the content discipline in a way that would let
> it pass for the sealed gate** — writing "the seal prevents offensive content"
> would claim, falsely, that a structural proof covers a Rice-undecidable content
> property, and the legal teeth of the real gate make that overclaim expensive.
> The seal forbids an offensive *type*; the discipline governs offensive *content*.

---

## 6. The regulatory clock-tree — ordered, not timed

`regime-route` is **not** a three-way fan-out. **DORA is *lex specialis* and
displaces NIS2's incident-reporting obligation for a financial entity in its
scope** (NIS2 Art. 4 yields to an equivalent sector-specific Union act; DORA Art. 2
is that act). So for an EU financial institution the live sinks are **DORA + RGPD in
parallel**, with NIS2 suppressed for the same incident; NIS2 returns only for an
entity *outside* DORA scope. Routing both DORA and NIS2 for one financial entity is
a **malformed graph** — a `cs spore validate` well-formedness expectation (the
`regimes` list must not contain both `dora` and `nis2`), not a seal property.

The clock-tree **forks at intake** so a slow investigation cannot consume the whole
budget. `NoSilentClockMiss` proves **ordering** — the mission cannot close with an
applicable regime's notice never accounted for (drafted, or an explicitly recorded
escalation) — and **never timeliness.** The model is untimed; TLC has no wall
clock. Real-time deadline enforcement is an operational **watchdog**, explicitly
outside the seal. Selling this as "TLC guarantees the deadline" is a
misrepresentation.

**The graph may pre-fill criteria and run the deterministic arithmetic; it stops
at every risk / criticality qualifier and at fixing the legal awareness moment.**
That fixing is a `classification-ratification` human leg, fail-closed
(`RatifiedClassificationBeforeNotice`): no notice drafts until a human attests the
classification, the risk tier, and the awareness timestamp for that regime.
Automation is **asymmetric** — trip *toward* notification, never innocent *away*
from it; the only route to not-notifying (an exemption) is a qualified human's.

---

## 7. The seal — the full property set

`spore.tla` + `spore.cfg`, verified by TLC. Nineteen properties:

| Property | What it forbids (the refutation target) |
|---|---|
| **Termination** (liveness) | a polymer that never drains |
| **EvidenceBeforeRemediation** (floor) | remediation while custody unsealed |
| **ActionRequiresSealedProvenance** (floor) | remediation on a non-AUTHORIZED gate |
| **CorroborationBeforeAction** (floor) | AUTHORIZED without a non-LLM corroboration |
| **TwoLegCountersign** (floor) | AUTHORIZED without two distinct signers |
| **ClassifyBeforeEscalate** | an external-capable node without the sensitivity gate upstream |
| **RoutingConfinement** (envelope, over *realized*) | the sensitive node's *realized* locality outside its envelope, in any post-fallback state |
| **RoutingEnvelopeDeclared** (plan-side) | a *plan-selectable* locality outside a node's envelope |
| **ModelLockOnSensitive** (fail-closed) | a sensitive node realizing the guardrail-free model, even under an induced fallback |
| **FallbackStormIsIOC** | a refused sensitive-node fallback silently absorbed instead of raised as an IOC |
| **NoSilentClockMiss** (ordering) | closing with an applicable regime's notice unaccounted |
| **RatifiedClassificationBeforeNotice** | a notice drafted without the three attested fields |
| **BlindBeforeConfrontation** | the two lines reachable from each other along blocked-by |
| **TraceCompleteness** | a node Done without emitting its step record |
| **SoDCapability** | one actor holding both evidence-write and production-write |
| **NoOffensiveArtifact** | a node emitting an offensive-playbook / attack-procedure *type* |
| **NoResourceCollision** | two nodes (or two loop rounds) writing the same path |
| **DeterministicParametrization** | the node set drifting from `20 + \|regimes\|` |
| **ArtifactFlow** | a required artifact with no upstream producer |

**RoutingConfinement is the envelope form** — *every model the plan may select for
node N lies within N's sensitivity-permitted set* — **not** "N runs only on model
C" (which would make the legitimate in-envelope guardrail-free fallback a
self-inflicted violation). The guardrail-free fallback is pre-declared **inside**
the envelope of internal nodes via `fallback_model`; a restricted node's envelope
excludes it, and an out-of-envelope hop aborts fail-closed.

### 7a. Routing is the differentiator, and it is carried explicitly

Across the wider guardrail ecosystem, automatic fallback almost universally treats
a *failed* step. But **a model refusing a legitimate task is not a failure**: the
call *succeeds*, the machine returns polite text, and the report keeps writing
itself on a refusal it mistakes for an answer. An adversary can seed
guardrail-tripping content precisely to *induce* that fallback. So routing is
carried **explicitly** in both `spore.tla` and `spore.toml`, as three named things:

1. **The envelope form, quantified over *realized* bindings** — `RoutingConfinement`
   checks the locality the sensitive node *actually ran on* (every post-fallback
   state TLC explores), not the planned model. The plan-side declaration is the
   separate `RoutingEnvelopeDeclared`.
2. **A fail-closed model-lock on sensitive nodes** — `ModelLockOnSensitive`: a
   restricted node *purely forbids* the guardrail-free model, so an
   attacker-induced fallback cannot route consequential authorship (a regulator
   notice, a containment authorization) onto the least-aligned model.
3. **The fallback storm as an IOC** — `FallbackStormIsIOC`: a refused induced
   fallback on a sensitive node is recorded as a compromise indicator, never
   silently absorbed. A burst of close refusals on sensitive nodes is a **signal,
   not a statistic**.

**This "who, human, asked what" criterion is not home-grown.** The EU AI Act (Reg.
(EU) 2024/1689, published 12 July 2024) writes it two years ahead of us: **Art. 12
(automatic recording of events / logging over the system's lifetime)** and **Art.
14 (human oversight, including the identity of the natural persons involved).** The
flight-recorder (`trace`, §11) and the realized-model provenance record answer
exactly that opposable antecedent.

### Verifying the seal yourself (prerequisite: a JVM + TLC)

```sh
export TLA2TOOLS_JAR=/path/to/cosmon/docs/specs/tla2tools.jar
java -XX:+UseParallelGC -cp "$TLA2TOOLS_JAR" tlc2.TLC \
     -workers auto -config spore.cfg spore.tla
# expect: "Model checking completed. No error has been found."
```

**Fail-closed if TLC is absent.** `cs spore run` on a released `cs` may report
"TLC unavailable" and refuse unless you pass `--allow-unchecked-seal` (the status
line stays honest: "seal: present, NOT verified"). **If you have no JVM at all,
you cannot verify the seal on this machine** — germinate with
`--allow-unchecked-seal` and verify the proof on a machine that has Java, or accept
the unverified status knowingly. The refusal is by design: a silent pass here would
be the worst outcome. `spore.cfg` lists the non-vacuity checks and the negative
tests (each mutation that must be REJECTED) to run when you verify.

---

## 8. Worst-case cost, stated honestly

Node calls, per germination (each node = one `task-work` molecule ≈ 2 model
calls). The **epistemic loop rounds are NOT fixed units of spend** — later rounds
re-read accumulated disputed findings, so a round is not a flat cost, and the loop
stops the moment the disputed set is empty.

| Component | Calls | Note |
|---|---|---|
| Custody spine (fixed nodes) | ~15 nodes | intake → verdict, once each |
| Legal clock-tree | ~3 + \|regimes\| | regime-route, ratification, cross-notice + one notice per regime |
| Epistemic loop | `0` at `epistemic_rounds=1`; up to `~2 × (rounds−1)` extra blind-line pairs + a confrontation per extra round | **worst case = cap-exhausted**; early reconciliation only reduces it |
| trace + chronicle | 2 | always-on sidecar + fold |

Worst case is the cap-exhausted loop with the largest `regimes` list; the default
(`epistemic_rounds = 1`, `regimes = [dora, rgpd]`) is the floor. `epistemic_rounds`
is capped at 5 (the sealed `max_instances`); `cs spore validate` refuses a larger
value.

---

## 9. Recipient prerequisites

- **`cs` on `PATH`** — the cosmon CLI (`cs spore validate/run/export`).
- **A model adapter** — `claude` (the default) or another; the formulas pin
  `claude-opus-5` / `claude-sonnet-5` on their steps. A recipient with one model
  sets a global override (`ANTHROPIC_MODEL=<m>` or `cs tackle --model <m>`), which
  ranks above every pin (`models = single`).
- **A JVM + TLC** — only to *verify the seal*; germination and `cs spore validate`
  never need it. Without it, run `--allow-unchecked-seal` (§7).
- **A driver-capable `cs`** (with `wait` + `run --resident`) — only for
  `epistemic_rounds ≥ 2`; the loop refuses fast otherwise and tells you to
  re-germinate with `epistemic_rounds = 1`.
- **Pre-provisioned escrow holders** — only for `delivery = live` (§4).
- **The spore's formulas copied into your mission's `.cosmon/formulas/`** — as with
  any spore.

### Model & adapter access

`model` names *which* model; `adapter` names *which runtime* talks to it. They are
independent axes and both travel on the formula step (a spore node has no `model`
field). To widen input diversity across the two blind lines (threat register B4),
point one line at a codex-pinned copy of `task-work-reasoning` (with the `model`
pin removed — a `claude-*` id is not legal for the `codex` adapter) and leave the
other on `claude`; split by **node**, not by formula.

---

## 10. Quickstart

```sh
# Validate + expand as a dry run (germinates nothing) — the safe first move:
cs spore validate spore.toml \
    --var incident="incident-alpha" \
    --var incident_report="Anomalous outbound traffic observed from a segment; \
        first signal at T0; scope under investigation."

# The default is drill-only: reconstruct, record, propose — no live actuator.
cs spore run spore.toml --var incident="…" --var incident_report="…" \
    --allow-unchecked-seal          # if your cs reports "TLC unavailable"

# Export a content-addressed bundle for sharing:
cs spore export spore.toml --out dist/
```

For a live actuation (`delivery = live`) you must additionally pre-provision the
escrow holders and verify the seal green on a JVM host first — see §4 and §7.

---

## 11. Accountability, out loud

A preventable destructive action must never become *nobody's*. Ownership is named,
as a cascade with a discharge condition at each link:

- The **tool author** owns the decision's *shape* — and discharges it by shipping
  the structural counter-measures (the two blind lines, the assigned dissenter, the
  non-LLM corroboration, the two-leg countersign, the unavoidable second-look) as
  seal edges and graph structure, which this package does.
- The **operator** owns the *germination* — and discharges it by honoring the
  drill-only floor and not germinating live with the corroboration disabled.
- The **recipient organization** owns the *culture the spore cannot ship* — two
  real minds behind the two legs, protected wall-clock time behind the second-look,
  a signer distinct from the investigator — and discharges it by staffing those
  seats.
- The **human signer** owns the *act* — legitimate and non-diffusible once the
  three upstream links have discharged.

The flight-recorder (`trace`) binds signer identity + the specific facts attested +
the corroboration artifact + the live dissent record, hash-chained and
append-only, so "the system authorized a wipe" becomes "actor X attested facts F
against corroboration C, over dissent-record D, at position P" — a sentence with a
subject.

---

*Built by [Noogram](https://noogram.org). Public facts cited by name: DORA (Reg.
(EU) 2022/2554), NIS2 (Dir. (EU) 2022/2555), RGPD (Reg. (EU) 2016/679), the EU AI
Act (Reg. (EU) 2024/1689), Directive 2013/40/EU, dual-use export control (Reg. (EU)
2021/821), NIST SP 800-61r3 and SP 800-86, OASIS CACAO v2.0, STIX 2.1, the Traffic
Light Protocol, RFC 3161 trusted timestamps, RFC 6962. No partner, client, or
commercial detail appears. Licensing: see the repository root.*

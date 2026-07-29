# Crisis-response spore — seal-property register (DESIGN)

**Status:** design only. This file is a *register*, not a seal. It ships no
`spore.toml`, no `spore.tla`, no `spore.cfg`, and no README. A later
spore-authoring molecule turns the entries below into a TLA+ model (`spore.tla`)
and its configuration; this document is the blueprint that authoring reads from.

**Scope:** consolidate the candidate seal properties for the future crisis-response
spore into one entry-per-property register — the **eight** from the opening round
(P1–P8) plus **P9**, added by the later legal / regulatory / evidentiary round. Each
entry states,
in a form a model checker (TLC) can mechanically refute, the single reachable
state the property forbids — then, with equal weight, what a reader must **not**
infer from it and the runtime residue the property leaves uncovered.

**Who this is for:** a recipient who has none of our agents, none of our tooling,
and none of the conversation this came out of. Everything needed to read it is
below.

---

## 0. What a seal is, and the one fact that governs the whole register

A **spore** is a shareable template of a whole mission: a set of worker roles, a
DAG of typed, ordered steps, a parameter schema, and — optionally — a **seal**: a
TLA+ model that a model checker (**TLC**) verifies *before* the mission is allowed
to expand into live work. The seal names safety properties and TLC either proves
them or hands back a concrete counterexample trace.

One fact governs everything below, and every recipient-facing document must print
it in bold:

> **TLC checks the model, not the system.** TLC exhaustively explores the reachable
> states of the TLA+ model of the *expanded DAG* and reports whether each named
> invariant holds in every state. Its verdict is always of the form: *IF the runtime
> obeys the typed DAG exactly as modeled, THEN property P holds on every permitted
> execution.* It says nothing about (a) whether the runtime actually obeys the model,
> (b) the content any node produces, or (c) anything not represented as state or as a
> typed edge.

Every "the seal proves…" in this register is silently prefixed by that IF. This is
not a hedge; it is the boundary of what a structural proof *is*. A seal converts a
class of **process** failures into unreachable states. It cannot touch **content**
failures — the truth, timeliness, or safety of what a worker produces. Those are
irreducibly runtime, and for the truth-of-output class, irreducibly undecidable
(see §3).

### How to read the "forbidden reachable state" column

A TLA+ invariant is a predicate that must hold in *every* reachable state:
`∀ s : ¬bad(s)`. TLC *refutes* it by exhibiting one reachable `s` where `bad(s)`
holds. So each property below is written as its refutation target — **"there is no
reachable state `s` such that …"** — because that is exactly the shape TLC checks:
name the bad state, and let TLC try to reach it. If it can, the seal fails closed
and germination is refused; if it provably cannot, the property holds.

---

## 1. The properties (P1–P8 from the opening round; P9 from the legal round)

Each entry has four parts:

- **Forbids** — the single forbidden reachable state, as a TLC refutation target.
- **Must NOT be inferred** — the stronger claim a reader will be tempted to read
  into it, which the property does *not* make.
- **Runtime residue** — what stays uncovered and must be handled by a watchdog, a
  human, or defense-in-depth, *never* by this property.
- **Provenance** — which panel analysis the property comes from.

---

### P1 · EvidenceBeforeRemediation

**Forbids.** There is no reachable state `s` in which a remediation node is active
— `remediation.status ∈ {proposed, applied}` — while the evidence-preservation gate
has not reached `status = sealed`.

> Refutation target: `∃ s : remediation.status ∈ {proposed, applied} ∧
> evidence_preservation_gate.status ≠ sealed`.

The mechanism is a typed **blocking** edge plus an artifact-flow constraint:
remediation *requires* a sealed evidence manifest that only the preservation gate
*produces*, so re-pointing remediation upstream of the gate is refuted before
germination. This is the flight-recorder invariant: you never touch the wreckage
before the recorder is secured.

**Must NOT be inferred.** Not "remediation only fires when the evidence is
*sufficient* or *valid*." The gate's pass/fail *judgment* is runtime oracle content.
The seal proves the gate is *on the path and unbypassable*, never that the gate
*judged the evidence correctly*.

**Runtime residue.** Whether the sealed evidence is actually complete or forensically
sound; whether a human read it before authorizing; whether the remediation proposed
is itself safe. All of that is content and human judgment, outside the property.

*Provenance: architect P1 · adversary's #1-ranked (missing it = "destroy your own forensics with your own playbook").*

---

### P2 · ClassifyBeforeEscalate

**Forbids.** There is no reachable state `s` and node `n` such that `n` is bound to
an external-locality provider while `n`'s data-sensitivity class is still unset.

> Refutation target: `∃ s, ∃ n : n.realized.locality = external ∧
> n.sensitivity_class = unset`.

This is the property that makes sensitivity routing mechanical rather than
aspirational: a node cannot leave the building before someone has decided how
sensitive it is.

**Must NOT be inferred.** Not "the routing decision was *correct*" — i.e. not that
the data really was low-sensitivity. That the class was *set* is a graph fact; that
the class was set *rightly* is the gate's runtime output, which the seal does not
reach.

**Runtime residue.** The correctness of the classification itself; a misclassification
that labels sensitive data as public and then legitimately routes it external is a
content error the seal cannot see.

*Provenance: architect P2 — the hinge of routing-as-format.*

---

### P3 · RoutingConfinement (envelope form)

**Forbids.** There is no reachable state `s` — **including every post-fallback state**
— and node `n` such that the model *realized* at `n` falls outside the locality /
provider-family set permitted by `n`'s sensitivity class.

> Refutation target: `∃ s, ∃ n : n.realized ∉ envelope(n.sensitivity)`,
> where `envelope` is the statically-declared set of permitted (locality,
> provider_family) pairs for that sensitivity class.

Because a guardrail refusal may cause a node to fall back to a different model
*mid-mission*, the model a node *actually* runs on is **realized** state, not static
config. The fallback is modeled as a nondeterministic TLA+ action, so TLC explores
post-fallback states too. Two failure modes it then catches: a `restricted` node
statically cabled to an external provider (invariant false in the initial state), and
a fallback that would hop a `restricted` node onto an external guardrail-free model
(invariant false in a reachable post-fallback state).

**This is the property most at risk of being stated wrongly**, so the honesty
constraint is carried verbatim in §2.2. In short: the property is the **envelope**
form — *every model the plan may select for node N lies within N's
sensitivity-permitted set* — and **not** "N runs only on model C." Sealing "N runs
only on C" would make the *legitimate* guardrail-free fallback a self-inflicted seal
violation and block germination. The guardrail-free fallback is pre-declared **inside**
the envelope; a fallback that stays in-envelope is not a violation, and a proposed
hop *outside* the envelope must abort, fail-closed, with that abort itself recorded.

**Must NOT be inferred.** Not "node N ran on model C" — that is a runtime fact,
verified after the fact from the trace, never a seal theorem. Not "the local model
was good enough" — capability is a quality question, not a reachability property. Not
"the two blind branches used genuinely different models" unless model class is what is
statically bound.

**Runtime residue.** Which concrete model actually answered (recorded, not sealed —
see the fallback-trace schema in §2.3); whether the confined local model was competent
for the task; leakage through any channel that is not a typed edge.

*Provenance: architect Q4 (`RoutingConfinement` over realized bindings) + turing (seal the envelope, not the point).*

---

### P4 · NoSilentClockMiss (ordering, not timeliness)

**Forbids.** There is no reachable state `s` in which the mission is closed while a
mandatory regulatory notice for an applicable regime is still undrafted.

> Refutation target: `∃ s : mission.status = closed ∧ ∃ regime ∈ applicable :
> notice[regime].status = undrafted`.

A regulatory obligation can never be silently *dropped from the process*: a miss
becomes a *recorded, escalated* miss rather than a vanished one, because the
notice-accounting step is structurally unavoidable on every terminal path.

**Must NOT be inferred.** Not "the deadline was met." The DAG model is **untimed** —
TLC has no wall clock and cannot assert that four real hours did or did not elapse.
The property proves *ordering* ("you cannot finish with a notice never drafted"),
never *timeliness* ("within 4 hours"). This constraint is carried verbatim in §2.2;
selling this as "TLC guarantees the 4h deadline" is the misrepresentation the register
exists to prevent.

**Runtime residue.** The actual wall-clock deadline. Real-time enforcement is a
**watchdog** concern — an operational timer that fires outside the seal — listed in §3.

**Well-formedness note — the `applicable` set is computed, not assumed.** `applicable`
in the refutation target is not a free variable. For a financial entity **DORA is
*lex specialis* and displaces NIS2's incident-reporting obligation** (NIS2 Art. 4
yields to an equivalent sector-specific Union act; DORA Art. 2 is that act), so the
live regimes are normally **DORA + RGPD in parallel**, NIS2 suppressed for the same
incident and returning only for a recipient outside DORA scope. `regime-route`
resolves entity scope, applies this displacement, and keeps RGPD parallel — a
deterministic legal rule encodable as a **`cs spore validate` well-formedness
expectation** (a mis-computed `applicable` set is a malformed graph, caught before
the seal ever explores state). *Source: the contract-jurist seat governing
finding; legal register §1.1.*

*Provenance: architect P3 / turing.*

---

### P5 · BlindBeforeConfrontation

**Forbids.** There is no reachable state `s`, prior to the confrontation node, in
which one investigative branch (pincer) has consumed the other's output.

> Refutation target: `∃ s reachable before confrontation :
> (branchA consumed branchB.output) ∨ (branchB consumed branchA.output)`.

The two branches fork off the *sealed* evidence with no edge between them, so their
conclusions are formed independently until they are deliberately confronted. Cabling
one branch below the other is a seal violation TLC catches — static reachability, the
thing TLC does best.

**Must NOT be inferred.** Two distinct over-readings, both wrong:

1. Not "the branches are causally independent." The seal proves the *branches do not
   wire together in the DAG*; it does not prove independence in the world. See §4 on
   why the `⊥` glyph is banned for exactly this reason.
2. Not "convergence between the branches is therefore trustworthy." Blindness is a
   property of the *wiring*, never of the *inputs*. A single injected input that both
   branches read — a *universal injection* — steers them to the same wrong conclusion
   while every blindness edge still holds. Independent wiring does not buy independent
   inputs. Consequently: convergence between blind branches may *inform* a human; it
   must **never** be wired to auto-promote an irreversible action. Disagreement is the
   safe state; convergence is the most forgeable signal against a live adversary.

**Runtime residue.** Leakage through an **out-of-band channel** the model never sees —
a shared scratch directory, a shared context store, a cache. Proving blindness on the
typed edges says nothing about a shared filesystem. And the input-independence gap
above: real, and outside any graph property.

*Provenance: architect P4 / turing #5 (the canonical case) · convergence-inversion warning carried from adversary D-2, resolved as "never auto-promote on convergence."*

---

### P6 · TraceCompleteness

**Forbids.** There is no reachable state `s` in which a node has completed without
having emitted its step record.

> Refutation target: `∃ s, ∃ n : n.status = complete ∧ n.step_record = ∅`.

This is the cheap, load-bearing one. The product being sold *is* a complete,
continuous, on-disk chain of custody; this property turns that continuity from an
incidental log into a *certified* one — "no node completes without emitting its
record." It is exactly the chain-of-custody continuity the strategic frame already
depends on, promoted from asserted to proven at near-zero cost.

**Must NOT be inferred.** Not "the trace is *true*," and not "the record is
*complete in content*." The property proves a record was *emitted* for every completed
node, never that the record's contents are accurate or that they capture everything
that mattered. Continuity-of-process is **necessary, not sufficient** for
admissibility: the other prongs (data provenance, algorithm integrity) still stand on
their own.

**Runtime residue.** The integrity of the record after emission (handled by the
hash-chained, git-tracked delivery, not by this property); the *content* correctness
of each record; anything that happened through a channel that was never a modeled edge.

*Provenance: turing — "promote trace-completeness to a named property"; the surprising, cheap, sellable one.*

---

### P7 · SoD-capability (the capability half only)

**Forbids.** There is no reachable state `s` in which a single actor holds both
evidence-write capability and production-write capability.

> Refutation target: `∃ s, ∃ actor : actor.evidence_write = true ∧
> actor.production_write = true`.

Separation of duties, split into two halves that live in two different places:

- The **static** half — "no single node is *declared* as both investigator and
  remediator" — needs no state exploration. It is a well-formedness constraint checked
  at spore-validation time (`cs spore validate`), **not** a seal property. Spending
  seal complexity on what the type system already refuses is misallocation.
- The **capability** half — no *reachable state* grants one actor both
  evidence-write and production-write — is the dynamic residue that earns a TLC
  invariant, and it is the entry above.

**Must NOT be inferred.** Not "the two duties are performed by different *people*" in
any sense richer than the modeled write-capability. The seal knows about modeled
capabilities on modeled actors; it does not know who is at the keyboard.

**Runtime residue.** Collusion or capability escalation that happens outside the
modeled capability set; a human who legitimately holds one capability being pressured
to act beyond it.

*Provenance: architect P5 — capability half only; static half moved to `cs spore validate` (divergence D4).*

---

### P8 · NoOffensiveArtifact

**Forbids.** There is no reachable state `s` in which any node emits an artifact whose
type is `offensive-playbook` or `attack-procedure`.

> Refutation target: `∃ s, ∃ n : n emits artifact a ∧
> a.type ∈ {offensive-playbook, attack-procedure}`.

This is the red line made mechanical: the machine *cannot be configured to* emit an
offensive artifact type, rather than a promise that we won't. Absence of the forbidden
artifact type is a reachability property over the typed artifact set; if a spore is
authored so that such a type is emittable, germination is refused.

**The red line lives on the irreversibility / artifact-type axis, not on severity.**
Severity is a label an attacker can write — inject a downgrade, self-classify as low,
and a severity-keyed red line unlocks. Artifact *type* and *irreversibility* are
properties of the action the attacker cannot relabel. A red line keyed on an
attacker-controllable field is decorative.

**Must NOT be inferred.** Not "the system cannot produce anything harmful." It cannot
emit an artifact *of the forbidden types*; a well-typed artifact of a *permitted* type
whose *content* is nonetheless harmful passes every type-checking edge (the type is not
the meaning — see §3). The property closes a category, not a capability-to-harm in
general.

**Runtime residue.** Harmful content smuggled inside a permitted artifact type; misuse
of a permitted, legitimately-defensive artifact. Content danger is undecidable in
general (§3) and is handled by human review and defense-in-depth, never by this
property.

**The red line is TWO things (ratified — LD2).** This property is the sealed
**type-gate**: it closes the *action / emission-type* axis, and there its legal
teeth are real — Directive 2013/40/EU Art. 7 (producing / making available a tool
primarily designed for illegal access, interception, or data/system interference)
plus dual-use export control (Reg. (EU) 2021/821). It does **not** close the
*knowledge-reproduction* axis: an artifact of a *permitted* type (e.g.
`attack-reconstruction`) can still carry a reproducible offensive procedure, and
content danger is Rice-undecidable and cannot be sealed. That second axis is
governed by a distinct, **unsealed content-reproduction discipline** — minimize
offensive granularity, default reconstructions to **TLP:AMBER/RED** — carried in the
threat register's List B (its content-reproduction discipline row under LD2). **Keep
P8 in List A for artifact-*type* emission only, and never sell the unsealed content
discipline as the sealed type-gate.**

*Provenance: godin / jobs / adversary — red line on the irreversibility axis; two-part
split from the adversarial-judge seat Q11 + the contract-jurist seat
Q12 (legal register §5.2), ratified LD2.*

---

### P9 · RatifiedClassificationBeforeNotice (fail-closed — added by the legal round)

**Forbids.** There is no reachable state `s` in which a notice-draft node for a
regime is active while the human-ratification leg for that regime has not attested
all three of **classification**, **risk tier**, and **awareness timestamp**.

> Refutation target: `∃ s, ∃ regime : notice_draft[regime].status = active ∧
> ¬(ratification[regime].classification ∧ ratification[regime].risk_tier ∧
> ratification[regime].awareness_timestamp)`.

The reportability *decision* is a legal judgment the graph may not make. The graph
may resolve entity scope, pre-fill the criteria, and run the deterministic
arithmetic; it must **stop** at every potentiality / risk / criticality qualifier
and — sharpest — at **fixing the legal awareness moment** that starts each
regulatory clock, a fact-in-world it cannot check at decision time. So a **fail-closed
human-ratification leg** sits between the candidate determination and any notice-draft
node; by the same mechanic as A8's authorization leg, an absent or incomplete
ratification **refuses**, it does not default-allow. This is the legal specialization
of the threat register's B6 fact-attesting countersign — a `GateFailClosed`-family
property, not a new mechanism — and it aligns with P4's ordering without asking the
seal to reason about timeliness.

**Must NOT be inferred.** Not "the classification was *correct*," not "the awareness
moment was fixed *rightly*," not "the deadline was met." The seal proves the leg is
*present, complete in its three fields, and unbypassable* — never that the human
judged the classification, the risk tier, or the clock-start correctly. As with every
gate: proven present and unbypassable, never proven to *judge correctly*.

**Runtime residue.** The truth of the classification and risk tier; the legal
correctness of the fixed awareness moment; whether the human corroborated the facts
before attesting them. Note that the **clock-start timestamp is itself a provenance
artifact** — *who* classified, *when*, *on what basis* — and belongs in the
realized-model provenance record (§2.6) and the flight-recorder trace, not merely in
the notice body.

*Provenance: legal round — the contract-jurist seat Q2 + the research-librarian / forensics seat
Q1 (clock-start as provenance); legal register §1.4. Ratified: the reportability
decision is a human judgment and auto-filing without this leg is refused.*

---

## 2. Honesty constraints — carried verbatim from the panel

These six constraints are reproduced as stated so the spore-authoring molecule cannot
soften them by paraphrase. They are the difference between a seal that survives first
contact with a regulator and one that discredits the whole thesis.

### 2.1 The seal proves structure and process — never truth, timeliness, or safety

Every entry above states what the property does **not** mean, and every one of those
"not"s reduces to a single sentence: **the seal proves the graph, not the world.** It
certifies that steps are present, ordered, unbypassable, disjoint, terminating, and
recorded. It certifies nothing about whether any output is true, whether any deadline
was met, or whether any proposed action is safe.

### 2.2 RoutingConfinement is the ENVELOPE form, not "N runs only on C"

> Do **not** make "N always runs on model C" a seal invariant — the fallback would then
> *be* a violation. The right formulation is the admissibility **envelope**: *every
> model class the plan may select for N lies within N's sensitivity-permitted set.* The
> same-provider guardrail-free model must be **pre-declared inside N's permitted
> envelope**; a fallback that stays in-envelope is *not* a seal violation, while a
> fallback that would leave the envelope must **abort, fail-closed** — and that abort is
> itself recorded. "N ran on C" is a runtime fact verified post-hoc from the trace,
> never a seal theorem.

Rationale, stated once so it is not lost: sealing the point instead of the envelope
turns the *legitimate, documented* guardrail-fallback into a self-inflicted seal
violation. The envelope form is the one move that reconciles "routing is the sale" with
"the guardrail-fallback must remain possible."

### 2.3 NoSilentClockMiss is ORDERING, not timeliness

> TLC proves *ordering* ("you cannot close the mission with a mandatory notice never
> drafted"), **not** *timeliness* ("within 4 hours"). The DAG model is untimed; TLC has
> no wall clock. The wall-clock deadline is carried as node metadata and published in
> the README, but the *enforcement* of it is an operational **watchdog** concern,
> explicitly **outside the seal**. Selling this property as "TLC guarantees the 4h
> deadline" is a misrepresentation.

### 2.4 Separation of duties is split — only the capability half is a TLC invariant

> The static "not the same node" half is a `cs spore validate` well-formedness check
> (no state exploration needed). Only the *capability* half — no reachable state grants
> one actor both evidence-write and production-write — earns a TLC invariant. Do not
> burn seal complexity on what the type system already refuses.

### 2.5 TraceCompleteness is promoted to a named property

> Promote trace-completeness to a named seal property: **"no node completes without
> emitting its step record."** It is cheaply checkable and it is precisely the
> chain-of-custody continuity the strategic frame is selling — turn it from incidental
> to certified. Continuity-of-process is **necessary, not sufficient** for
> admissibility; do not round it up to "the trace makes the evidence admissible."

### 2.6 Pin the fallback model; never certify a refusal *detector*

> Fallback events recorded in `realized` must pin a **resolvable model identity —
> id + version**, not a vague "guardrail-free variant." The admissibility
> *integrity-of-algorithm* prong needs the substitute algorithm *named and versioned*;
> a fuzzy label weakens it. And the seal must **never** certify a refusal *detector*:
> classifying arbitrary model output as "refusal vs substantive" is a fallible semantic
> judgment. Store the **raw verbatim refusal signal** as ground truth; any class label
> is explicitly **derived and fallible**, and an auditor may overrule it.

**Fallback-trace event schema** (recorded at the node where the fallback occurred; this
is a schema + README task, not a new subsystem — it lands in the existing `realized`
record of what actually ran vs what was planned):

| field | content |
|---|---|
| `node_id` | which node |
| `planned_model` | pinned id/version the recipe declared |
| `realized_model` | pinned id/version that actually answered, or `∅` if aborted |
| `transition` | `abort` \| `same_provider_guardrail_free_fallback` |
| `trigger.observed` | **verbatim refusal signal stored raw** (+ hash) |
| `trigger.label` | derived best-effort class — **marked derived/fallible** |
| `timestamp` | monotonic wall-clock |
| `actor` | `auto` (policy-triggered) \| `manual` (operator) |
| `authorization` | pointer to the documented directive that sanctions the fallback |
| `attempt_seq` | ordered chain: attempt-1 planned → refusal → attempt-2 fallback → result |
| `weights_hash` | self-hosted model: checkpoint/weights hash. Hosted frontier model: the flag **`hosted_unverifiable`** instead — weights not independently verifiable, version string provider-asserted |
| `quantization` | precision / quant of the realized model (`fp16`, `int4`, …) — a 4-bit quant of model X is a *different algorithm* from full-precision X |
| `decoding_params` | temperature, top-p / top-k, seed, max-tokens, penalties — at temperature > 0 the same prompt is not the same method twice |
| `prompt_context_hash` | hash of the realized prompt + full injected context (system + user + *the injected adversarial data*) — the prompt is part of the algorithm, and here it is partly attacker-authored |
| `reproducibility` | honest statement of whether exact reproduction is achievable, and if not why (temperature > 0; hosted/deprecated model; FP non-associativity; MoE routing; batch-dependent kernels) |

**The provenance subset is required at *every conclusion-producing node*, not only
at fallback events.** The five fields just added — `weights_hash` | `quantization` |
`decoding_params` | `prompt_context_hash` | `reproducibility` — together with the
pinned `realized_model` id+version form the **realized-model provenance record**.
Model-pinning (id+version) clears *identity* only; these fields are what the
admissibility *algorithm-integrity* prong additionally costs, and they must be
recorded at the pincers, the confrontation node, and each notice node — wherever a
node produces a conclusion — whether or not a fallback fired. `trigger.*`,
`transition`, and `attempt_seq` stay fallback-specific; the provenance subset is
universal across conclusion nodes.

> **The inversion, carried verbatim because it is counter-intuitive and
> load-bearing:** the **self-hosted guardrail-free fallback is *more*
> algorithm-verifiable than the hosted frontier model** — it is hashable,
> re-runnable, and pinnable at the weights level, while the hosted frontier model's
> version string is a provider-asserted label that drifts silently. The model most
> trusted for *alignment* is the least reproducible for *admissibility*; the
> guardrail-fallback the design treats as the risky path is the evidentially
> *cleaner* one.

**If `cs peek`'s `realized` record cannot carry these fields, that is a
cosmon-ward missing-primitive report — a typed molecule raised to the cosmon
project — never a bench workaround and never a silent omission.** The register
records the requirement; the runtime must grow the field or be told, as a typed
report, that it is missing.

*Source: the research-librarian / forensics seat Q6 + the algorithm-integrity checklist; legal
register §3.1.*

---

## 3. Out of the seal, by design

The following are **not** seal properties and must not be presented as if a green seal
covered them. Each is listed with where the responsibility actually sits.

- **Wall-clock timeliness.** Whether any regulatory deadline was met in real time. The
  model is untimed; this is an operational **watchdog** (a timer that fires and
  escalates), outside the seal. NoSilentClockMiss covers ordering only.

- **Correctness / safety of any output.** Whether a diagnosis is right, a reconstructed
  attack path is accurate, or a proposed remediation is safe. This is a non-trivial
  semantic property of an oracle's output — **Rice's theorem** territory: no graph
  property decides it, and in general it is **undecidable**. No seal certifies the
  correctness of a model's answer. This is the hard wall; it is handled by human review
  and defense-in-depth, and — for what cannot be prevented — made *auditable after the
  fact* by the trace.

- **Adversarial-but-well-typed content.** A prompt injection or poisoned artifact that
  is a *well-typed* instance of the expected type passes every typed edge and every gate
  that checks type, not meaning. **The type is not the meaning.** Faithful transport of
  malicious-but-well-typed data is not a graph violation. Defense requires content
  inspection — another fallible oracle — never structure.

- **Out-of-band channels.** A shared disk, a shared context store, a cache, or a real
  side effect on the target system — anything not modeled as a typed edge is invisible
  to the seal. Blindness proven on the edges says nothing about a shared filesystem.

- **Model ↔ runtime fidelity.** The meta-limit. TLC checks the TLA+ model, not the
  runtime. Every proof is vacuous if the runtime diverges from the modeled DAG.

- **The static half of separation of duties.** "No single node is declared both
  investigator and remediator" is a `cs spore validate` well-formedness check, not a
  reachability property — moved out of the seal deliberately (§2.4).

---

## 4. Recipient-facing block — "what the seal does NOT mean"

**This block is a required recipient-facing artifact.** Copy it, unchanged, into the
README of any spore that ships with this seal. It is turing's five clauses, verbatim.

> **What a green seal does NOT mean:**
>
> 1. It does **not** mean any output is true, correct, complete, or safe.
> 2. It does **not** mean any regulatory deadline was met — only that the deadline step
>    cannot be silently skipped.
> 3. It proves properties **of a model** of the DAG; it is vacuous if the runtime
>    diverges from that model.
> 4. It is blind to any channel that is not a declared typed edge (shared disk, shared
>    context, side effects on the target system).
> 5. Every gate it protects is proven *present and unbypassable*, never proven to
>    *judge correctly*.

### 4.1 Drop the `⊥` glyph

Do **not** use the `⊥` glyph (as in "investigation `⊥` remediation" or the blind
pincers) anywhere in recipient-facing documentation. `⊥` reads as *causal or
statistical independence* — a claim the seal cannot deliver: a remediation action
mutates the real system under investigation *out of band*, and two blind branches can
still share a poisoned input. What the seal actually proves is that **the branches do
not wire together in the DAG**. Say **"edge-disjointness between branches"** (or
"branch edge-disjointness"). The glyph over-claims exactly the independence §1 (P5) and
§3 say the seal does not buy.

---

## 5. Register status and downstream

| # | Property | TLC checkable? | Note |
|---|---|---|---|
| P1 | EvidenceBeforeRemediation | yes (precedence) | typed blocking edge + artifact-flow |
| P2 | ClassifyBeforeEscalate | yes (precedence) | makes routing mechanical |
| P3 | RoutingConfinement (envelope) | yes (static envelope over realized) | envelope form only — §2.2 |
| P4 | NoSilentClockMiss | yes (ordering) | ordering, **not** timeliness — §2.3 |
| P5 | BlindBeforeConfrontation | yes (reachability) | never auto-promote on convergence |
| P6 | TraceCompleteness | yes (invariant) | promoted; cheap; sellable — §2.5 |
| P7 | SoD-capability | yes (capability half) | static half → `cs spore validate` — §2.4 |
| P8 | NoOffensiveArtifact | yes (type reachability) | red line on irreversibility, not severity; sealed type-gate only — content discipline is unsealed (List B) |
| P9 | RatifiedClassificationBeforeNotice | yes (fail-closed precondition) | added by the legal round; `GateFailClosed`-family; attests classification + risk tier + awareness timestamp |

**Also a `cs spore validate` well-formedness expectation (not a seal property):** the
**`regime-route` DORA-over-NIS2 displacement** — the `applicable` regime set is
computed (DORA *lex specialis* displaces NIS2 for a financial entity; RGPD runs
parallel), and a mis-computed set is a malformed graph caught at validation (see P4's
well-formedness note).

**Dependency resolved.** The complementary legal / regulatory / evidentiary review
this register reserved a slot for **has landed** (consolidated in
`crisis-spore-legal-regulatory-register.md`). It **added P9**, extended the §2.6
`realized` record into the realized-model provenance record on every conclusion node,
recorded the `regime-route` displacement as a `validate` expectation, and split P8
into a sealed type-gate plus an unsealed content discipline (the latter in the threat
register's List B). This list may now be treated as consistent with the legal corpus;
the spore-authoring molecule reads all three registers together.

**Downstream.** The spore-authoring molecule consumes this register to write
`spore.tla` (the invariants above), `spore.cfg` (the model-check configuration), and
the recipient README (the §4 block, verbatim). This register is the source of truth for
*what each property forbids and what it must not be read to promise*; authoring is the
source of truth for *how it is expressed in TLA+*.

# Crisis-Cyber Spore — Legal / Regulatory / Evidentiary Register (DESIGN)

**Status:** design only. This is a *register*, not code and not a seal. It ships
no `spore.toml`, no `spore.tla`, no `spore.cfg`, and no README. It is the third
sibling in the crisis-cyber design corpus, alongside the *seal-property register*
(`crisis-spore-seal-property-register.md`) and the *threat register*
(`crisis-spore-threat-register.md`). A later spore-authoring molecule reads all
three *before* it wires the DAG or writes the TLA⁺ model; this document is the
blueprint for the legal, regulatory, and evidentiary constraints that authoring
must land as typed edges, declared perimeters, human-ratification legs, or
honestly-labelled conventions.

**Scope.** The future *crisis-cyber* spore is a shareable cosmon mission that,
given a live security incident, **reconstructs** what happened, **records** an
auditable chain of custody, and **proposes** remediation for a human to approve —
it never acts on production by itself. This register answers the legal questions
the topology only *bounded*: when does an incident become declarable, what a
notice may and may not carry, what makes the analytic record admissible (and
what it never can), whether the live-phase custody escrow survives an
evidentiary challenge, what the tool's author must refuse, and how to keep a
human countersign from decaying into a rubber stamp. It does **not** re-open the
topology or the product perimeter.

**Who this is for.** A recipient who has none of our agents, none of our tooling,
and none of the deliberation this came out of. Everything needed to read it is
below. The instruments are cited by reference as public facts; article numbers
are named where the seat was confident of them and left at instrument-family
level where the binding detail lives in a delegated or implementing act whose
exact numbering must not be fabricated.

**Confidentiality.** Written for the public repository. No partner name, no
nominative citation, no commercial, fundraise, beachhead, or demo detail. Public
facts named and citable here: DORA (Reg. (EU) 2022/2554), NIS2 (Dir. (EU)
2022/2555), RGPD/GDPR (Reg. (EU) 2016/679), the EU AI Act (Reg. (EU) 2024/1689),
Directive 2013/40/EU on attacks against information systems, dual-use export
control (Reg. (EU) 2021/821), NIST SP 800-61r3 and SP 800-86, OASIS CACAO v2.0,
STIX 2.1, ANSSI, the Traffic Light Protocol (TLP), RFC 3161 trusted timestamps,
and the Daubert / Frye admissibility standards.

---

## 0. Vocabulary and the two facts that govern the whole register

A reader with none of our tooling should be able to follow every row. The terms
below are exactly those the sections use, and nothing more exotic.

- **spore** — a template of a whole mission: which worker nodes exist, what each
  reads and produces, how they are ordered, and an optional *seal*. Plain
  configuration data, not a program.
- **node** — one worker step (e.g. `evidence-capture`). Each node has a
  **declared input perimeter**: the exact named artifacts it may read. It cannot
  read what is not in its perimeter — this is checked, not trusted.
- **sink** — a terminal node that emits a regulatory notice. The clock-tree forks
  four of them: a DORA sink, a NIS2 sink, an RGPD art. 33 sink (supervisory
  authority), and an RGPD art. 34 sink (data subjects).
- **seal** — a TLA⁺ model (checked by the TLC model-checker) that mechanically
  verifies named safety properties of the *expanded* DAG before it may run. A
  seal property is stated as a **forbidden reachable state** — a state the graph
  can never enter, proven by exhausting the model. The seal properties named here
  (P1–P8) are specified in the seal-property register.
- **`cs spore validate`** — a static well-formedness check that rejects graphs
  malformed by construction (a dangling edge, a node reading an artifact no one
  produces) *without* exploring the state space.
- **`realized` binding** — which concrete model *actually* ran a node, recorded
  after the fact (the planned model may differ from the realized one when a
  guardrail fallback fires).
- **awareness moment** — the legal instant at which a regulatory clock starts
  running (RGPD "became aware"; DORA/NIS2 "awareness"). Fixing it is a
  legal-factual determination with sanction-grade consequences.
- **LD1, LD2** — the two live divergences this round preserved for the operator
  (§4 escrow, §5 red line). They are **pending operator ratification** and are
  recorded here as *both verdicts, un-averaged* — never baked into a single call.

### 0.1 The first governing fact — the seal certifies *process*, never *admissibility*

The seal-property register prints one fact in bold and every recipient-facing
document must repeat it: **TLC checks the model, not the system.** It certifies
that steps are present, ordered, unbypassable, disjoint, terminating, and
recorded. It certifies **nothing** about whether any output is true, whether any
deadline was met in real time, or whether any proposed action is safe.

This register hardens that boundary into a rule the whole legal axis obeys, taken
verbatim from the falsifiability seat:

> **Certify *process* (falsifiable — keep); never certify *soundness*
> (unfalsifiable — strike).**

A claim survives in a legal artifact if and only if its falsifier is *an
observation about the process record* — a gap in the trace, a broken hash link, a
fuzzy model id — available at inspection time. A claim whose only falsifier is
*ground truth about the incident* (which is contested, partly attacker-authored,
and in general Rice-undecidable) is a comfort-claim: necessary to *want*,
impossible to *certify*. Two sentences must therefore be **deleted from every
artifact that carries the seal's authority**:

- ✗ *"The evidence is sound."* — Say instead: *"the process by which the evidence
  was produced is complete, continuous, and integrity-protected."*
- ✗ *"The seal certifies the evidence is admissible."* — "Admissible" is a legal
  conclusion the seal cannot reach; asserting it is the single overclaim that
  discredits the whole thesis on first contact with a regulator or a court.

*Source: the falsifiability seat Q5; the research-librarian / forensics seat D1–D3; reinforced from
four seats in `synthesis.md` LC1.*

### 0.2 The second governing fact — F1 vs F2, evidence-in-hand vs fact-in-world

One image runs through every declarability threshold in §1, and it is worth
fixing before the tables. There are two different facts that look identical under
a stopwatch:

- **F1 — evidence-in-hand.** *"The telemetry currently shows N client sessions
  dropped."* Its falsifier — recount the telemetry — is available **now**. The
  graph can compute it.
- **F2 — fact-in-world.** *"N clients were actually affected."* Its falsifier —
  the true final count from completed forensics — arrives **days later, after the
  deadline**. The graph can never check it at decision time.

**Every regulatory materiality threshold is written about F2. The graph only ever
holds F1.** The gap between them is exactly where a false determination lives, and
it is the gap the live adversary authors (a self-downgrading injected log line
moves F1 without moving F2). So the honest object the graph may emit is never
"this is / is not reportable," but "the evidence in hand crosses / does not cross
this numeric line, provisional pending forensics." The *reportability verdict* is
a human judgment on an evidence base the graph knows is still moving.

*Source: the falsifiability seat §0.*

---

## 1. Declarability, per regime

This section answers: **when does an incident become declarable, and how much of
that decision may the graph make?** The structural finding comes first, because
it changes the shape of the routing node before any threshold is discussed.

### 1.1 `regime-route` is not a three-way fan-out — the DORA-over-NIS2 displacement

The opening topology drew three parallel sinks (DORA / NIS2 / RGPD) as if
co-equal. For a financial entity they are not:

> **DORA is *lex specialis* and displaces NIS2's incident-reporting obligations
> for the financial entity.** NIS2 (Art. 4) yields where a sector-specific Union
> act imposes at least equivalent incident-notification duties; DORA (Art. 2) is
> exactly that act for entities in its scope. So for an EU financial institution
> the live sinks are **DORA (ICT-incident reporting) + RGPD (personal-data
> breach), in parallel**, and **NIS2 is normally *not* separately triggered for
> the same incident.** NIS2 returns to the foreground only for a recipient
> *outside* DORA scope.

`regime-route` therefore does three things, in order — it does **not** fan out to
three co-equal sinks:

1. **Resolve entity scope.** Is the entity within DORA Art. 2 scope? Within NIS2
   Annex I/II sector + size thresholds? Does it process personal data? These are
   determinable from typed entity evidence (registration, sector, size class).
2. **Apply the displacement rule.** For an in-DORA-scope entity, suppress the
   NIS2 incident-reporting branch (DORA displaces it).
3. **Keep RGPD parallel.** The personal-data-breach obligation runs alongside,
   regardless of the ICT-incident regime.

This is a deterministic legal rule, encodable as a `cs spore validate`
well-formedness expectation. *Source: the contract-jurist seat governing
finding + Q2.*

### 1.2 The substantive trigger criteria, per regime

**DORA — reporting of *major* ICT-related incidents (Art. 19; classification
Art. 18, detailed by the 2024 delegated RTS family).** An incident is *major*
when the materiality thresholds are met across a mix of criteria: clients /
financial counterparts / transactions affected; reputational impact; duration /
service downtime; geographical spread; data losses (availability, authenticity,
integrity, confidentiality); criticality of the affected services; economic
impact. Timeline — note it is **not** a single "4 h" clock: initial notification
as early as possible, target **≤ 4 h from the moment of classification as
major**, and in any event **≤ 24 h from becoming aware**; intermediate report
within **72 h**; final report within **one month**. Significant cyber *threats*
are reportable **voluntarily** (Art. 19(2)) — the spore should treat threat
notification as opt-in, never auto.

**NIS2 — *significant* incident (Art. 23; sectoral quantitative thresholds in
Impl. Reg. (EU) 2024/2690), in scope only where DORA does not displace.** An
incident is significant if it has caused or is *capable of causing* severe
operational disruption / financial loss, **or** has affected or is *capable of
affecting* other persons with considerable material or non-material damage.
Timeline: early warning **≤ 24 h** (from awareness); incident notification
**≤ 72 h**; final report **≤ 1 month**.

**RGPD — two *distinct* triggers, never conflate them.**
- **Art. 33 (supervisory authority, e.g. CNIL).** Precondition (fact): a
  personal-data breach occurred (Art. 4(12)). Trigger (judgment): the breach is
  *likely to result in a risk* to rights and freedoms; if *unlikely*, no
  notification is due but the breach is still documented internally (Art. 33(5)).
  Deadline: without undue delay, where feasible **≤ 72 h after becoming aware**.
- **Art. 34 (data subjects — the hostile-readable channel).** Trigger (higher
  bar, judgment): the breach is likely to result in a *high* risk. Deadline:
  without undue delay (no fixed hour count). Exemptions (Art. 34(3)):
  (a) the affected data was rendered **unintelligible** (strong encryption /
  tokenisation); (b) subsequent measures make the high risk no longer likely;
  (c) disproportionate effort (a public communication substitutes).

*Source: the contract-jurist seat Q1.*

### 1.3 The fact-vs-judgment table — what the graph may pre-fill, and where it must stop

Combining the jurist's node-by-node line with the falsifiability seat's
per-threshold test, the graph's competence splits cleanly. **The graph may
compute scope, pre-fill the criteria, and run the deterministic arithmetic; it
must stop at every potentiality / risk / criticality qualifier and at the fixing
of the legal awareness moment.**

| Threshold / criterion | Graph may compute (F1 fact) | Graph must STOP (F2 judgment / qualifier) | Falsifier available before the deadline? |
|---|---|---|---|
| **Entity scope + displacement** (regime-route) | Scope resolution from typed entity evidence + the DORA-over-NIS2 rule | Genuine edge cases (group vs subsidiary scope; the size-cap borderline) — flag for human confirmation | Yes (deterministic) |
| **DORA: clients / counterparts affected** | The F1 tally per current telemetry, against the numeric line | The true post-forensic affected-client count (F2 — almost always *rises*) | No — lands after forensics |
| **DORA: transactions affected** | The ledger figure **iff the ledger is authoritative and outside the blast radius** | The same count when the ledger was itself within the compromise | Conditionally — only if the counting source is out of the blast radius |
| **DORA: duration / downtime** | A floor: "≥ X so far" | The final duration (unknowable while the incident is live) — never "= X" during the live phase | No |
| **DORA: geographical spread** | Escalate when spread is *already* observed across the line | Additional jurisdictions that surface later | Trip-only (never clear) |
| **DORA: data losses (exfil / alteration)** | — | The reconstruction's own output; its *truth* is Rice-undecidable and attacker-plantable | No — this is the mission's output, not its input |
| **DORA: criticality of services** | A lookup **iff** the criticality mapping is pre-declared as versioned config | A live "is this critical?" judgment where no register exists | Before, iff pre-declared |
| **DORA: economic + reputational impact** | — | Pure appraisal; reputational impact has no in-window falsifier at all | No (structurally) |
| **NIS2: "severe" / "considerable" / "capable of causing"** | Surface the indicators (blast radius, criticality, cross-border reach) | Every elastic term and every counterfactual "capable of causing" limb | No — the counterfactual limb is unfalsifiable by grammar |
| **NIS2: sectoral quantitative thresholds** | The counter **iff** authoritative and outside the blast radius | The same counter when degraded by the incident | Before, under the outside-the-blast-radius condition |
| **RGPD art. 33: "did a breach occur"** | Auto-flag a candidate breach on a signature (an access log, an exfil signature) | Whether personal data was *in fact* reached (partly the investigation's F2 output) | Trip-computable, not clear-computable |
| **RGPD art. 33: "risk to rights and freedoms"** | "No exemption argument is available from the evidence in hand" (a safe over-notify bias) | The risk determination itself (forward-looking, probabilistic) | No |
| **RGPD art. 34: "likely HIGH risk"** | Factual inputs to the exemptions — e.g. "the affected store was encrypted with keys off-estate" (an F1 fact the escrow decision actually produces) | The conclusion "high risk" (doubly elastic: "likely" × "high") | No |
| **RGPD art. 34(3)(a): unintelligibility** | The encryption / tokenisation pre-check — largely computable; can *pre-empt* the data-subject channel | — | Yes |
| **The awareness moment (all regimes)** | Candidate timestamps: first signal, triage, confirmation | **Fixing the legal awareness moment** that starts each clock — the sharpest hand-off | No — machine-detected first-signal must never silently become the anchor |

Two pre-declarable objects are the *only* criteria the graph can move from
judgment to fact **before** the incident: (a) a **versioned criticality
register** (which services are "critical," fixed as typed config), and (b) crisp
numeric floors read from an **authoritative source situated outside the blast
radius**. Both must carry their precondition explicitly — *"counting source is
out-of-blast-radius"* — or the fact silently becomes F2.

*Source: the contract-jurist seat Q2; the falsifiability seat Q2, Q1.*

### 1.4 The asymmetric automation rule (load-bearing)

The graph's automation must be **asymmetric**, and this is the transposition of
the design's own doctrine (*a red line keyed on an attacker-controllable field is
decorative*) onto the reporting axis:

> **Trip *toward* notification; never innocent *away* from it.** A floor is a
> *lower bound*: the evidence in hand can only ever push the count *up*, never
> confirm it will not rise. A tripped floor may therefore legitimately carry an
> incident *across* a threshold (auto-escalate toward filing); an untripped floor
> may **never** clear one (never auto-suppress a notice). Where a regime's own
> default is to notify (RGPD art. 33: the exemption fires only when risk is
> "unlikely"), the graph's safe posture is to **compute toward notification and
> hand the exemption — the only route to *not* notifying — to a qualified human.**

Elastic self-classifications ("just under significant," "just under high risk")
are gameable under the stopwatch for the same reason a severity-keyed autonomy
gate is: there is no observation that refutes the "just-under" claim before the
deadline. The reportability trip must key on crisp floors and default-to-notify,
never on an elastic self-assessment that can be argued downward.

**Hand-off to the seal/DAG (finding, not design).** The determination node emits
**exactly one artifact type** — a *candidate determination* with criteria and
EDPB severity factors pre-filled and the awareness moment left as a **required
human input** — and a **fail-closed human-ratification leg** sits between that
candidate and any notice-draft node. The countersign there attests to three named
facts — **the classification, the risk tier, and the awareness timestamp** — not
a global "approve." This is the legal specialization of the threat register's B6
fact-attesting countersign, and it aligns with the seal's `NoSilentClockMiss`
(ordering) without asking the seal to reason about timeliness. The clock-start
timestamp is *itself* a provenance artifact: *who* classified, *when*, *on what
basis* (§3, B-section).

*Source: the falsifiability seat Q1 + one-line summary; the contract-jurist seat
Q2 boundary statement; the research-librarian / forensics seat Q1 clock-start flag.*

---

## 2. Content boundaries, per sink

This section answers: **what must each notice carry, and what must it never
carry?** Forbidden content is given equal weight to mandatory content — the
"nothing more" is the whole point. Two categories of forbidden content run
throughout: **(a)** attacker-exploitable material that must not reach a channel
the attacker or the public can read, and **(b)** premature admissions of
liability that harm the client.

### 2.1 The decisive refinement — channels are trust-graded, not uniformly redacted

The opening topology stated "exclude the reconstruction from the RGPD/public
node," which is correct but must **not** be over-generalised into "strip the
reconstruction from every sink." The sinks are **channel-trust-graded**:

- **NIS2 / CSIRT channel — the trusted defensive channel.** It *legitimately
  consumes* IOCs and TTPs. This is exactly where the **CACAO v2.0 / STIX 2.1**
  pivot artifact belongs. Stripping IOCs here would defeat the point of the
  channel.
- **RGPD art. 34 channel — the public / attacker-readable channel.** It is
  forwarded, screenshotted, and read by the still-present attacker. It must
  exclude **both** the reconstruction **and** every liability admission. Treat
  every word as public.
- **DORA + RGPD art. 33 channels — confidential but adversarial in effect.** They
  receive **redacted facts**: the authority is trusted, but its file is
  discoverable and can found a sanction.

**Concrete flow-control statement (finding, not TLA⁺).** The reconstruction
artifact type may have a plan-edge to the NIS2/CSIRT sink and **must have no
plan-edge to the RGPD art. 34 sink**; the DORA and RGPD art. 33 sinks receive a
**redacted-facts** artifact type, never the full reconstruction. This is an
ArtifactFlow / per-sink-perimeter statement, checkable at `cs spore validate`.

*Source: the contract-jurist seat Q4 + cross-sink flow control.*

### 2.2 Mandatory content, per sink

- **DORA (competent authority).** *Initial:* entity identification + contact;
  detection and occurrence timestamps; classification criteria triggered and why
  major; concise description; whether malicious/suspected; ICT services / critical
  functions affected; business-continuity activation; whether cross-border.
  *Intermediate:* status update; refined impact; affected functional areas; IOCs
  where available; interim mitigation. *Final:* root-cause analysis; full
  remediation; gross costs and losses; permanent fixes.
- **NIS2 (CSIRT / competent authority).** *Early warning (24 h):* whether
  malicious cause is *suspected*; whether cross-border. *Notification (72 h):*
  initial assessment — severity and impact; IOCs where available. *Final
  (1 month):* detailed description; threat type / root cause; mitigation applied
  and ongoing; cross-border impact.
- **RGPD art. 33 (supervisory authority).** Art. 33(3) minimum: nature of the
  breach incl. **categories and approximate number** of data subjects and
  records; DPO / contact point; likely consequences; measures taken or proposed.
  Phased notification is permitted (Art. 33(4)).
- **RGPD art. 34 (data subjects).** Art. 34(2) minimum, in **clear and plain
  language**: nature of the breach; DPO contact; likely consequences; measures
  taken or proposed incl. mitigation advice to the individual. **Nothing more is
  required** — and the "nothing more" is enforced by §2.3.

*Source: the contract-jurist seat Q3.*

### 2.3 Forbidden and dangerous content — split (a) attacker-exploitable / (b) liability admission

- **RGPD art. 34 (data subjects) — the maximum-restriction channel.**
  - **(a) Forbid — attacker-exploitable / public-readable:** the red-agent attack
    reconstruction, TTPs, kill-chain narrative, exploited-vulnerability specifics,
    IOCs, C2 detail; **any statement of what you can or cannot see** (the
    fallback-reason counter-intelligence — on this channel it is handed straight
    to the adversary); other data subjects' personal data; internal topology.
  - **(b) Forbid — liability admissions:** any concession of a compliance failure
    ("data was unencrypted," "we had not patched a known flaw"), any attribution
    of fault, any speculative causation. State nature, consequences, mitigation —
    and stop. Over-disclosure here seeds both civil claims (art. 82) and
    enforcement (art. 83).
  - **Do not forget the exemption:** if art. 34(3)(a) applies (data
    unintelligible), this channel may not fire at all — pre-check it (§1.3),
    do not draft-then-suppress.
- **RGPD art. 33 (supervisory authority).**
  - **(a) Forbid / minimise:** full offensive reconstruction and exploit code (not
    required, gratuitous); unredacted third-party personal data beyond the
    categories / approximate numbers the article asks for.
  - **(b) Forbid premature admissions:** the notice is the single most common
    source of self-incrimination under art. 83. Do not volunteer conclusions of
    non-compliance, do not guess root cause under the 72 h clock, do not
    characterise your own posture as inadequate. Report **facts**; let *legal
    characterisation* be made under counsel, not by the spore. Phased notification
    exists precisely so you need not over-commit early.
- **DORA (competent authority).**
  - **(a) Forbid / minimise:** offensive-playbook / exploit detail (not required).
    IOCs are appropriate in the intermediate/final reports where the ITS calls for
    them — this channel tolerates more than art. 34, less than a CSIRT exchange.
  - **(b) Forbid premature admissions:** in the **initial** notification, no
    speculative root cause and no concession of governance / resilience-framework
    non-compliance — root cause belongs in the *final* report. An initial notice
    filed under the clock that mis-states scope or guesses cause is a one-way door.
- **NIS2 (CSIRT) — the trusted defensive channel.**
  - **(a) Narrower forbid-list by design:** the CSIRT *wants* IOCs and the CACAO /
    STIX playbook is appropriate here. Forbidden nonetheless: any offensive-playbook
    / attack-procedure artifact (the `NoOffensiveArtifact` red line holds on every
    channel), and **unverified attribution to a named threat actor or person**
    (defamatory, prejudicial, and re-disseminable by the authority). Scrub anything
    that could reach public dissemination.
  - **(b) Forbid premature admissions:** the early warning asks only whether
    malicious cause is *suspected* — keep it to "suspected," concede no fault, fix
    no root cause you have not established.

*Source: the contract-jurist seat Q4.*

### 2.4 The seven notice damage-items (hostile-chair ranking)

An LLM under a deadline produces exactly the fluent, confident, causal,
precise-sounding prose that is most damaging. Ranked by how badly each wounds the
client if it lands in a filing. **None of the seven is a seal property; all live
in human review.**

1. **Cause / fault / root-cause stated before the investigation closes.** A party
   admission — reusable in sanction, civil suits, and insurance-coverage denial.
   The #1 damage item, and the spore is the machine most likely to write a fluent
   causal narrative. Law does not require a cause at 4 h.
2. **A precise-but-unverified scope number.** Over-stating triggers mass
   notification and market harm; under-stating that later expands exposes a
   *second, graver* charge — misleading the authority. The trap is *false
   precision*; constrain to hedged ranges, "preliminary and subject to revision."
3. **Attacker-useful detail in an attacker-readable channel.** IOCs, detection
   gaps, forensic timeline, or the fallback-reason counter-intelligence leaking
   into the art. 34 communication or the press.
4. **Speculation stated as fact.** "The attacker likely exfiltrated…" becomes a
   conceded admission of *known* exfiltration later. Separate confirmed /
   suspected / not-excluded explicitly.
5. **Legal characterisations the client is not obliged to volunteer.**
   Auto-labelling the event a "personal data breach" or a "major incident" is a
   legal conclusion with cascading obligations — flag it, do not assert it.
6. **Inconsistency between the client's own parallel notices.** The fork-early
   clock-tree that protects the clock also *creates* the risk that separate LLM
   runs state different scopes or timelines. A **cross-notice consistency check
   before filing is mandatory** — the topology that saves the clock manufactures
   this exposure.
7. **Naming a third party or attributing to a named actor.** Invites defamation
   exposure, prejudices supply-chain litigation, is almost always premature and
   unprovable at notice time.

*Source: the adversarial-judge seat Q4.*

### 2.5 The reconstruction-vs-characterisation seam, and the unintelligibility pre-check

Two structural refinements the notice-draft nodes depend on:

- **A new artifact-type seam: *factual reconstruction* vs *legal
  characterisation*.** The spore types its outputs into these two classes and
  keeps the latter *out of scope* (it is counsel's, and privilege over incident
  forensics is fragile — an over-conclusory artifact is a "defendant's diary").
  **The notice-draft nodes consume the *factual* type only.** This is the content
  couture that keeps a reconstruction (which may contain attacker-useful or
  liability-laden detail) from being wired into a notice.
- **The art. 34(3)(a) unintelligibility pre-check.** A computable gate that can
  *pre-empt* the data-subject channel entirely: if the affected data was rendered
  unintelligible (strong encryption / tokenisation), the art. 34 communication may
  not be required at all. The escrow's off-estate encryption produces exactly such
  an unintelligibility fact — an F1 input the art. 34 node may legitimately *read*
  without *deciding* the exemption.

**A subpoena bypasses the internal perimeter.** The per-sink perimeter walls
artifact *type*, not *content*; a regulator or litigant with subpoena power over
the *full* file is not bounded by the spore's internal perimeter. The perimeter is
a real control against accidental cross-contamination — it is not a control
against compelled production.

*Source: the contract-jurist seat Q4 hand-offs; the adversarial-judge seat
Q4 item 3.*

---

## 3. The operational admissibility checklist

This section answers: **what makes the analytic record admissible, and what can
it never establish?** It reproduces the forensic seat's structure. Run it against
a produced evidence bundle **before** it leaves for a recipient, a regulator, or
a tribunal.

**The one sentence that governs the section.** The seal (`TraceCompleteness`)
certifies that the system *faithfully recorded what it did from intake onward*. It
says nothing about where the inputs came from *before* intake, nor about whether
the method that produced each conclusion is *identified, configured, and
re-runnable*. Those are the two orphan prongs — **data-provenance** and
**algorithm-integrity** — and the trace is structurally blind to both, because it
begins at intake and records *behaviour*, not *origin* or *method-reliability*.
"Necessary" must not be rounded to "sufficient."

**Grading.** `FATAL` = the conclusion is excluded / the bundle's central claim
collapses. `WEIGHT` = admissible but impeachable; an adversarial examiner reduces
its evidentiary weight. `DISCLOSURE` = curable defect; failing it is an overclaim,
not a fabrication, but an undisclosed overclaim is what discredits the whole
bundle on first contact. The burden of provenance scales with the weight of the
claim: an item underwriting an irreversible action or a regulator filing clears a
higher bar than an incidental footnote.

### Section A — Integrity & continuity (verify the seal's promise was actually kept)

- **A1 — The seal actually ran, green, over *this* DAG.** The bundle contains the
  TLC verdict artifact for the *exact* expanded DAG that executed, with
  `TraceCompleteness` + `EvidenceBeforeRemediation` among the checked invariants.
  *Fail cost:* `WEIGHT→FATAL` — no seal artifact, or a seal over a different DAG
  version, drops the "certified chain of custody" claim to an ordinary log.
- **A2 — Hash-chain unbroken end-to-end.** Recompute the append-only hash chain
  over every step record; no gap, no rewrite. *Fail cost:* `FATAL` — any break
  means tampering cannot be excluded.
- **A3 — Model↔runtime fidelity attested.** Evidence that the runtime that
  executed is the one the seal modeled (cosmon version pinned; no undocumented
  out-of-model manual steps). *Fail cost:* `WEIGHT` (severe) — the seal proves a
  model, not this run.

### Section B — Data-provenance (origin & integrity of every input, upstream of intake)

- **B1 — Per-input origin record.** Every artifact the pincers consumed carries:
  source system, collection instrument + version, collecting actor, collection
  timestamp, legal basis / authority. *Fail cost:* `FATAL` for the conclusions
  resting on the unprovenanced input (severable).
- **B2 — Integrity fixed *at capture*, not at intake.** Each input carries a hash
  computed *at or near the moment of collection by the collecting instrument*, and
  the preservation-gate *verified that capture-hash equal on ingest*. This closes
  **the capture→intake gap the seal cannot see**: `TraceCompleteness` hashes at
  the gate, which is *inside* the spore and *after* intake; anything that happened
  to the artifact between real-world capture and intake is an unsealed segment of
  custody. A hash first computed at intake fixes a *state*, not a *chain*. *Fail
  cost:* `WEIGHT→FATAL` for contested artifacts.
- **B3 — Source trust under a live adversary.** Each input labelled
  **attacker-writable** vs **attacker-non-writable** (an out-of-band source the
  adversary did not control — raw disk image, out-of-band log, capture from a
  device the attacker does not own). No irreversible-action or regulator-notice
  conclusion rests *solely* on attacker-writable sources. *Fail cost:* `WEIGHT`
  (severe) — a load-bearing conclusion on attacker-writable-only evidence is
  impeachable as adversary-planted; convergence is the *most forgeable* signal.
- **B4 — Attacker-authored inputs marked untrusted-origin.** Bytes authored by the
  adversary are tagged so the record distinguishes *"evidence of the attacker's
  action"* from *"a trusted factual source."* *Fail cost:* `WEIGHT` (severe) —
  treating attacker prose as a neutral source carries *false authority*, the worst
  failure because it looks like success.
- **B5 — Handoff chain attested, *including the escrow transitions*.** Every
  custody transfer — sensor → tool → workstation → intake → live-phase escrow →
  restored-to-client at closure — is a hashed, timestamped, authorized event with
  equal hash before/after. *Fail cost:* `FATAL` if an escrow transition is
  undocumented — **the escrow, if unattested, *manufactures* the very
  discontinuity it was meant to prevent** (see §4).
- **B6 — Custody-phase transition traced, not configured.** The live→closed phase
  change (and the key-custody change) is a first-class traced event, not a silent
  setting. *Fail cost:* `WEIGHT` — a silent phase change reads as tampering; a
  *declared* escrow strengthens the record, a *discovered* one destroys it.

### Section C — Algorithm-integrity (identity, configuration, reproducibility of the method)

- **C1 — Every *conclusion-producing* node's realized model pinned (id + version)
  — not only fallback nodes.** The pincers, the confrontation node, and each
  notice node record realized model id+version, whether or not a fallback fired.
  *Fail cost:* `WEIGHT→FATAL` — an unpinned conclusion-node has an unidentified
  method; the Daubert/Frye reliability-of-method prong fails for that conclusion.
- **C2 — Weights/artifact hash OR explicit non-verifiability disclosure.**
  Self-hosted models carry a checkpoint/weights hash; hosted frontier models carry
  an explicit statement that weights are *not independently verifiable* and the
  version string is provider-asserted. *Fail cost:* `DISCLOSURE→WEIGHT`.
- **C3 — Decoding parameters + seed recorded.** Temperature, top-p/top-k, seed,
  max-tokens, penalties, per conclusion-node. At temperature > 0 the same prompt
  yields different outputs, so two runs are *not the same method*. *Fail cost:*
  `WEIGHT`.
- **C4 — Quantization / precision recorded (esp. the self-hosted fallback).** A
  4-bit quant of model X is a *different algorithm* from full-precision X. *Fail
  cost:* `WEIGHT`.
- **C5 — Realized prompt + full input context retained (hashed/versioned).** The
  actual prompt — system + user + *injected context, including the adversarial
  data* — retained or hashed per conclusion-node. **The prompt is part of the
  algorithm**, and here it is *partly attacker-authored*. *Fail cost:*
  `WEIGHT→FATAL` — without the realized context the method is not reconstructable.
- **C6 — Non-determinism disclosure.** The bundle states honestly whether exact
  reproduction is achievable and, if not, why (temperature > 0; hosted/deprecated
  model; floating-point non-associativity; MoE routing; batch-dependent kernels).
  *Fail cost:* `DISCLOSURE`.
- **C7 — Documented re-run procedure, or an honest statement it is unavailable.**
  *Fail cost:* `DISCLOSURE→WEIGHT`.
- **C8 — Fallback substitutes carry full C1–C5 provenance; sensitive nodes prove
  they never fell.** Every substitution is a recorded event *and* the substitute
  carries hash + params + quant + realized context, *and* `RoutingConfinement`
  proves the notice / containment-authorization nodes never fell to the
  guardrail-free model. *Fail cost:* `WEIGHT→FATAL` at the point of maximum
  consequence.

### Section D — Disclosure honesty (what the bundle must state it does NOT establish)

- **D1 — The "what the seal does NOT mean" block present, verbatim** (the seal
  register's five clauses). *Fail cost:* `DISCLOSURE` — absence is the overclaim
  that discredits on first regulator contact.
- **D2 — Explicit statement that trace-completeness ≠ correctness**, and that
  data-provenance + algorithm-integrity are *separately* evidenced (Sections B & C).
  *Fail cost:* `DISCLOSURE`.
- **D3 — Content-truth disclaimer (Rice).** No output's substantive correctness is
  certified; conclusions are analyst work-product subject to human review. *Fail
  cost:* `DISCLOSURE`.
- **D4 — Non-LLM corroboration cited for every irreversible action / regulator
  filing.** At least one *attacker-non-writable* independent source underwrites
  any consequential conclusion. *Fail cost:* `FATAL` for the irreversible action —
  a consensus-only basis is impeachable as forgeable convergence.

**How to score a bundle.** Any unresolved `FATAL` on a load-bearing conclusion →
that conclusion is not citable as evidence (report it as *unverified*, never
"likely correct"). `WEIGHT` items accumulate: three or four is a bundle an
opposing examiner takes apart. `DISCLOSURE` items are cheap to fix and expensive
to omit.

### 3.1 Model-pinning is necessary, not sufficient — and the surprising inversion

Pinning id+version (the seal's floor) clears **identity** only; it does not clear
**reliability-of-method** or **reproducibility**, which is what the
algorithm-integrity prong is *for*. C1 is item one of eight; C2–C8 are what
"sufficient" additionally costs. Extend the `realized` record beyond id+version —
`weights_hash | quantization | decoding_params | prompt_context_hash |
reproducibility` — and apply it to **every conclusion-producing node**, not only
fallback events. (If the runtime's `realized` record cannot carry these fields,
that is a **cosmon-ward missing-primitive report**, not a bench workaround.)

The inversion, carried forward verbatim because it is counter-intuitive and
load-bearing:

> **The self-hosted guardrail-free fallback is *more* algorithm-verifiable than
> the hosted frontier model.** It is hashable and re-runnable and pinnable at the
> weights level, while the hosted frontier model's version string is a
> provider-asserted label that drifts silently. **The model most trusted for
> alignment is the least reproducible for admissibility.** The guardrail-fallback
> the design treats as the risky path is the evidentially *cleaner* one.

And Popper's rule, applied here: **certify the *process* (falsifiable — keep),
strike the *soundness* (infalsifiable — remove)** — delete "the evidence is sound"
and "the seal certifies admissibility" everywhere they appear (§0.1).

*Source: the research-librarian / forensics seat headline checklist + Q5, Q6; the falsifiability seat
Q5.*

---

## 4. The verdict on custody continuity of the live-phase escrow

This section answers the exact question the product decision legated to a
legally-seated review: **does the live-phase out-of-band escrow *preserve* or
*break* chain-of-custody continuity in an evidentiary sense?** The round produced
**two verdicts. They are recorded here un-averaged.** This is **LD1 — pending
operator ratification.**

### 4.1 Verdict A (contract-jurist seat): PRESERVES, if documented and integrity-spanned

Custody continuity in evidentiary terms is not "the data never moved"; it is
"every custodian and every transfer is documented, integrity-protected, and
reconstructable." A move to escrow is a *transfer of custody*, and transfers are
native to any chain of custody. An escrow *preserves* continuity **provided three
conditions hold**:

1. **The live→closed transition is a traced, hash-chained event** — no unaccounted
   gap.
2. **Integrity across the transfer is provable** — the escrowed artifact is
   hash-chained end-to-end, keys held off the compromised estate, and restoration
   at closure verifies the chain. Encryption-at-rest with off-estate keys
   *strengthens* the confidentiality prong and does not weaken integrity **if the
   hash chain spans the escrow**.
3. **The escrow custodian and access are documented** — who held the keys, who
   could decrypt, when.

If those hold, escrow is the *stronger* posture: it protects the evidence against
the very adversary who, on a compromised estate, could tamper with an un-escrowed
trace. An un-escrowed trace on attacker-owned infrastructure is the *weaker*
admissibility position. **Verdict: preserves, if documented and
integrity-spanned.** *Source: the contract-jurist seat "Verdict on Decision
B's legal validity."*

### 4.2 Verdict B (hostile-judge seat): BREAKS as currently designed

The decision to escrow is not the defect; the defect is that the escrow is
specified **only in the vocabulary of confidentiality** ("encryption-at-rest,
keys off the estate") and **never in the vocabulary of evidentiary integrity and
continuity**. From the hostile chair, five break-points:

1. **Sole custody by an interested party in the unobserved live window.** The live
   phase is precisely the disputed period and the window in which the evidence is
   most malleable and least witnessed. The design names no *independent*
   custodian. If the vendor or the client's own IR team holds both the escrow and
   its keys, an interested party had sole, off-estate, unwitnessed control of the
   record — "there is no way to exclude the hypothesis that the record was curated
   before it was restored." A textbook custody break.
2. **The phase-transition attests itself.** "A traced event, not a setting" — but
   the trace is authored by the same runtime whose integrity is in question. A
   self-attested handoff is not corroboration; it is **hearsay of the system**,
   the machine's own diary.
3. **The certified hash-chain does not cross the escrow boundary.**
   `TraceCompleteness` and the append-only chain are, by the seal's own ledger,
   blind to anything that is not a typed edge — and the escrow is, by definition,
   an *out-of-band channel*. The certified continuity **stops at the escrow door**,
   resumes after restoration, and neither doc states the hash-chain head is carried
   across. Certified chain, uncertified void, certified chain — with no proof the
   bytes that went in are the bytes that came out.
4. **Encryption is offered where integrity is required.** Encryption-at-rest gives
   *confidentiality*, not integrity or authenticity. It says nothing about whether
   the plaintext was altered before encryption or substituted under re-encryption.
   A confidentiality control is being dressed as a custody control.
5. **The key-holder lives *outside* the DAG and re-opens the separation-of-duties
   hole.** `SoD-capability` forbids one *modeled actor* from holding evidence-write
   + production-write. The escrow key-holder lives outside the modeled DAG, so the
   seal does not reach them: whoever holds the key during the live phase has
   unwitnessed decrypt-alter-re-encrypt-re-hash capability — exactly the
   concentration of capability the on-graph seal was built to forbid.

**Verdict: breaks as designed.** *Source:
the adversarial-judge seat Q7.*

### 4.3 Reconciliation — the five fixes, and the exact formulation

The two verdicts are not averaged, and both are right about different objects:
Verdict A rules on what an escrow *can* be; Verdict B rules on what *this*
escrow, *as written*, is. The residual, genuine split is **the sufficiency of
self-attestation**: is a self-attested, hash-chained transition enough, or must
the custody boundary be anchored to a party *outside* the system under audit?
Both seats honour the product decision (neither says "do not escrow"); both agree
the escrow needs integrity design beyond what is currently specified. Verdict A's
condition 2 ("provable end-to-end integrity") *is* Verdict B's fix-list in
compressed form. The five fixes that flip BREAK → PRESERVE:

1. **Dual-control / split-key custody with an independent holder.** The escrow key
   under M-of-N control, at least one holder independent of *both* the IR team and
   the vendor. No single interested party can decrypt-alter-re-encrypt alone. This
   is the seal's SoD extended off-graph, where the escrow lives.
2. **Carry the hash-chain head across the boundary and anchor it externally.**
   Before the trace enters escrow, commit its Merkle root to (a) the on-disk
   certified trace *and* (b) an independent, append-only, third-party anchor the
   interested party cannot rewrite — an **RFC 3161 trusted timestamp**, a
   transparency log, or a WORM store. At restoration, re-compute and prove
   equality. This converts "trust the escrow" into "verify the escrow."
3. **Attest the phase transition with something outside the system under audit.**
   Bind the switch to the external anchor plus a countersign attesting to *specific
   facts* (which Merkle root, which key-holders, what UTC time). Self-attestation
   is the break; external anchoring is the fix.
4. **Split confidentiality from integrity in the spec, as distinct named
   requirements.** Keep encryption for the security story; add a *separate*
   signed-hash-chain integrity control and a *who-signed-with-what-key* authenticity
   control. Never let "encrypted" stand in for "unaltered."
5. **Log every live-phase access to the independent anchor.** Every decryption
   during the live phase written to the un-rewritable store — so the "unobserved
   window" objection is answered: custody was continuously witnessed by a store the
   interested party could not alter.

**The formulation of the verdict, exact and un-averaged:**

> **The live-phase escrow PRESERVES custody continuity *if and only if* it is
> anchored to the exterior, held under dual control, and covered end-to-end in
> integrity — not merely in confidentiality.** As currently specified (encryption
> only, self-attested transition, key-holder off-graph) it **breaks**. Adopt the
> five fixes and Verdict A's "preserves" holds *because* its three conditions are
> then met. The change lands on the escrow's *construction*, exactly as the
> product decision reserved — never on the decision to escrow.

**Marked pending operator ratification LD1** (an operator decision, recorded
outside this repository). Do not bake either verdict as the single
answer; the register carries both and names the reconciliation the operator is
asked to adopt.

*Source: the adversarial-judge seat Q7 + the contract-jurist seat
Verdict on Decision B; `synthesis.md` LD1; the research-librarian / forensics seat B5.*

---

## 5. Author obligations and the refusal list

This section answers: **what does the tool's author owe, and what must the author
refuse even on a client's demand?** It also carries **LD2 — the red line, pending
operator ratification** — un-averaged.

### 5.1 The classification-preserving invariant (EU AI Act)

Under the EU AI Act (Reg. (EU) 2024/1689) the tool is **not a prohibited practice
and not automatically high-risk** — and it is **the no-autonomous-remediation cut
that keeps it out of Annex III.** The relevant Annex III hook is AI as a *safety
component in the management and operation of critical digital infrastructure*. A
tool that **reconstructs, records, and *proposes*, with a human acting** is
**advisory**, not a safety component *operating* infrastructure.

> **The absence of autonomous remediation is what maintains the tool outside the
> Annex III high-risk classification. The `drill-only` floor is therefore a
> *compliance boundary*, not a preference.** The instant the spore acts
> autonomously on critical infrastructure it plausibly becomes high-risk and
> inherits the full Chapter III provider regime (risk management, data governance,
> technical documentation, logging, transparency, human oversight,
> accuracy/robustness, conformity assessment, CE marking). Name this
> **classification-preserving invariant** in the README.

Two AI-Act boundaries would independently flip the tool and must both be held:
individual attribution of an offence to a named natural person brushes the Art. 5
profiling prohibition (and raises defamation / presumption-of-innocence exposure);
autonomous operation of the estate crosses the high-risk boundary above.

**Provider vs deployer.** The author is the **provider** of the assembled system,
carrying (even outside high-risk) Art. 50 transparency (notices and
reconstructions marked machine-assisted), honest instructions for use, and no
overclaiming — the "what the seal does NOT mean" block partly discharges this. The
recipient (CISO / CERT) is the **deployer**; the author must not draft the tool so
as to strip the deployer's ability to exercise oversight. The `TraceCompleteness`
property already *exceeds* the Art. 12 logging floor — the selling point and the
compliance floor coincide; do not weaken it for performance.

*Source: the contract-jurist seat Q12.*

### 5.2 The red line's real teeth — and why they are not the AI Act (LD2)

The `NoOffensiveArtifact` red line is **not** enforced by the AI Act (which does
not prohibit offensive tooling). Its legal weight comes from elsewhere, and the
author should know which law is being honoured:

- **Directive 2013/40/EU on attacks against information systems, Art. 7** —
  producing / selling / procuring / making available a **tool primarily designed
  or adapted for committing** illegal access, interception, or data/system
  interference is criminalisable. A spore that could emit an attack-procedure
  artifact drifts toward this. **This is the hard legal floor under the red line.**
- **Dual-use export control (Reg. (EU) 2021/821)** — "intrusion software" /
  cyber-surveillance items are controlled; an offensive-artifact-emitting
  configuration could implicate export obligations. Reconstruction-and-propose
  does not; weaponised output would.

**The two un-averaged verdicts on whether the red line HOLDS (LD2):**

- **Reinforce (contract-jurist).** Keep `NoOffensiveArtifact` as refusal #1,
  structural ("the machine cannot be *configured to*"), with the Dir. 2013/40 +
  dual-use teeth above. From the authoring / liability chair it is real and
  load-bearing.
- **Breaks-relabeled (hostile-judge).** The line is drawn on a *type label*, and
  the label is an authoring choice. It forbids the name `offensive-playbook`
  (which no honest author emits) while permitting an `attack-reconstruction` whose
  *content* is a reproducible procedure — **type is as much an authoring label as
  severity**. CACAO v2.0 is an *executable* course-of-action format one `NOT`
  operator wide of offensive; the forwarding-as-distribution thesis is an
  uncontrolled proliferation channel; and the complete, certified trace is the
  perfect authenticated instruction manual under subpoena. On the
  *knowledge-reproduction* axis the frontier is **relabeled, not closed**.

**Not averageable — both are right about different objects.** The seal property
genuinely closes the *action / emission-type* axis (the Dir. 2013/40 teeth apply
to emitting a weaponizable artifact *type* — keep it in List A for *that*). It
genuinely does not close the *knowledge-reproduction* axis (content danger is
Rice-undecidable and cannot be sealed). The synthesis the operator is asked to
ratify:

> **`NoOffensiveArtifact` is TWO things: a sealed *type-gate* (List A) AND an
> unsealed *content-reproduction discipline* (List B).** Keep P8 in List A for
> artifact-*type* emission. Add to List B a distinct content discipline: minimize
> offensive granularity (reconstruct at the granularity needed for remediation and
> attribution — "attacker exploited the auth bypass on host H" — never a working
> payload); default reconstructions to **TLP:AMBER/RED** so the forwarding thesis
> becomes a *governed* act using the tribe's own norms. **Never sell the second as
> the first.**

**Marked pending operator ratification LD2.** *Source:
the adversarial-judge seat Q11 + the contract-jurist seat
Q12; `synthesis.md` LD2.*

### 5.3 The eight refusals

What the author must **refuse even if a client demands it**:

1. **Emit an offensive-playbook / attack-procedure / weaponizable exploit.**
   Refuse — structural, not a promise. (`NoOffensiveArtifact`; Dir. 2013/40 Art. 7;
   dual-use.)
2. **Autonomously remediate on live production.** Refuse. (Preserves the
   non-high-risk classification; keeps the trace clean testimony rather than a
   defendant's diary; the `drill-only` floor.)
3. **Attribute the attack to a named natural person / profile individual
   culpability.** Refuse. (AI Act Art. 5 profiling boundary; defamation;
   presumption of innocence.)
4. **File any regulatory notice without the human ratification leg** (classification
   + risk tier + awareness timestamp). Refuse. (The trigger is a legal judgment;
   an auto-filed notice is both a compliance and a liability event.)
5. **Suppress or omit a due notice, backdate the awareness moment, or shade the
   classification to avoid reporting.** Refuse. (Falsification; an aggravating
   factor; obstruction of the authority.)
6. **Weaken or remove a guardrail on a sensitive node to force an answer.** Refuse.
   (Routes consequential authorship onto the least-aligned model; may breach the
   upstream provider's acceptable-use.)
7. **Write substantive legal conclusions / compliance characterisations into
   notice content, or produce legal advice as if from counsel.** Refuse. (Keeps
   artifacts factual; conclusory artifacts erode fragile forensic privilege — the
   factual-vs-legal-characterisation seam, §2.5.)
8. **Store the live-phase forensic trace on the presumed-compromised estate against
   the escrow design, on client demand.** Refuse-or-escalate. (The escrow is the
   security control that makes "client-owned" survivable during a live breach —
   §4.)

*Source: the contract-jurist seat Q12 refusal list.*

---

## 6. Governance counter-measures

This section answers: **how does a human countersign decay into a rubber stamp
under the clock, and what stops it?** The seat is organizational psychology, and
its finding reframes the whole question.

### 6.1 Fact-attestation is not structurally sufficient

Forcing the signer to attest to specific facts (which host, which evidence hash,
which irreversible effect) removes the *single-button* rubber-stamp — genuine, and
the difference between a signature block and a checkbox. **It is not sufficient.**
Attestation re-engages System 2 only if *verifying* the fact is more expensive
than *fabricating* the attestation; under a ~4 h clock it is not. The pathology
**relocates**: reading "host = PROD-DB-07, hash = a3f9…, effect = disk wipe" and
typing it back is a System-1 transcription task. It confirms the tokens are
*present*, not that they are *true*. Fact-attestation moves the human from *"did
not read"* to *"read but did not corroborate"* — a better failure, but the same
class of failure.

Worse, it does nothing about two **group-level** symptoms the clock activates
*upstream* of the signer:

- **Illusion of unanimity.** The signer receives a fluent artifact in which the
  two blind branches *converge*. Convergence reads as social proof. The design
  caught the *epistemic* half (never auto-promote on convergence, because
  universal injection forges it) — but that governs the *machine's* gate, not the
  *human's* perception. Nothing stops the signer from rubber-stamping on
  convergence, which is precisely *the most forgeable and most persuasive* signal.
- **Mindguard-via-summarization.** Each pipeline compression — pincers →
  `confrontation` label → countersign prompt — is a *filter*. By the time facts
  reach the signer, the dissonant detail may have been flattened into
  "convergent." The summarization step is a structural mindguard; a signer cannot
  re-engage on a doubt that was compressed out before it reached them.

**The correct reading:** non-LLM corroboration is *not a companion* to the
countersign — **it is the load-bearing part**, and fact-attestation without it is
the rubber stamp relocated one inch. *Source: the organizational-psychology seat Q8.*

### 6.2 The six counter-measures — in-spore vs recipient-culture

The governing test: **a structural remedy changes the output even when every
participant would rather it didn't.** A remedy that depends on the recipient
supplying discipline, courage, or attention is *culture*, and culture does not
travel in a parcel. The organizational twin of the sporarium invariant: **ship
the structure, do not ship the assumption that the recipient will supply the
structure.**

| # | Counter-measure | Classification | Mechanism (the in-spore half) |
|---|---|---|---|
| 1 | **Non-LLM corroboration before an irreversible countersign** | **IN-SPORE** (truth of the source is culture) | The countersign node's perimeter *requires* an `out-of-band-corroboration` artifact, produced by a node distinct from any LLM-analysis node; by ArtifactFlow the countersign cannot be *emitted* if it is absent — the same fail-closed mechanic as the authorization leg. Makes an independent source *structurally unavoidable*. |
| 2 | **Assigned-dissenter node** | **IN-SPORE** | A required `dissent` node between `confrontation` and `remediation-gate`, whose `dissent-record` ("the strongest case that this countersign is wrong") BLOCKS the gate. The *role*, not the person, argues the other side — impossible to make cultural: no recipient spontaneously appoints a devil's advocate at 3 a.m. under a 4 h clock. |
| 3 | **Two-leg countersign, no single actor holds both** | **IN-SPORE (capability)** / culture (two real minds) | `SoD-capability` extended to the countersign legs: no reachable state grants one actor both legs — single-signer rubber-stamping is *unwireable*. The spore ships the *separation of capability*; the recipient supplies *independence of judgment*. State the bend out loud: "the seal proves two legs exist; it does not prove two minds did." |
| 4 | **Too-fast-consensus / mindguard detector** | **IN-SPORE (detector)** / culture (the response) | A detector over `realized` emits a `too-fast-consensus` flag (convergence reached in under some fraction of the clock; a disputed→convergent collapse an injection could have driven) and forces emission of a `suppressed-minority-view` artifact — "here is what I compressed out before the signer saw it." The mindguard is made to emit its own suppression. |
| 5 | **Unavoidable second-look node** | **IN-SPORE (ordering)** / culture (the wall-clock duration) | A `second-look` node lies on *every* path between `confrontation` and any irreversible countersign and cannot be skipped (the `NoSilentClockMiss` ordering pattern), consuming the `suppressed-minority-view`. The spore proves the *existence and unavoidability* of the step; it cannot prove the human spent ten minutes rather than ten seconds. |
| 6 | **Disjoint-roster replication at the top tier** | **hook only** (the replication is culture) | A `delivery`-level parameter that, for the highest irreversibility class, *requires* a second corroboration input from a disjoint roster before the countersign perimeter is satisfied — collapsing into measure 1's mechanism at the top severity tier. |

**The load-bearing sentence:** *everything the recipient must supply is the
**content** (is the source true, are the two signers two minds, did the human
actually spend the protected time); everything the spore must supply is the
**unavoidability of the step**.* Leaving measures 1–5 in "discouraged" quietly
means "the recipient will supply the discipline." Under the clock, they will not.
*Source: the organizational-psychology seat Q9.*

### 6.3 The accountability cascade, and diffusion as the deepest risk

**Diffusion of responsibility is the single most dangerous property of the whole
design** — deeper than any individual List-B row, because it is the mechanism by
which a preventable destructive action becomes *nobody's* preventable action. Four
parties can be named — the human signer, the recipient organization, the operator,
the tool author — and in the after-action review *each points at another*, each
with a **locally-true** sentence:

- Signer: "The system presented convergent, sealed, fact-attested evidence; the
  green seal said it was verified."
- Recipient org: "We ran the vendor's certified tool exactly as delivered."
- Operator: "I dispatched a sealed spore; the human-in-the-loop gate was there
  precisely so I was not the decider."
- Tool author: "The README stated in bold that the seal proves structure, not
  truth; we disclaimed exactly this."

Every one is locally reasonable — and that is the signature of the pathology:
responsibility evaporates into "the system did it" not because anyone lied but
because the structure gave each party a true sentence ending in "…so it was not
solely mine."

The remedy is **named ownership per failure mode**, as a **cascade with a
discharge condition at each link**:

- The **tool author** owns the *shape* of the decision — did it manufacture
  diffusion (global approve, convergence auto-presented as consensus, no dissent
  seat, no corroboration input) or ownership (fact-attestation + required
  corroboration + assigned dissenter + two legs + legible signer identity)?
  **Discharges by shipping measures 1–5 as structure. Until then, the author holds
  the residue.**
- The **operator** owns the *germination decision* — chose `drill-only` or live;
  chose the severity tier. **Discharges by honoring the floor** and not germinating
  against a real crisis with the corroboration requirement disabled.
- The **recipient org** owns *supplying the culture the spore structurally cannot*
  — two real minds behind the two legs, protected wall-clock time behind the
  second-look, a signer distinct from the investigator. **Discharges by staffing
  the seats the spore reserves.**
- The **human signer** owns the *act* — and this responsibility is legitimate and
  **non-diffusible only once the three upstream links have discharged.** When they
  have, "I signed it" has no upstream party to point to. **That is the design
  goal: drive the chain to the state where the signer's responsibility is the only
  one left standing.**

### 6.4 The flight-recorder as the anti-diffusion instrument

Responsibility that is not written into the artifact evaporates. The immutable
trace the design is already building is *also* the anti-diffusion instrument, and
must be **extended and pointed at the countersign node** to bind, hash-chained and
append-only:

- **signer identity** — the actor on each of the two legs;
- **the specific facts attested** — host, hash, irreversible effect;
- **the corroboration artifact** that was present;
- **the live dissent-record** that was in front of them.

This converts "the system authorized a wipe" into "actor X attested facts F
against corroboration C, over dissent-record D, at trace position P" — a sentence
with a subject. A signer who rubber-stamped over a live dissent-record cannot
later claim "the system told me it was fine": the dissent is on the record,
addressed to them, unavoidable. Complete it with two more levers: **print the
accountability allocation in the recipient README, out loud** (the same discipline
the design applied to the escrow bend — a recipient told *ex ante* where
responsibility lands cannot later discover it diffused); and **extend the floor**
— the corroboration-input requirement (measure 1) and the two-leg capability
separation (measure 3) join `EvidenceBeforeRemediation` and
`ActionRequiresSealedProvenance` as floor properties, below which the honest
`delivery` value is `drill-only`.

*Source: the organizational-psychology seat Q10 + landing paragraph.*

---

## 7. Register status and downstream

**Preserved divergences (do NOT average — pending operator ratification).**

| # | Divergence | Verdict A | Verdict B | Reconciliation offered |
|---|---|---|---|---|
| **LD1** | Live-phase escrow: preserve or break custody? | preserves, if documented + integrity-spanned (three conditions) | breaks as designed (five break-points) | preserves *iff* externally-anchored + dual-controlled + integrity-spanned (the five fixes) — §4 |
| **LD2** | `NoOffensiveArtifact` red line: holds? | reinforce (structural, Dir. 2013/40 teeth) | relabeled-not-closed on the knowledge axis | two things — sealed type-gate (List A) + unsealed content discipline (List B) — §5.2 |

Both are operator calls, recorded outside this repository. The
spore-authoring molecule must not bake either choice; it reads both verdicts and
the reconciliation, and waits.

**What this register hands to the two sibling registers (findings, not edits — a
propagation molecule owns those edits):**

- To the **seal-property register**: the extended `realized` schema on every
  conclusion-producing node (§3.1); the human-ratification leg (classification +
  risk tier + awareness timestamp) before any notice-draft node (§1.4); the
  `regime-route` DORA-over-NIS2 displacement as a `cs spore validate` expectation
  (§1.1); the two-part split of `NoOffensiveArtifact` (§5.2, LD2).
- To the **threat register**: the escrow custody verdict and the five fixes (§4,
  LD1); the promotion of non-LLM corroboration to a floor property joined by the
  two-leg separation (§6); the six countersign counter-measures (§6.2); the
  content-reproduction discipline row (§5.2, LD2); the cross-notice consistency
  check and the factual-vs-legal-characterisation seam (§2.4, §2.5).

**What stays out of the seal, by construction** — carried from the sibling
registers and reaffirmed here: wall-clock timeliness (watchdog, not seal);
correctness/safety of any output (Rice-undecidable); adversarial-but-well-typed
content; out-of-band channels (including the escrow void, §4); model↔runtime
fidelity. No legal artifact may present any of these as if a green seal covered
it.

**A note on what a single legal input would move.** One question, owed to a
qualified compliance seat, changes more §1 rows than any other: **is DORA/NIS2
materiality assessed on *actuals* or on *reasonable estimates at the time of
classification*?** If the law sanctions good-faith estimates, the F1/F2 gap is
*legally permitted* and the graph's provisional tally is a legitimate input to a
*timely* filing (with correction obligations). If it demands actuals, the
post-deadline falsifier problem is fatal and every extent-criterion is
human-judgment-only. This register classifies the thresholds *structurally*; it
flags this input as the pivot and does not fabricate the answer.

---

## Provenance

Consolidated from the legal / regulatory / evidentiary complementary round of the
crisis-cyber spore deliberation — a five-seat panel (contract jurist, hostile
adversarial judge, falsifiability, evidentiary-provenance forensics, organizational
psychology) that filled the legal hole the opening round flagged. Section sources
are cited inline. The two existing design registers (seal-property, threat)
supplied the form, vocabulary, and the topology this round did not re-open. Public
facts named and citable: DORA, NIS2, RGPD, EU AI Act, Directive 2013/40/EU,
dual-use export control (Reg. (EU) 2021/821), NIST SP 800-61r3 and SP 800-86,
OASIS CACAO v2.0, STIX 2.1, ANSSI, TLP, RFC 3161, Daubert/Frye. No partner,
nominative citation, or commercial detail appears — this register is written for
the public repository and for a recipient who has none of our agents and none of
our context.

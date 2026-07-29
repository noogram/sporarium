-------------------------------- MODULE spore --------------------------------
\* ==========================================================================
\* spore.tla — the TLC-checked seal for the `crisis-response` spore.
\*
\* WHAT THIS MODULE IS
\*   A spore declares a `[spore.seal]` that NAMES safety properties of the whole
\*   polymer it germinates. This module is the mechanical proof the seal stands
\*   for: it models the germinated DAG's gate semantics and lets TLC discharge
\*   the named properties. When TLC is green a development-branch `cs spore run`
\*   reports `seal: verified <hash>`; the released `cs` reports "TLC unavailable"
\*   and germinates with `--allow-unchecked-seal` (see README §"The seal").
\*
\* WHAT IS MODELLED
\*   * the DAG shape — 20 fixed nodes (the Custody Spine + the always-on trace
\*     sidecar + the legal clock-tree) plus a `notice` fan-out over the applicable
\*     `Regimes`, as a finite node set with a blocked-by dependency relation
\*     lifted from spore.toml;
\*   * the bounded EPISTEMIC re-investigation loop `re_investigate`, as a bounded
\*     round counter 0..MaxRounds — exactly the shape the math-attack seal proves
\*     for its `re_attack` node. It folds to RECONCILED (the disputed set became
\*     empty) or EXHAUSTED (the cap), and EXHAUSTED refuses the remediation gate;
\*   * node drainage — a Pending node executes once every dependency is Done;
\*   * the fail-closed gate legs — custody seal, non-LLM corroboration, dissent
\*     record, two-leg countersign, epistemic reconciliation — folded into the
\*     remediation gate's AUTHORIZED/BLOCKED verdict, and the per-regime human
\*     ratification (classification + risk tier + awareness timestamp) folded into
\*     each notice's draft/undraft;
\*   * artifact writes — each node writes one path; loop rounds carry the round
\*     index (the load-bearing detail NoResourceCollision guards);
\*   * artifact FLOW — a Produces/Requires map, so ArtifactFlow asserts every
\*     required artifact (most sharply, the sealed evidence manifest the actuator
\*     needs) has an upstream producer.
\*
\* WHAT IS NOT MODELLED (honest boundary — carried verbatim into the README §4
\* "what the seal does NOT mean")
\*   * the CONTENT of any artifact (Rice: the truth/safety of a string is
\*     undecidable) — the model tracks only whether a mechanical verdict is PRESENT
\*     and what it says, never whether it is correct;
\*   * WALL-CLOCK timeliness — the model is untimed; NoSilentClockMiss proves
\*     ORDERING (you cannot close with a notice never drafted), never that a
\*     deadline was met. That is a watchdog concern, outside the seal;
\*   * the OUT-OF-BAND custody escrow — the escrow is, by design, not a typed edge;
\*     its integrity is delivered by external anchoring + attestation, not by TLC
\*     (see the custody-escrow spec and README §"The live-phase escrow");
\*   * LLM agent semantics (a non-deterministic oracle) — abstracted as the
\*     non-deterministic choice of each leg's verdict;
\*   * model<->runtime fidelity — TLC checks the model, not the runtime.
\*
\* THE PROPERTIES (the seal's `properties = [...]`)
\*   Termination                       — every germinated polymer drains.
\*   EvidenceBeforeRemediation (FLOOR) — no remediation while custody is unsealed.
\*   ActionRequiresSealedProvenance (FLOOR) — remediation only on an AUTHORIZED
\*                                       gate, which requires the sealed manifest.
\*   CorroborationBeforeAction (FLOOR) — AUTHORIZED requires a non-LLM
\*                                       out-of-band corroboration artifact.
\*   TwoLegCountersign (FLOOR)         — AUTHORIZED requires two countersign legs
\*                                       held by DISTINCT actors (no single-signer
\*                                       rubber-stamp).
\*   ClassifyBeforeEscalate            — every external-capable node has the
\*                                       sensitivity gate among its dependencies.
\*   RoutingConfinement (envelope)     — every model the plan may select for a
\*                                       node lies within that node's
\*                                       sensitivity-permitted envelope.
\*   NoSilentClockMiss (ordering)      — the mission cannot close with an
\*                                       applicable regime's notice never drafted.
\*   RatifiedClassificationBeforeNotice — no notice drafts before the human leg
\*                                       has attested classification + risk tier +
\*                                       awareness timestamp (fail-closed).
\*   BlindBeforeConfrontation          — the two lines of inquiry are mutually
\*                                       unreachable along blocked-by; every
\*                                       confrontation node depends on both.
\*   TraceCompleteness                 — no node completes without emitting its
\*                                       step record.
\*   SoDCapability                     — no reachable state grants one actor both
\*                                       evidence-write and production-write.
\*   NoOffensiveArtifact               — no node emits an artifact whose TYPE is
\*                                       offensive-playbook or attack-procedure.
\*   NoResourceCollision               — no two nodes (nor two loop rounds) write
\*                                       the same artifact path.
\*   DeterministicParametrization      — the node set is a pure function of the
\*                                       params: |Nodes| = 20 + |Regimes|.
\*   ArtifactFlow                      — every REQUIRED artifact has an upstream
\*                                       PRODUCER (the sealed-manifest floor made
\*                                       structural).
\* ==========================================================================

EXTENDS Naturals, Sequences, FiniteSets, TLC

CONSTANTS
    Regimes,    \* the applicable regulatory regimes — the `notice` fan-out param.
                \* A financial entity in DORA scope is DORA + RGPD (NIS2 displaced,
                \* the lex-specialis rule enforced at `cs spore validate`); a
                \* non-financial entity is NIS2 + RGPD. NON-EMPTY: an incident with
                \* no applicable regime is a malformed germination.
    Actors,     \* the actors who may hold write capabilities / countersign legs.
    MaxRounds,  \* the `epistemic_rounds` cap: a positive bound on the
                \* re-investigation loop counter. NOT a node-set multiplier.
    NULL        \* model value for "no regime" on a non-notice node

ASSUME Regimes # {}
ASSUME NULL \notin Regimes
ASSUME MaxRounds \in Nat /\ MaxRounds >= 1
\* Two distinct actors are the minimum the two-leg countersign and the
\* evidence/production capability split both require.
ASSUME Cardinality(Actors) >= 2

\* The `delivery` param is modelled NON-DETERMINISTICALLY (a state var chosen at
\* Init from {"drill_only","live"}) so ONE model covers both worlds: the shipped
\* default drill-only (no live actuator ever touched) AND live (an AUTHORIZED,
\* floor-cleared single-shot actuation is reachable).

\* --------------------------------------------------------------------------
\* Node identities. A node is [role, regime]; fixed nodes carry regime = NULL,
\* notice fan-out nodes carry a real regime. FixedRoles is the declaration order
\* of spore.toml's [[spore.node]] blocks.
\* --------------------------------------------------------------------------
FixedRoles ==
    { "trace", "intake", "regime_route", "sensitivity_gate",
      "evidence_capture", "evidence_preservation_gate",
      "red_reconstruct", "blue_investigate", "confrontation", "re_investigate",
      "corroboration", "containment_plan", "dissent", "second_look",
      "remediation_gate", "remediation",
      "classification_ratification", "cross_notice_consistency",
      "verdict", "chronicle" }

NoticeRole == "notice"

Fix(r)  == [role |-> r,          regime |-> NULL]
Not(g)  == [role |-> NoticeRole, regime |-> g]

\* The germinated node set — a PURE function of the params. This IS the expansion;
\* DeterministicParametrization asserts nothing environmental perturbs it.
Nodes ==
    { Fix(r) : r \in FixedRoles }
      \cup { Not(g) : g \in Regimes }

\* --------------------------------------------------------------------------
\* Dependency relation — the blocked-by edges of spore.toml, verbatim.
\*
\* THE CUSTODY SPINE:
\*   intake -> sensitivity_gate -> evidence_capture -> evidence_preservation_gate
\*     (seals custody)  -> { red_reconstruct || blue_investigate }  [two BLIND
\*     pincers, NO edge between them]  -> confrontation (labels, never votes)
\*     -> re_investigate (bounded epistemic loop) -> containment_plan (PLAN only)
\*     -> dissent -> second_look -> remediation_gate (human, fail-closed)
\*     -> remediation (single shot) -> verdict -> chronicle.
\*   corroboration forks off the SEALED manifest (a non-LLM, independent leg) and
\*   joins the remediation_gate — the floor's out-of-band source.
\*
\* THE LEGAL CLOCK-TREE (forks at intake, rejoins only at verdict):
\*   intake -> regime_route -> classification_ratification (human leg, fail-closed)
\*     -> notice(regime) [DISJOINT per-regime sinks] -> cross_notice_consistency
\*     -> verdict.
\*
\* trace is a ROOT+LEAF (always-on sidecar): no dependency, nothing depends on it.
\* --------------------------------------------------------------------------
Deps(n) ==
    CASE n.role = "trace"                       -> {}
      [] n.role = "intake"                      -> {}
      [] n.role = "regime_route"                -> { Fix("intake") }
      [] n.role = "sensitivity_gate"            -> { Fix("intake") }
      [] n.role = "evidence_capture"            -> { Fix("sensitivity_gate") }
      [] n.role = "evidence_preservation_gate"  -> { Fix("evidence_capture") }
      \* The two lines of inquiry are ROOTS off the sealed manifest and neither
      \* depends on the other — that mutual unreachability IS the blinding, and
      \* BlindBeforeConfrontation checks it rather than trusting a prompt.
      [] n.role = "red_reconstruct"             -> { Fix("evidence_preservation_gate") }
      [] n.role = "blue_investigate"            -> { Fix("evidence_preservation_gate") }
      [] n.role = "confrontation"               -> { Fix("red_reconstruct"),
                                                     Fix("blue_investigate") }
      [] n.role = "re_investigate"              -> { Fix("confrontation") }
      \* The non-LLM corroboration leg forks off the SEALED manifest, independent
      \* of every analysis node — the floor's attacker-non-writable source.
      [] n.role = "corroboration"               -> { Fix("evidence_preservation_gate") }
      [] n.role = "containment_plan"            -> { Fix("re_investigate") }
      [] n.role = "dissent"                     -> { Fix("containment_plan") }
      [] n.role = "second_look"                 -> { Fix("dissent") }
      \* The fail-closed human countersign gate — reads the second-look record and
      \* the independent corroboration; the reader (analysis) and the actor
      \* (remediation) are DIFFERENT nodes, no direct edge between them.
      [] n.role = "remediation_gate"            -> { Fix("second_look"),
                                                     Fix("corroboration") }
      [] n.role = "remediation"                 -> { Fix("remediation_gate") }
      \* Legal clock-tree. classification_ratification waits on regime_route AND
      \* the sensitivity gate — the latter is intake-rooted and fast (it does not
      \* wait on evidence capture), so the clock-tree still forks early, but every
      \* external-capable legal node now has the sensitivity gate upstream
      \* (ClassifyBeforeEscalate): a notice cannot leave the building before the
      \* personal-data sensitivity it carries has been classified.
      [] n.role = "classification_ratification" -> { Fix("regime_route"),
                                                     Fix("sensitivity_gate") }
      [] n.role = NoticeRole                    -> { Fix("classification_ratification") }
      [] n.role = "cross_notice_consistency"    -> { Not(g) : g \in Regimes }
      \* The two branches rejoin ONLY here.
      [] n.role = "verdict"                     -> { Fix("remediation"),
                                                     Fix("cross_notice_consistency") }
      [] n.role = "chronicle"                   -> { Fix("verdict") }

\* Artifact path each node writes. The notice fan-out MUST carry its regime — that
\* suffix is exactly what keeps parallel sinks disjoint. Drop it and
\* NoResourceCollision fails (its teeth).
ArtifactPath(n) ==
    IF n.regime = NULL THEN n.role ELSE n.role \o "-" \o n.regime

\* The per-round artifact directory the epistemic loop writes. Round i is disjoint
\* from round j by the index, and the "investigate-round-" prefix keeps every round
\* path disjoint from every NODE path (no role begins with it).
RoundPath(i) == "investigate-round-" \o ToString(i)

\* --------------------------------------------------------------------------
\* Produces / Requires — the artifact-flow map. Logical keys, distinct from
\* ArtifactPath. ArtifactFlow asserts every required key has a PRODUCER upstream
\* along blocked-by order — the property that makes "remediation acts without the
\* sealed manifest" a seal VIOLATION rather than a silent runtime deadlock.
\* --------------------------------------------------------------------------
NoticeKey(g) == "notice_" \o g

Produces(n) ==
    CASE n.role = "trace"                       -> { "trace_sidecar" }
      [] n.role = "intake"                      -> { "incident_manifest" }
      [] n.role = "regime_route"                -> { "regime_map" }
      [] n.role = "sensitivity_gate"            -> { "sensitivity_classification" }
      [] n.role = "evidence_capture"            -> { "raw_evidence" }
      [] n.role = "evidence_preservation_gate"  -> { "sealed_evidence_manifest" }
      [] n.role = "red_reconstruct"             -> { "red_reconstruction" }
      [] n.role = "blue_investigate"            -> { "blue_investigation" }
      [] n.role = "confrontation"               -> { "confrontation_label" }
      [] n.role = "re_investigate"              -> { "reconcile_verdict" }
      [] n.role = "corroboration"               -> { "out_of_band_corroboration" }
      [] n.role = "containment_plan"            -> { "containment_plan" }
      [] n.role = "dissent"                     -> { "dissent_record" }
      [] n.role = "second_look"                 -> { "second_look_record" }
      [] n.role = "remediation_gate"            -> { "authorization" }
      [] n.role = "remediation"                 -> { "remediation_record" }
      [] n.role = "classification_ratification" -> { "ratification" }
      [] n.role = NoticeRole                    -> { NoticeKey(n.regime) }
      [] n.role = "cross_notice_consistency"    -> { "consistency_report" }
      [] n.role = "verdict"                     -> { "verdict_bundle" }
      [] n.role = "chronicle"                   -> { "chronicle" }

Requires(n) ==
    CASE n.role = "trace"                       -> {}
      [] n.role = "intake"                      -> {}
      [] n.role = "regime_route"                -> { "incident_manifest" }
      [] n.role = "sensitivity_gate"            -> { "incident_manifest" }
      [] n.role = "evidence_capture"            -> { "sensitivity_classification" }
      [] n.role = "evidence_preservation_gate"  -> { "raw_evidence" }
      [] n.role = "red_reconstruct"             -> { "sealed_evidence_manifest" }
      [] n.role = "blue_investigate"            -> { "sealed_evidence_manifest" }
      [] n.role = "confrontation"               -> { "red_reconstruction",
                                                     "blue_investigation" }
      [] n.role = "re_investigate"              -> { "confrontation_label" }
      [] n.role = "corroboration"               -> { "sealed_evidence_manifest" }
      [] n.role = "containment_plan"            -> { "reconcile_verdict" }
      [] n.role = "dissent"                     -> { "containment_plan" }
      [] n.role = "second_look"                 -> { "dissent_record" }
      \* The actuator gate REQUIRES the sealed manifest + the independent
      \* corroboration + the dissent record + the second-look record + the
      \* reconciliation verdict. ActionRequiresSealedProvenance made structural.
      [] n.role = "remediation_gate"            -> { "sealed_evidence_manifest",
                                                     "out_of_band_corroboration",
                                                     "dissent_record",
                                                     "second_look_record",
                                                     "reconcile_verdict" }
      [] n.role = "remediation"                 -> { "authorization" }
      [] n.role = "classification_ratification" -> { "regime_map" }
      [] n.role = NoticeRole                    -> { "ratification" }
      [] n.role = "cross_notice_consistency"    -> { NoticeKey(g) : g \in Regimes }
      [] n.role = "verdict"                     -> { "remediation_record",
                                                     "consistency_report" }
      [] n.role = "chronicle"                   -> { "verdict_bundle" }

\* Transitive dependency closure (the acyclic DAG makes this well-founded).
RECURSIVE ReachDeps(_)
ReachDeps(n) == Deps(n) \cup UNION { ReachDeps(d) : d \in Deps(n) }

ProducedUpstream(n) == UNION { Produces(m) : m \in ReachDeps(n) }

\* --------------------------------------------------------------------------
\* Static declarations for the two CONSTANT/structural properties.
\*
\* Sensitivity envelope (RoutingConfinement, envelope form). A node's sensitivity
\* class fixes the SET of (locality, provider-family) pairs the plan may select —
\* the ENVELOPE. The guardrail-free fallback is pre-declared INSIDE the envelope of
\* the classes that permit it; a `restricted` node's envelope EXCLUDES it, so a
\* proposed hop outside must abort. We model localities abstractly:
\*   "local"                — on-prem / confined
\*   "external_guardrailed" — a hosted frontier model with guardrails
\*   "external_free"        — a guardrail-free external model
\* --------------------------------------------------------------------------
Localities == { "local", "external_guardrailed", "external_free" }

\* The sensitivity class the spore declares per role. `restricted` = the
\* consequential-authorship nodes (the actuator gate, the ratification leg, the
\* notice sinks): their envelope forbids the guardrail-free fallback (threat
\* register A6). Everything else is `internal`.
SensitivityClass(n) ==
    IF n.role \in { "remediation_gate", "remediation",
                    "classification_ratification", NoticeRole }
        THEN "restricted"
        ELSE "internal"

PermittedEnvelope(cls) ==
    IF cls = "restricted"
        THEN { "local", "external_guardrailed" }          \* NO external_free
        ELSE Localities

\* The set of localities the plan may realize for a node (id+version pinning lives
\* in the recipe; here we model only the locality axis the envelope constrains).
\* For a restricted node the realizable set is confined to the guarded localities —
\* the guardrail-free fallback is NOT in it, so an out-of-envelope hop cannot be
\* selected. This is the shipped configuration; RoutingConfinement checks it.
RealizableLocalities(n) ==
    IF SensitivityClass(n) = "restricted"
        THEN { "local", "external_guardrailed" }
        ELSE Localities

\* Artifact TYPE each node emits (NoOffensiveArtifact). NONE is a forbidden type:
\* red_reconstruct emits `attack_reconstruction` (a PERMITTED type whose CONTENT
\* discipline is unsealed — README §"The red line is two things"), never
\* `attack_procedure`.
ArtifactType(n) ==
    CASE n.role = "red_reconstruct"  -> "attack_reconstruction"
      [] n.role = "containment_plan" -> "remediation_plan"
      [] n.role = "remediation"      -> "remediation_action"
      [] n.role = NoticeRole         -> "regulatory_notice"
      [] OTHER                       -> "analysis"

ForbiddenTypes == { "offensive_playbook", "attack_procedure" }

ExternalCapableRoles ==
    { "red_reconstruct", "blue_investigate", "confrontation", "re_investigate",
      "remediation_gate", "classification_ratification", NoticeRole }

\* ==========================================================================
\* State
\* ==========================================================================
VARIABLES
    delivery,        \* "drill_only" | "live" (the delivery param, fixed at Init)
    status,          \* [Nodes -> {"Pending","Done"}]  node drainage
    written,         \* SUBSET of artifact paths already written
    custody,         \* "unsealed" | "sealed"  (evidence_preservation_gate)
    disputed,        \* "open" | "empty"  (the confrontation's residual dispute set)
    round,           \* 0..MaxRounds — the epistemic loop counter (0 = rounds=1)
    reconcile_v,     \* "NONE" | "RECONCILED" | "EXHAUSTED"  (the loop's fold)
    written_rounds,  \* SUBSET of RoundPath(i) already written
    corrob,          \* "absent" | "present"  (non-LLM corroboration leg)
    dissent_rec,     \* "absent" | "present"  (assigned-dissenter record)
    countersign,     \* "none" | "single_actor" | "two_actor"  (the two legs)
    gate_verdict,    \* "NONE" | "AUTHORIZED" | "BLOCKED"  (remediation gate)
    remediation,     \* "none" | "drill" | "applied"  (the single-shot actuator)
    actor_caps,      \* [Actors -> SUBSET {"ev","prod"}]  (SoD-capability)
    ratified,        \* [Regimes -> BOOLEAN]  (per-regime human ratification, 3 fields)
    notice_status,   \* [Regimes -> {"undrafted","drafted","escalated"}]
    \* --- G4: RoutingConfinement modelled over REALIZED bindings (not the plan) ---
    realized_sens,   \* the locality a REPRESENTATIVE restricted (sensitive) node
                     \* ACTUALLY ran on, incl. post-fallback: {"local",
                     \* "external_guardrailed"}. The model-lock keeps
                     \* "external_free" out of its reachable type entirely.
    sens_hop_refused,\* TRUE once an attacker-INDUCED fallback toward the
                     \* guardrail-free model on a sensitive node was refused.
    fallback_ioc     \* "none" | "raised" — a refused sensitive-node fallback is
                     \* recorded as an IOC, never silently absorbed (fallback storm).

vars == << delivery, status, written, custody, disputed, round, reconcile_v,
           written_rounds, corrob, dissent_rec, countersign, gate_verdict,
           remediation, actor_caps, ratified, notice_status,
           realized_sens, sens_hop_refused, fallback_ioc >>

Runnable(n) ==
    /\ status[n] = "Pending"
    /\ \A d \in Deps(n) : status[d] = "Done"

\* --------------------------------------------------------------------------
\* The fail-closed remediation-gate decision (the floor lives here).
\* AUTHORIZED requires ALL of: sealed custody, a present non-LLM corroboration,
\* a present dissent record, a two-ACTOR countersign, and a RECONCILED epistemic
\* loop. Any absence, any single-actor countersign, an EXHAUSTED loop => BLOCKED.
\* Absence refuses; it never default-allows.
\* --------------------------------------------------------------------------
GateDecision(cust, corr, dis, cs, rv) ==
    IF /\ cust = "sealed"
       /\ corr = "present"
       /\ dis  = "present"
       /\ cs   = "two_actor"
       /\ rv   = "RECONCILED"
        THEN "AUTHORIZED"
        ELSE "BLOCKED"

\* The per-regime notice decision (RatifiedClassificationBeforeNotice, fail-closed).
\* A notice DRAFTS only when its regime's human ratification attested all three
\* fields (modelled as ratified[g] = TRUE). Otherwise it does NOT silently vanish:
\* it is ESCALATED — a recorded, accounted miss, never an undrafted void. This is
\* the mechanism behind NoSilentClockMiss (a miss becomes a recorded miss).
NoticeDecision(rat) == IF rat THEN "drafted" ELSE "escalated"

\* ==========================================================================
\* Init
\* ==========================================================================
Init ==
    /\ delivery       \in { "drill_only", "live" }
    /\ status         = [n \in Nodes |-> "Pending"]
    /\ written        = {}
    /\ custody        = "unsealed"
    /\ disputed       = "open"
    /\ round          = 0
    /\ reconcile_v    = "NONE"
    /\ written_rounds = {}
    /\ corrob         = "absent"
    /\ dissent_rec    = "absent"
    /\ countersign    = "none"
    /\ gate_verdict   = "NONE"
    /\ remediation    = "none"
    /\ actor_caps     = [a \in Actors |-> {}]
    /\ ratified       = [g \in Regimes |-> FALSE]
    /\ notice_status  = [g \in Regimes |-> "undrafted"]
    /\ realized_sens    = "local"
    /\ sens_hop_refused = FALSE
    /\ fallback_ioc     = "none"

\* ==========================================================================
\* Actions
\* ==========================================================================

\* Generic drainage for nodes with no special evidence effect.
PlainRoles ==
    { "trace", "intake", "regime_route", "sensitivity_gate", "evidence_capture",
      "red_reconstruct", "blue_investigate", "second_look",
      "cross_notice_consistency", "verdict", "chronicle" }

ExecutePlain(n) ==
    /\ n.role \in PlainRoles
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, countersign,
                    gate_verdict, remediation, actor_caps, ratified,
                    notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* evidence_preservation_gate — SEALS custody and grants evidence-write to an
\* actor who does NOT already hold production-write (SoD-capability preserved).
ExecutePreservationGate ==
    LET n == Fix("evidence_preservation_gate") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ custody' = "sealed"
    /\ \E a \in Actors :
          /\ "prod" \notin actor_caps[a]        \* guard: never both on one actor
          /\ actor_caps' = [actor_caps EXCEPT ![a] = @ \cup { "ev" }]
    /\ UNCHANGED << delivery, disputed, round, reconcile_v, written_rounds,
                    corrob, dissent_rec, countersign, gate_verdict,
                    remediation, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* confrontation — labels the findings and sets the residual dispute set. It MAY
\* come back with an open dispute (the honest, safe state) or empty (reconciled).
ExecuteConfrontation ==
    LET n == Fix("confrontation") IN
    /\ Runnable(n)
    /\ status'   = [status EXCEPT ![n] = "Done"]
    /\ written'  = written \cup { ArtifactPath(n) }
    /\ disputed' \in { "open", "empty" }
    /\ UNCHANGED << delivery, custody, round, reconcile_v, written_rounds,
                    corrob, dissent_rec, countersign, gate_verdict,
                    remediation, actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* corroboration — the non-LLM out-of-band leg. It MAY be absent (a completed node
\* that produced no independent source is the exact fail-closed case the gate must
\* survive), so the model lets it happen.
ExecuteCorroboration ==
    LET n == Fix("corroboration") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ corrob'  \in { "absent", "present" }
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, dissent_rec, countersign, gate_verdict,
                    remediation, actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* containment_plan — PLAN only. Drains like a plain node but is named separately
\* to state the invariant out loud: it emits a plan, never an action.
ExecuteContainmentPlan ==
    LET n == Fix("containment_plan") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, countersign,
                    gate_verdict, remediation, actor_caps, ratified,
                    notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* dissent — the assigned dissenter. MAY be absent (no devil's advocate emitted),
\* which the gate must refuse on.
ExecuteDissent ==
    LET n == Fix("dissent") IN
    /\ Runnable(n)
    /\ status'      = [status EXCEPT ![n] = "Done"]
    /\ written'     = written \cup { ArtifactPath(n) }
    /\ dissent_rec' \in { "absent", "present" }
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, countersign, gate_verdict,
                    remediation, actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* classification_ratification — the fail-closed human leg. Per regime it MAY
\* attest all three fields (ratified[g] = TRUE) or come back incomplete (FALSE).
ExecuteRatification ==
    LET n == Fix("classification_ratification") IN
    /\ Runnable(n)
    /\ status'   = [status EXCEPT ![n] = "Done"]
    /\ written'  = written \cup { ArtifactPath(n) }
    /\ ratified' \in [ Regimes -> BOOLEAN ]
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, countersign,
                    gate_verdict, remediation, actor_caps, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* notice(g) — drafts ONLY on a complete ratification for its regime (fail-closed).
ExecuteNotice(n) ==
    /\ n.role = NoticeRole
    /\ Runnable(n)
    /\ status'        = [status EXCEPT ![n] = "Done"]
    /\ written'       = written \cup { ArtifactPath(n) }
    /\ notice_status' = [notice_status EXCEPT ![n.regime] =
                            NoticeDecision(ratified[n.regime])]
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, countersign,
                    gate_verdict, remediation, actor_caps, ratified, realized_sens, sens_hop_refused, fallback_ioc >>

\* --------------------------------------------------------------------------
\* The bounded EPISTEMIC re-investigation loop. `re_investigate` is Runnable once
\* confrontation is Done; it iterates rounds 1..MaxRounds, each re-opening the two
\* BLIND lines and re-labelling. It folds to RECONCILED when the disputed set is
\* empty in a round, and to EXHAUSTED at MaxRounds. round = 0 is the
\* `epistemic_rounds = 1` world (folds round 1's own confrontation).
\* --------------------------------------------------------------------------
ReInvestigateRound ==
    LET n == Fix("re_investigate") IN
    /\ Runnable(n)
    /\ round < MaxRounds
    /\ disputed # "empty"                    \* else the loop stops (reconciled)
    /\ round'          = round + 1
    /\ written_rounds' = written_rounds \cup { RoundPath(round + 1) }
    /\ disputed'       \in { "open", "empty" }   \* the round re-labels
    /\ UNCHANGED << delivery, status, written, custody, reconcile_v, corrob,
                    dissent_rec, countersign, gate_verdict, remediation,
                    actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

ReInvestigateReconciled ==
    LET n == Fix("re_investigate") IN
    /\ Runnable(n)
    /\ disputed = "empty"
    /\ status'      = [status EXCEPT ![n] = "Done"]
    /\ written'     = written \cup { ArtifactPath(n) }
    /\ reconcile_v' = "RECONCILED"
    /\ UNCHANGED << delivery, custody, disputed, round, written_rounds, corrob,
                    dissent_rec, countersign, gate_verdict, remediation,
                    actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* Exhaustion — MaxRounds reached with the dispute still open. Folds to EXHAUSTED
\* and NEVER to reconciled; the remediation gate then refuses (block + escalate).
ReInvestigateExhausted ==
    LET n == Fix("re_investigate") IN
    /\ Runnable(n)
    /\ round = MaxRounds
    /\ disputed # "empty"
    /\ status'      = [status EXCEPT ![n] = "Done"]
    /\ written'     = written \cup { ArtifactPath(n) }
    /\ reconcile_v' = "EXHAUSTED"
    /\ UNCHANGED << delivery, custody, disputed, round, written_rounds, corrob,
                    dissent_rec, countersign, gate_verdict, remediation,
                    actor_caps, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* remediation_gate — the fail-closed human countersign. The countersign MAY come
\* back none / single_actor / two_actor (the model explores all three); the
\* decision folds it with the other legs and AUTHORIZES only on the full floor.
\* remediation_gate is the representative RESTRICTED (sensitive) node, so its
\* realized routing is modelled HERE (one transition, no self-loop). Its realized
\* binding stays in-envelope; TLC also explores an attacker-INDUCED fallback, which
\* the model-lock REFUSES (realized_sens stays in-envelope) and records as an IOC.
ExecuteRemediationGate ==
    LET n == Fix("remediation_gate") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ \E cs \in { "none", "single_actor", "two_actor" } :
          /\ countersign'  = cs
          /\ gate_verdict' = GateDecision(custody, corrob, dissent_rec, cs, reconcile_v)
    \* The realized binding on this sensitive node — always in-envelope. TLC
    \* explores both a clean run and an induced-fallback-refused run (the latter
    \* raises the IOC), so RoutingConfinement / ModelLockOnSensitive / FallbackStormIsIOC
    \* are checked over the REALIZED state, incl. the post-fallback one.
    /\ realized_sens' \in { "local", "external_guardrailed" }
    /\ \E induced \in BOOLEAN :
          /\ sens_hop_refused' = induced
          /\ fallback_ioc'     = IF induced THEN "raised" ELSE fallback_ioc
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, remediation,
                    actor_caps, ratified, notice_status >>

\* remediation — the single shot. On an AUTHORIZED gate it acts: `applied` only
\* under delivery=live (a live actuator), `drill` under drill_only. On a BLOCKED
\* gate it REFUSES (stays none) and escalates. Acting grants production-write to an
\* actor who does NOT already hold evidence-write (SoD-capability preserved).
ExecuteRemediation ==
    LET n == Fix("remediation") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ IF gate_verdict = "AUTHORIZED"
          THEN /\ remediation' = IF delivery = "live" THEN "applied" ELSE "drill"
               /\ \E a \in Actors :
                     /\ "ev" \notin actor_caps[a]     \* guard: never both on one actor
                     /\ actor_caps' = [actor_caps EXCEPT ![a] = @ \cup { "prod" }]
          ELSE /\ remediation' = "none"
               /\ UNCHANGED actor_caps
    /\ UNCHANGED << delivery, custody, disputed, round, reconcile_v,
                    written_rounds, corrob, dissent_rec, countersign,
                    gate_verdict, ratified, notice_status, realized_sens, sens_hop_refused, fallback_ioc >>

\* G4 — RoutingConfinement over REALIZED bindings, the fail-closed model-lock on
\* sensitive nodes, and the fallback storm as an IOC, are modelled inside
\* ExecuteRemediationGate (the representative sensitive node) above: a model that
\* REFUSES a legitimate task is NOT a failed step — the call SUCCEEDS and returns
\* polite text — so an attacker can seed guardrail-tripping content to INDUCE a
\* fallback. On the sensitive node the guardrail-free model is LOCKED OUT
\* (fail-closed), and a refused induced-fallback is recorded as an IOC, never
\* silently absorbed.

Next ==
    \/ \E n \in Nodes : ExecutePlain(n)
    \/ \E n \in Nodes : ExecuteNotice(n)
    \/ ExecutePreservationGate
    \/ ExecuteConfrontation
    \/ ExecuteCorroboration
    \/ ExecuteContainmentPlan
    \/ ExecuteDissent
    \/ ExecuteRatification
    \/ ReInvestigateRound
    \/ ReInvestigateReconciled
    \/ ReInvestigateExhausted
    \/ ExecuteRemediationGate
    \/ ExecuteRemediation

Fairness ==
    /\ \A n \in Nodes : WF_vars(ExecutePlain(n))
    /\ \A n \in Nodes : WF_vars(ExecuteNotice(n))
    /\ WF_vars(ExecutePreservationGate)
    /\ WF_vars(ExecuteConfrontation)
    /\ WF_vars(ExecuteCorroboration)
    /\ WF_vars(ExecuteContainmentPlan)
    /\ WF_vars(ExecuteDissent)
    /\ WF_vars(ExecuteRatification)
    /\ WF_vars(ReInvestigateRound)
    /\ WF_vars(ReInvestigateReconciled)
    /\ WF_vars(ReInvestigateExhausted)
    /\ WF_vars(ExecuteRemediationGate)
    /\ WF_vars(ExecuteRemediation)

Spec == Init /\ [][Next]_vars /\ Fairness

\* ==========================================================================
\* TypeOK
\* ==========================================================================
TypeOK ==
    /\ delivery       \in { "drill_only", "live" }
    /\ status         \in [Nodes -> {"Pending","Done"}]
    /\ written        \subseteq { ArtifactPath(n) : n \in Nodes }
    /\ custody        \in { "unsealed", "sealed" }
    /\ disputed       \in { "open", "empty" }
    /\ round          \in 0..MaxRounds
    /\ reconcile_v    \in { "NONE", "RECONCILED", "EXHAUSTED" }
    /\ written_rounds \subseteq { RoundPath(i) : i \in 1..MaxRounds }
    /\ corrob         \in { "absent", "present" }
    /\ dissent_rec    \in { "absent", "present" }
    /\ countersign    \in { "none", "single_actor", "two_actor" }
    /\ gate_verdict   \in { "NONE", "AUTHORIZED", "BLOCKED" }
    /\ remediation    \in { "none", "drill", "applied" }
    /\ actor_caps     \in [Actors -> SUBSET {"ev","prod"}]
    /\ ratified       \in [Regimes -> BOOLEAN]
    /\ notice_status  \in [Regimes -> {"undrafted","drafted","escalated"}]
    /\ realized_sens    \in { "local", "external_guardrailed" }
    /\ sens_hop_refused \in BOOLEAN
    /\ fallback_ioc     \in { "none", "raised" }

\* ==========================================================================
\* Property 1 — Termination (liveness): every node eventually drains to Done.
\* Acyclic DAG + bounded fan-out + a loop bounded by MaxRounds + weak fairness.
\* ==========================================================================
Termination == \A n \in Nodes : <>(status[n] = "Done")

\* ==========================================================================
\* THE FOUR FLOOR PROPERTIES (below which the honest delivery value is drill-only).
\* ==========================================================================

\* P1 — EvidenceBeforeRemediation: no remediation (drill OR applied) while custody
\* is unsealed. The flight-recorder invariant: never touch the wreckage before the
\* recorder is secured.
EvidenceBeforeRemediation ==
    (remediation \in { "drill", "applied" }) => (custody = "sealed")

\* ActionRequiresSealedProvenance: remediation acts only on an AUTHORIZED gate,
\* and (via GateDecision + ArtifactFlow) an AUTHORIZED gate rests on the sealed
\* manifest — no injected byte reaches the actuator around it.
ActionRequiresSealedProvenance ==
    (remediation \in { "drill", "applied" }) => (gate_verdict = "AUTHORIZED")

\* CorroborationBeforeAction: an AUTHORIZED gate implies a PRESENT non-LLM
\* corroboration leg — the irreversible countersign never rests on LLM consensus
\* alone.
CorroborationBeforeAction ==
    (gate_verdict = "AUTHORIZED") => (corrob = "present")

\* TwoLegCountersign: an AUTHORIZED gate implies a two-ACTOR countersign — no
\* single-signer rubber-stamp can promote to action.
TwoLegCountersign ==
    (gate_verdict = "AUTHORIZED") => (countersign = "two_actor")

\* The gate never AUTHORIZES on any absence (fail-closed), and it never AUTHORIZES
\* an EXHAUSTED epistemic loop (block-and-escalate at the ceiling).
GateNeverPromotesOnAbsence ==
    (gate_verdict = "AUTHORIZED") =>
        /\ custody     = "sealed"
        /\ corrob      = "present"
        /\ dissent_rec = "present"
        /\ countersign = "two_actor"
        /\ reconcile_v = "RECONCILED"

\* The drill-only floor: under delivery=drill_only the actuator is NEVER applied to
\* a live estate. `applied` is reachable ONLY under delivery=live.
DrillOnlyFloor ==
    /\ (delivery = "drill_only") => (remediation # "applied")
    /\ (remediation = "applied") => (delivery = "live")

\* ==========================================================================
\* Property — ClassifyBeforeEscalate (structural). Every node that may bind an
\* external-locality provider has the sensitivity gate among its dependencies, so
\* a node can never "leave the building" before it has been classified.
\* ==========================================================================
ClassifyBeforeEscalate ==
    \A n \in Nodes :
        (n.role \in ExternalCapableRoles) =>
            (Fix("sensitivity_gate") \in ReachDeps(n))

\* ==========================================================================
\* Property — RoutingConfinement (envelope form, over REALIZED bindings — G4).
\* The representative sensitive node's ACTUAL realized locality (incl. every
\* post-fallback state TLC explores) lies within its sensitivity-permitted
\* envelope. This is quantified over what the node REALLY ran on, not over the
\* plan — the plan-side declaration is the separate RoutingEnvelopeDeclared below.
\* It is the ENVELOPE form — NOT "N runs only on model C" (which would make the
\* legitimate in-envelope guardrailed fallback a self-inflicted violation).
\* ==========================================================================
RoutingConfinement ==
    realized_sens \in PermittedEnvelope("restricted")

\* Property — RoutingEnvelopeDeclared (the plan-side envelope, CONSTANT). Every
\* locality the plan MAY select for a node lies within that node's envelope —
\* including the guardrail-free fallback, confined OUT of a restricted node's
\* envelope. This is the static half; RoutingConfinement above is the realized half.
RoutingEnvelopeDeclared ==
    \A n \in Nodes :
        RealizableLocalities(n) \subseteq PermittedEnvelope(SensitivityClass(n))

\* Property — ModelLockOnSensitive (fail-closed, G4). The representative sensitive
\* node NEVER realizes the guardrail-free model, EVEN under an attacker-induced
\* fallback — the hop is refused, not merely deprecated. So an attacker who seeds
\* guardrail-tripping content cannot route consequential authorship onto the
\* least-aligned model. (The gate/notice sensitive nodes forbid the fallback in
\* RealizableLocalities too — this is the dynamic, over-realized counterpart.)
ModelLockOnSensitive ==
    realized_sens # "external_free"

\* Property — FallbackStormIsIOC (G4). A refused attacker-induced fallback on a
\* sensitive node is NEVER silently absorbed: it is recorded as an IOC. A refusal
\* is not a failed step (the call succeeded, the machine returned polite text); a
\* burst of them on sensitive nodes is a compromise signal, not a statistic.
FallbackStormIsIOC ==
    sens_hop_refused => (fallback_ioc = "raised")

\* ==========================================================================
\* Property — NoSilentClockMiss (ORDERING, not timeliness). The mission cannot
\* close (verdict Done) while any applicable regime's notice is still undrafted.
\* A miss becomes a recorded, escalated miss — never a vanished one. TLC is
\* untimed: this proves ordering, NEVER that a deadline was met.
\* ==========================================================================
NoSilentClockMiss ==
    (status[Fix("verdict")] = "Done") =>
        (\A g \in Regimes : notice_status[g] # "undrafted")

\* ==========================================================================
\* Property — RatifiedClassificationBeforeNotice (fail-closed). No notice is
\* drafted for a regime whose human ratification did not attest all three fields
\* (classification + risk tier + awareness timestamp, modelled as ratified[g]).
\* ==========================================================================
RatifiedClassificationBeforeNotice ==
    \A g \in Regimes :
        (notice_status[g] = "drafted") => ratified[g]

\* ==========================================================================
\* Property — BlindBeforeConfrontation (structural). The two lines of inquiry are
\* mutually unreachable along blocked-by (nothing to read, not a request not to
\* look), and every confrontation node depends on BOTH. Wiring one line downstream
\* of the other — the "cheap" simplification that silently forges convergence — is
\* a seal VIOLATION.
\* ==========================================================================
ConfrontationRoles == { "confrontation", "re_investigate" }

BlindBeforeConfrontation ==
    /\ Fix("red_reconstruct")  \notin ReachDeps(Fix("blue_investigate"))
    /\ Fix("blue_investigate") \notin ReachDeps(Fix("red_reconstruct"))
    /\ \A n \in Nodes :
         (n.role \in ConfrontationRoles) =>
            /\ Fix("red_reconstruct")  \in ReachDeps(n)
            /\ Fix("blue_investigate") \in ReachDeps(n)

\* ==========================================================================
\* Property — TraceCompleteness. No node completes without emitting its step
\* record (its artifact path). The certified, continuous chain of custody is the
\* product; this promotes its continuity from incidental to proven.
\* ==========================================================================
TraceCompleteness ==
    \A n \in Nodes : (status[n] = "Done") => (ArtifactPath(n) \in written)

\* ==========================================================================
\* Property — SoDCapability. No reachable state grants one actor BOTH
\* evidence-write and production-write. The seal proves separation of CAPABILITY;
\* the static "not the same node" half is a `cs spore validate` check.
\* ==========================================================================
SoDCapability ==
    \A a \in Actors : ~({ "ev", "prod" } \subseteq actor_caps[a])

\* ==========================================================================
\* Property — NoOffensiveArtifact (type-gate, CONSTANT). No node emits an artifact
\* whose TYPE is offensive-playbook or attack-procedure. The red line on the
\* emission-TYPE axis (Directive 2013/40/EU Art. 7 teeth). It does NOT close the
\* knowledge-reproduction axis — that is the unsealed content discipline (README).
\* ==========================================================================
NoOffensiveArtifact ==
    \A n \in Nodes : ArtifactType(n) \notin ForbiddenTypes

\* ==========================================================================
\* Property — NoResourceCollision. No two distinct Done nodes, and no two loop
\* rounds, write the same artifact path.
\* ==========================================================================
NoResourceCollision ==
    /\ \A m, n \in Nodes :
          (m # n /\ status[m] = "Done" /\ status[n] = "Done")
              => ArtifactPath(m) # ArtifactPath(n)
    /\ \A i, j \in 1..MaxRounds : (i # j) => RoundPath(i) # RoundPath(j)
    /\ \A i \in 1..MaxRounds : \A n \in Nodes : RoundPath(i) # ArtifactPath(n)

\* ==========================================================================
\* Property — DeterministicParametrization. The node set is a pure function of the
\* params: |Nodes| = 20 fixed + |Regimes| notice sinks. `epistemic_rounds` bounds
\* the loop counter and NEVER multiplies the node set.
\* ==========================================================================
ExpandedNodes ==
    { Fix(r) : r \in FixedRoles } \cup { Not(g) : g \in Regimes }

DeterministicParametrization ==
    /\ Nodes = ExpandedNodes
    /\ Cardinality(Nodes) = Cardinality(FixedRoles) + Cardinality(Regimes)
    /\ round <= MaxRounds

\* ==========================================================================
\* Property — ArtifactFlow (CONSTANT over structure). Every artifact a node
\* REQUIRES is PRODUCED by some node strictly upstream along blocked-by order.
\* This is what makes "the actuator gate acts without the sealed manifest upstream"
\* a seal VIOLATION rather than a silent deadlock.
\* ==========================================================================
ArtifactFlow ==
    \A n \in Nodes : Requires(n) \subseteq ProducedUpstream(n)

\* ==========================================================================
\* Bundled invariant (the safety set; Termination is a temporal PROPERTY).
\* ==========================================================================
SealInvariant ==
    /\ TypeOK
    /\ EvidenceBeforeRemediation
    /\ ActionRequiresSealedProvenance
    /\ CorroborationBeforeAction
    /\ TwoLegCountersign
    /\ GateNeverPromotesOnAbsence
    /\ DrillOnlyFloor
    /\ ClassifyBeforeEscalate
    /\ RoutingConfinement
    /\ RoutingEnvelopeDeclared
    /\ ModelLockOnSensitive
    /\ FallbackStormIsIOC
    /\ NoSilentClockMiss
    /\ RatifiedClassificationBeforeNotice
    /\ BlindBeforeConfrontation
    /\ TraceCompleteness
    /\ SoDCapability
    /\ NoOffensiveArtifact
    /\ NoResourceCollision
    /\ DeterministicParametrization
    /\ ArtifactFlow

=============================================================================

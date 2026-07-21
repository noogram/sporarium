-------------------------------- MODULE spore --------------------------------
\* ==========================================================================
\* spore.tla — the TLC-checked seal for the `math-attack` spore.
\*
\* WHAT THIS MODULE IS
\*   A spore declares a `[spore.seal]` that NAMES safety properties of the whole
\*   polymer it germinates. An earlier shipment declared that block but did not
\*   check it, so `cs spore run` refused unless the operator passed
\*   `--allow-unchecked-seal`.
\*   This module is the mechanical proof the seal was standing in for: it models
\*   the germinated DAG's gate semantics and lets TLC discharge the five
\*   properties the seal claims. Once TLC is green, a development-branch
\*   `cs spore run` reports `seal: verified <hash>` and the flag is no longer
\*   needed; the released `cs` reports "TLC unavailable" and germinates with
\*   `--allow-unchecked-seal` (see README §0/§2).
\*
\* WHAT IS MODELLED
\*   * the DAG shape — 15 fixed nodes + a 2-node fan-out (proof-attempt ||
\*     notebooks) over the `subquestions` param + an OPTIONAL 3-node
\*     instrumentation chain (collector -> dataviz -> narrator) fanned out over
\*     the `observability` gate param (empty => germinates nothing) — as a finite
\*     set of nodes with a dependency (blocked-by) relation lifted from spore.toml.
\*     The 15 fixed nodes include the always-on `trace` root+leaf (v3.2) and
\*     the SPLIT gates evidence_gate (pre-synthesis) + citation_gate (post-write)
\*     from the v3.2 gate-split repair;
\*   * node drainage — a Pending node executes once every dependency is Done;
\*   * the SPLIT gate legs — evidence_gate's kernel + skeptic legs (pre-synthesis)
\*     and citation_gate's citation leg (post-write), plus the editorial verdict
\*     over both, each reading evidence that MAY be absent;
\*   * artifact writes — each node writes one path; fan-out paths carry the
\*     subquestion index (the load-bearing detail NoResourceCollision guards);
\*   * artifact FLOW — a Produces/Requires map per node (v3.2), so ArtifactFlow
\*     can assert every required artifact has an upstream producer.
\*
\* WHAT IS NOT MODELLED (honest boundary)
\*   * proof/prose CONTENT (Rice: truth of a string is undecidable) — the model
\*     tracks only whether a mechanical verdict is PRESENT and what it says;
\*   * LLM agent semantics (a non-deterministic oracle beyond TLA+'s reach) —
\*     abstracted as the non-deterministic choice of each leg's verdict;
\*   * filesystem races / worktree lifecycle (worktree isolation is assumed, and
\*     is exactly what makes the static path-injectivity argument sound).
\*
\* THE FIVE PROPERTIES (the seal's `properties = [...]`)
\*   Termination                 — every germinated polymer drains: every node
\*                                 eventually reaches Done. The DAG is acyclic and
\*                                 the fan-out is bounded by a param list, so no
\*                                 unbounded foaming and no cycle.
\*   GateFailClosed  (LOAD-BEARING) — the absence of a kernel/skeptic verdict
\*                                 REFUSES the evidence gate, and an absent
\*                                 citation verdict REFUSES the citation gate;
\*                                 SHIP requires BOTH promoting. No leg silently
\*                                 degrades to "pass".
\*   NoResourceCollision         — no two nodes write the same artifact path (the
\*                                 fan-out index makes proof-attempt-1 disjoint
\*                                 from proof-attempt-2).
\*   DeterministicParametrization — the same params yield the same expansion: the
\*                                 node set is a pure function of `subquestions`
\*                                 and `observability`, with cardinality
\*                                 15 + 2*|subquestions| + 3*|observability|.
\*   ArtifactFlow (v3.2)          — every artifact a node REQUIRES has an upstream
\*                                 node that PRODUCES it. The gate-split bug (citation
\*                                 audit requiring a paper produced downstream)
\*                                 VIOLATES this; the split gate satisfies it.
\*
\* Modeled as a bounded finite-state pipeline (drainage to an absorbing
\* terminal state). Launch command and expected verdict live in spore.cfg and
\* README.md §10.
\* ==========================================================================

EXTENDS Naturals, Sequences, FiniteSets, TLC

CONSTANTS
    Subquestions,   \* the `subquestions` fan-out param: a finite, NON-EMPTY set
    Observability,  \* the `observability` gate param: a finite set that MAY be
                    \* EMPTY (off => the instrumentation sub-DAG germinates nothing)
    NULL            \* model value for "no subquestion" on a fixed node

\* A fan-out over an empty param list is a typo, not an intention:
\* the spore parser rejects it, and the model refuses to reason about it.
ASSUME Subquestions # {}
\* Observability is the on/off gate for the OPTIONAL instrumentation sub-DAG.
\* It MAY be empty (the default `off`): an empty fan-out list emits zero calls, so
\* the collector/dataviz/narrator nodes simply do not exist. The model therefore
\* imposes NO non-emptiness assumption on it — the off case is a first-class world.
\* NULL is a distinguished value, never a real subquestion or observability stage
\* (so a fixed node's sq never collides with a fan-out instance's sq).
ASSUME NULL \notin Subquestions
ASSUME NULL \notin Observability

\* The `formal_backend` param is modelled NON-DETERMINISTICALLY (a state var
\* chosen at Init from {"lean","none"}) so ONE model covers both worlds: the
\* real kernel leg (backend="lean" => evidence PASS reachable) AND the honest degrade
\* (backend="none" => kernel leg DEGRADED, seal rests on skeptic + citation).

\* --------------------------------------------------------------------------
\* Node identities — the expansion of the DAG (DeterministicParametrization).
\* A node is [role, sq]; fixed nodes carry sq = NULL, fan-out nodes carry a real
\* subquestion. FixedRoles / FanoutRoles are the declaration-order roles of
\* spore.toml's [[spore.node]] blocks.
\* --------------------------------------------------------------------------
FixedRoles ==
    { "trace", "decompose", "frame_deliberation", "source_ledger",
      "concept_cards", "skeptic", "lean_skeleton", "lean_probe",
      "red_team_corpus", "evidence_gate", "synthesize", "write_paper",
      "citation_gate", "editorial_verdict", "chronicle" }

\* Two fan-out DIMENSIONS. The informal branch fans out over `subquestions`; the
\* OPTIONAL instrumentation sub-DAG fans out over `observability` (empty => none).
SqFanoutRoles  == { "proof_attempt", "notebooks" }
ObsFanoutRoles == { "collector", "dataviz", "narrator" }

Fix(r) == [role |-> r, sq |-> NULL]
PA(s)   == [role |-> "proof_attempt", sq |-> s]
NB(s)   == [role |-> "notebooks",     sq |-> s]
CO(o)   == [role |-> "collector",     sq |-> o]
DV(o)   == [role |-> "dataviz",       sq |-> o]
NA(o)   == [role |-> "narrator",      sq |-> o]

\* The germinated node set — a PURE function of the params. This IS the
\* expansion; DeterministicParametrization asserts nothing environmental ever
\* perturbs it. When Observability = {} the third set is empty, so the
\* instrumentation nodes germinate nothing (the honest `off` degradation).
Nodes ==
    { Fix(r) : r \in FixedRoles }
      \cup { [role |-> r, sq |-> s] : r \in SqFanoutRoles,  s \in Subquestions }
      \cup { [role |-> r, sq |-> o] : r \in ObsFanoutRoles, o \in Observability }

\* --------------------------------------------------------------------------
\* Dependency relation — the blocked-by edges of spore.toml, verbatim.
\* PARALLEL FORMAL BRANCH (v2, parallel-branch topology): the Lean anchor forks from
\* concept_cards IN PARALLEL with the informal branch, so the fidelity anchor
\* (`theorem … := by sorry`) is pinned WHILE the informal proof is being
\* written — statement drift can no longer creep in during the skeptic loop.
\* The two branches converge at evidence_gate (v3.2 split gate; the citation audit
\* moved downstream to citation_gate, after write_paper).
\*   decompose -> frame_deliberation -> source_ledger -> concept_cards
\*     concept_cards -> [ proof_attempt(s) || notebooks(s) ] -> skeptic    (informal)
\*     concept_cards -> lean_skeleton -> [ lean_probe || red_team_corpus ] (formal)
\*   { skeptic, lean_probe, red_team_corpus } -> evidence_gate            (converge)
\*     evidence_gate -> synthesize -> write_paper -> citation_gate
\*                   -> editorial_verdict -> chronicle
\* --------------------------------------------------------------------------
Deps(n) ==
    \* trace is a ROOT+LEAF: no dependency (runnable at germination, before the
    \* first scientific tackle) and nothing depends on it (v3.2 — the
    \* always-on sidecar survives a downstream stall).
    CASE n.role = "trace"              -> {}
      [] n.role = "decompose"          -> {}
      [] n.role = "frame_deliberation" -> { Fix("decompose") }
      [] n.role = "source_ledger"      -> { Fix("frame_deliberation") }
      [] n.role = "concept_cards"      -> { Fix("source_ledger") }
      [] n.role = "proof_attempt"     -> { Fix("concept_cards") }
      [] n.role = "notebooks"         -> { Fix("concept_cards") }
      [] n.role = "skeptic"           -> { PA(s) : s \in Subquestions }
                                            \cup { NB(s) : s \in Subquestions }
      [] n.role = "lean_skeleton"     -> { Fix("concept_cards") }
      [] n.role = "lean_probe"        -> { Fix("lean_skeleton") }
      [] n.role = "red_team_corpus"   -> { Fix("lean_skeleton") }
      \* v3.2 split gate: evidence_gate (pre-synthesis, kernel+skeptic legs over
      \* existing artifacts) and citation_gate (post-write, the citation audit
      \* over the paper that now exists).
      [] n.role = "evidence_gate"     -> { Fix("skeptic"), Fix("lean_probe"),
                                           Fix("red_team_corpus") }
      [] n.role = "synthesize"        -> { Fix("evidence_gate") }
      [] n.role = "write_paper"       -> { Fix("synthesize") }
      [] n.role = "citation_gate"     -> { Fix("write_paper") }
      [] n.role = "editorial_verdict" -> { Fix("citation_gate") }
      [] n.role = "chronicle"         -> { Fix("editorial_verdict") }
      \* Instrumentation sub-DAG (present only when Observability # {}). Rooted
      \* at chronicle so it observes the fully drained attack DAG; each stage
      \* blocked-by ALL instances of the previous stage (the spore's fan-out ->
      \* fan-out edge semantics, mirroring how skeptic waits on all of PA/NB).
      [] n.role = "collector"         -> { Fix("chronicle") }
      [] n.role = "dataviz"           -> { CO(o) : o \in Observability }
      [] n.role = "narrator"          -> { DV(o) : o \in Observability }

\* Artifact path each node writes. Fan-out nodes MUST carry their subquestion in
\* the path — that suffix is exactly what keeps parallel writers disjoint. Drop
\* it and NoResourceCollision fails (its teeth).
ArtifactPath(n) ==
    IF n.sq = NULL THEN n.role ELSE n.role \o "-" \o n.sq

\* --------------------------------------------------------------------------
\* Produces / Requires — the artifact-flow map (v3.2). Each node PRODUCES a
\* set of artifact KEYS and REQUIRES a set of upstream keys. These are logical
\* keys (role-level), distinct from ArtifactPath (which carries the fan-out index
\* for NoResourceCollision). ArtifactFlow (below) then asserts every required key
\* has a PRODUCER somewhere upstream along blocked-by order — the property that
\* makes the old gate-split bug (a citation audit REQUIRING "paper" while the paper is
\* produced DOWNSTREAM) a seal VIOLATION rather than a silent runtime deadlock.
\* --------------------------------------------------------------------------
Produces(n) ==
    CASE n.role = "trace"              -> { "trace_sidecar" }
      [] n.role = "decompose"          -> { "decompose_md" }
      [] n.role = "frame_deliberation" -> { "frame_outcomes" }
      [] n.role = "source_ledger"      -> { "source_ledger_md" }
      [] n.role = "concept_cards"      -> { "concept_cards" }
      [] n.role = "proof_attempt"      -> { "proof_attempt" }
      [] n.role = "notebooks"          -> { "notebooks" }
      [] n.role = "skeptic"            -> { "faults_md" }
      [] n.role = "lean_skeleton"      -> { "lean_skeleton" }
      [] n.role = "lean_probe"         -> { "lean_probe_report" }
      [] n.role = "red_team_corpus"    -> { "corpus" }
      [] n.role = "evidence_gate"      -> { "evidence_verdict" }
      [] n.role = "synthesize"         -> { "synthesis" }
      [] n.role = "write_paper"        -> { "paper" }
      [] n.role = "citation_gate"      -> { "verification_report" }
      [] n.role = "editorial_verdict"  -> { "editorial_verdict_md" }
      [] n.role = "chronicle"          -> { "chronicle_md" }
      [] n.role = "collector"          -> { "report_data" }
      [] n.role = "dataviz"            -> { "report_figures" }
      [] n.role = "narrator"           -> { "report_md" }

Requires(n) ==
    CASE n.role = "trace"              -> {}   \* reads live cosmon state, not a DAG artifact
      [] n.role = "decompose"          -> {}
      [] n.role = "frame_deliberation" -> { "decompose_md" }
      [] n.role = "source_ledger"      -> { "frame_outcomes" }
      [] n.role = "concept_cards"      -> { "decompose_md", "source_ledger_md" }
      [] n.role = "proof_attempt"      -> { "concept_cards", "source_ledger_md" }
      [] n.role = "notebooks"          -> { "concept_cards" }
      [] n.role = "skeptic"            -> { "proof_attempt", "notebooks" }
      [] n.role = "lean_skeleton"      -> { "concept_cards" }
      [] n.role = "lean_probe"         -> { "lean_skeleton" }
      [] n.role = "red_team_corpus"    -> { "lean_skeleton" }
      \* the pre-synthesis gate reads ONLY evidence that already exists — NOT the
      \* paper (that is the whole point of the gate split).
      [] n.role = "evidence_gate"      -> { "faults_md", "lean_probe_report", "corpus" }
      [] n.role = "synthesize"         -> { "evidence_verdict", "proof_attempt",
                                            "notebooks", "faults_md",
                                            "lean_probe_report" }
      [] n.role = "write_paper"        -> { "synthesis" }
      \* the citation gate REQUIRES "paper" — and write_paper (its upstream
      \* dependency) PRODUCES it. In the OLD design the audit required "paper"
      \* while the paper's producer was downstream: ArtifactFlow would REJECT it.
      [] n.role = "citation_gate"      -> { "paper", "source_ledger_md" }
      [] n.role = "editorial_verdict"  -> { "paper", "evidence_verdict",
                                            "verification_report" }
      [] n.role = "chronicle"          -> { "editorial_verdict_md" }
      [] n.role = "collector"          -> {}   \* reads live cosmon state
      [] n.role = "dataviz"            -> { "report_data" }
      [] n.role = "narrator"           -> { "report_figures" }

\* Transitive dependency closure (the acyclic DAG makes this well-founded).
RECURSIVE ReachDeps(_)
ReachDeps(n) == Deps(n) \cup UNION { ReachDeps(d) : d \in Deps(n) }

\* Every artifact key produced by some strict-upstream node of n.
ProducedUpstream(n) == UNION { Produces(m) : m \in ReachDeps(n) }

\* ==========================================================================
\* State
\* ==========================================================================
VARIABLES
    backend,           \* "lean" | "none"  (the formal_backend param, fixed at Init)
    status,            \* [Nodes -> {"Pending", "Done"}]  node drainage
    written,           \* SUBSET of artifact paths already written (collision witness)
    kernel_leg,        \* "absent" | "pass" | "fail" | "degraded"  (Lean kernel verdict)
    citation_leg,      \* "absent" | "pass" | "fail"               (citation audit, at citation_gate)
    skeptic_leg,       \* "absent" | "clean" | "blockers"          (residual BLOCKERs)
    evidence_verdict,  \* "NONE" | "PASS" | "DEGRADED" | "BLOCKED"  (evidence_gate, pre-synthesis)
    citation_verdict,  \* "NONE" | "PASS" | "BLOCKED"               (citation_gate, post-write)
    editorial          \* "NONE" | "SHIP" | "REWRITE"

vars == << backend, status, written, kernel_leg, citation_leg,
           skeptic_leg, evidence_verdict, citation_verdict, editorial >>

\* A node is runnable when it is still Pending and every dependency is Done.
Runnable(n) ==
    /\ status[n] = "Pending"
    /\ \A d \in Deps(n) : status[d] = "Done"

\* --------------------------------------------------------------------------
\* v3.2 SPLIT GATE — two fail-closed gate decisions (GateFailClosed lives here).
\*
\* EvidenceDecision (evidence_gate, PRE-synthesis) folds the KERNEL and SKEPTIC
\* legs over evidence that already exists — NOT the citation leg (no paper yet).
\* Absence of a leg refuses; a failing leg refuses; a degraded (backend=none)
\* kernel leg can at best DEGRADE, and only if the skeptic leg is clean. PASS
\* requires both present-and-passing.
\* --------------------------------------------------------------------------
EvidenceDecision(k, sk) ==
    IF k = "absent" \/ sk = "absent"
        THEN "BLOCKED"                                  \* fail-closed on absence
    ELSE IF k = "fail" \/ sk = "blockers"
        THEN "BLOCKED"                                  \* fail-closed on a failing leg
    ELSE IF k = "degraded"
        THEN IF sk = "clean" THEN "DEGRADED" ELSE "BLOCKED"
    ELSE "PASS"                                         \* kernel pass + skeptic clean

\* CitationDecision (citation_gate, POST-write) folds the single citation leg,
\* audited over the paper that write_paper has now produced. Absent or failing
\* audit refuses.
CitationDecision(c) ==
    IF c = "absent" \/ c = "fail" THEN "BLOCKED" ELSE "PASS"

\* The editorial gate — SHIP only when BOTH split gates established a promoting
\* verdict (evidence PASS/DEGRADED and citation PASS); any absence => REWRITE.
EditorialDecision(ev, cv) ==
    IF ev \in {"PASS", "DEGRADED"} /\ cv = "PASS" THEN "SHIP" ELSE "REWRITE"

\* ==========================================================================
\* Init
\* ==========================================================================
Init ==
    /\ backend          \in {"lean", "none"}
    /\ status           = [n \in Nodes |-> "Pending"]
    /\ written          = {}
    /\ kernel_leg       = "absent"
    /\ citation_leg     = "absent"
    /\ skeptic_leg      = "absent"
    /\ evidence_verdict = "NONE"
    /\ citation_verdict = "NONE"
    /\ editorial        = "NONE"

\* ==========================================================================
\* Actions
\* ==========================================================================

\* Generic drainage: any runnable node whose execution has no special evidence
\* effect just goes Done and records its write. The evidence-producing nodes
\* (skeptic, lean_probe, evidence_gate, citation_gate) and the editorial node
\* have their own actions below.
PlainRoles ==
    { "trace",
      "decompose", "frame_deliberation", "source_ledger", "concept_cards",
      "proof_attempt", "notebooks", "lean_skeleton", "red_team_corpus",
      "synthesize", "write_paper", "chronicle",
      \* the instrumentation sub-DAG is read-only reporting: it drains like any
      \* plain node and touches none of the seal legs.
      "collector", "dataviz", "narrator" }

ExecutePlain(n) ==
    /\ n.role \in PlainRoles
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ UNCHANGED << backend, kernel_leg, citation_leg, skeptic_leg,
                    evidence_verdict, citation_verdict, editorial >>

\* skeptic — emits a residual-BLOCKER verdict. It MAY come back empty-handed
\* (absent): a completed node that produced no verdict is the exact silent-degrade
\* failure mode the gate must survive, so the model lets it happen.
ExecuteSkeptic ==
    LET n == Fix("skeptic") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ skeptic_leg' \in {"clean", "blockers", "absent"}
    /\ UNCHANGED << backend, kernel_leg, citation_leg,
                    evidence_verdict, citation_verdict, editorial >>

\* lean_probe — the kernel leg. Under backend="lean" the mechanical verdict is
\* genuinely non-deterministic — pass / fail / absent (a build that never ran) —
\* so TLC explores all three; under backend="none" the leg is honestly DEGRADED,
\* never silently "pass".
ExecuteLeanProbe ==
    LET n == Fix("lean_probe") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ IF backend = "none"
          THEN kernel_leg' = "degraded"
          ELSE kernel_leg' \in {"pass", "fail", "absent"}
    /\ UNCHANGED << backend, citation_leg, skeptic_leg,
                    evidence_verdict, citation_verdict, editorial >>

\* evidence_gate (v3.2 split gate, PRE-synthesis) — folds the KERNEL and SKEPTIC legs
\* over existing evidence into the fail-closed evidence verdict. NO citation
\* audit here (the paper does not exist yet). This is where the first half of
\* GateFailClosed lives.
ExecuteEvidenceGate ==
    LET n == Fix("evidence_gate") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ evidence_verdict' = EvidenceDecision(kernel_leg, skeptic_leg)
    /\ UNCHANGED << backend, kernel_leg, citation_leg, skeptic_leg,
                    citation_verdict, editorial >>

\* citation_gate (v3.2 split gate, POST-write) — runs the citation audit over the paper
\* (which write_paper has produced upstream; MAY be absent) and folds it into the
\* fail-closed citation verdict. The second half of GateFailClosed.
ExecuteCitationGate ==
    LET n == Fix("citation_gate") IN
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }
    /\ \E c \in {"pass", "fail", "absent"} :
          /\ citation_leg' = c
          /\ citation_verdict' = CitationDecision(c)
    /\ UNCHANGED << backend, kernel_leg, skeptic_leg, evidence_verdict, editorial >>

\* editorial_verdict — the fail-closed SHIP/REWRITE gate over BOTH split gates.
ExecuteEditorial ==
    LET n == Fix("editorial_verdict") IN
    /\ Runnable(n)
    /\ status'   = [status EXCEPT ![n] = "Done"]
    /\ written'  = written \cup { ArtifactPath(n) }
    /\ editorial' = EditorialDecision(evidence_verdict, citation_verdict)
    /\ UNCHANGED << backend, kernel_leg, citation_leg, skeptic_leg,
                    evidence_verdict, citation_verdict >>

Next ==
    \/ \E n \in Nodes : ExecutePlain(n)
    \/ ExecuteSkeptic
    \/ ExecuteLeanProbe
    \/ ExecuteEvidenceGate
    \/ ExecuteCitationGate
    \/ ExecuteEditorial

\* Weak fairness on every node's execution so drainage is guaranteed (liveness).
Fairness ==
    /\ \A n \in Nodes : WF_vars(ExecutePlain(n))
    /\ WF_vars(ExecuteSkeptic)
    /\ WF_vars(ExecuteLeanProbe)
    /\ WF_vars(ExecuteEvidenceGate)
    /\ WF_vars(ExecuteCitationGate)
    /\ WF_vars(ExecuteEditorial)

Spec == Init /\ [][Next]_vars /\ Fairness

\* ==========================================================================
\* TypeOK
\* ==========================================================================
TypeOK ==
    /\ backend          \in {"lean", "none"}
    /\ status           \in [Nodes -> {"Pending", "Done"}]
    /\ written          \subseteq { ArtifactPath(n) : n \in Nodes }
    /\ kernel_leg       \in {"absent", "pass", "fail", "degraded"}
    /\ citation_leg     \in {"absent", "pass", "fail"}
    /\ skeptic_leg      \in {"absent", "clean", "blockers"}
    /\ evidence_verdict \in {"NONE", "PASS", "DEGRADED", "BLOCKED"}
    /\ citation_verdict \in {"NONE", "PASS", "BLOCKED"}
    /\ editorial        \in {"NONE", "SHIP", "REWRITE"}

\* ==========================================================================
\* Property 1 — Termination (liveness): every node eventually drains to Done.
\* Acyclic DAG + bounded fan-out + weak fairness => no cycle, no spin.
\* ==========================================================================
Termination ==
    \A n \in Nodes : <>(status[n] = "Done")

\* ==========================================================================
\* Property 2 — GateFailClosed (LOAD-BEARING, safety). The gate never promotes
\* on absent or failing evidence.
\* ==========================================================================
\* (a) evidence PASS implies the kernel + skeptic legs present AND passing.
EvidencePassImpliesLegs ==
    (evidence_verdict = "PASS") =>
        /\ kernel_leg  = "pass"
        /\ skeptic_leg = "clean"

\* (b) citation PASS implies the citation leg present AND passing.
CitationPassImpliesLeg ==
    (citation_verdict = "PASS") => citation_leg = "pass"

\* (c) The load-bearing negatives: an absent kernel/skeptic can never yield a
\* promoting evidence verdict; an absent citation leg can never yield a promoting
\* citation verdict. Absence refuses, always (fail-closed).
AbsentEvidenceNeverPromotes ==
    (kernel_leg = "absent" \/ skeptic_leg = "absent")
        => evidence_verdict \in {"NONE", "BLOCKED"}

AbsentCitationNeverPromotes ==
    (citation_leg = "absent") => citation_verdict \in {"NONE", "BLOCKED"}

\* (d) The editorial gate never SHIPs unless BOTH split gates established a
\* promoting verdict (evidence PASS/DEGRADED and citation PASS).
ShipImpliesGatesEstablished ==
    (editorial = "SHIP") =>
        /\ evidence_verdict \in {"PASS", "DEGRADED"}
        /\ citation_verdict = "PASS"

GateFailClosed ==
    /\ EvidencePassImpliesLegs
    /\ CitationPassImpliesLeg
    /\ AbsentEvidenceNeverPromotes
    /\ AbsentCitationNeverPromotes
    /\ ShipImpliesGatesEstablished

\* ==========================================================================
\* Property 3 — NoResourceCollision (safety): no two distinct Done nodes have
\* written the same artifact path. The fan-out suffix is what keeps this true.
\* ==========================================================================
NoResourceCollision ==
    \A m, n \in Nodes :
        (m # n /\ status[m] = "Done" /\ status[n] = "Done")
            => ArtifactPath(m) # ArtifactPath(n)

\* ==========================================================================
\* Property 4 — DeterministicParametrization (safety): the expansion is a pure
\* function of the params. The node set equals its pure-function image at all
\* times (germination is one-shot, not environment-perturbed), and both fan-outs
\* are bounded: |Nodes| = 15 fixed + 2 per subquestion + 3 per observability
\* stage (0 when observability is off — the instrumentation sub-DAG vanishes).
\* ==========================================================================
ExpandedNodes ==
    { Fix(r) : r \in FixedRoles }
      \cup { [role |-> r, sq |-> s] : r \in SqFanoutRoles,  s \in Subquestions }
      \cup { [role |-> r, sq |-> o] : r \in ObsFanoutRoles, o \in Observability }

DeterministicParametrization ==
    /\ Nodes = ExpandedNodes
    /\ Cardinality(Nodes)
         = Cardinality(FixedRoles)
           + Cardinality(SqFanoutRoles)  * Cardinality(Subquestions)
           + Cardinality(ObsFanoutRoles) * Cardinality(Observability)

\* ==========================================================================
\* Property 5 — ArtifactFlow (v3.2, safety over the STATIC structure): every
\* artifact a node REQUIRES is PRODUCED by some node strictly upstream of it along
\* the blocked-by order. This is a constant property (params-only, state-
\* independent); it holds by construction and is checked in every state. It is the
\* property that makes a gate-flow bug a seal VIOLATION: the old seal-gate REQUIRED
\* "paper" while the paper's producer (write_paper) was DOWNSTREAM, so
\* "paper" \notin ProducedUpstream(old single-gate) and this invariant would fail.
\* The v3.2 split moves the citation audit (citation_gate) BELOW write_paper, so
\* "paper" \in ProducedUpstream(citation_gate) and the invariant holds.
\* ==========================================================================
ArtifactFlow ==
    \A n \in Nodes : Requires(n) \subseteq ProducedUpstream(n)

\* ==========================================================================
\* Bundled invariant (the safety set; Termination is a temporal PROPERTY).
\* ==========================================================================
SealInvariant ==
    /\ TypeOK
    /\ GateFailClosed
    /\ NoResourceCollision
    /\ DeterministicParametrization
    /\ ArtifactFlow

=============================================================================

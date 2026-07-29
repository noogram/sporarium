# `crisis-response` — validation record

Honest record of the checks run against this package at authoring time. A failure
reported here is worth more than a success invented.

**Host:** darwin (Apple Silicon). **`cs` version:** 0.4.0 (cfa27a90, built
2026-07-29). **JVM/TLC:** OpenJDK 21.0.11 via Homebrew + `tla2tools.jar` from the
cosmon repo (`docs/specs/tla2tools.jar`). **Date:** 2026-07-29.

---

## 1. `cs spore validate` — parse + expand (PASS)

```
cs spore validate spores/crisis-response/spore.toml \
    --var incident="incident-alpha" \
    --var incident_report="Anomalous outbound traffic; first signal at T0."
```

- **Result:** `spore: crisis-response (v1) - 22 call(s)` · `seal: present, NOT verified` · **exit 0**.
- **Call count 22 = 20 fixed nodes + 2 notice sinks** (`regimes = [dora, rgpd]`),
  matching the seal's `DeterministicParametrization` (`|Nodes| = 20 + |regimes|`).
- The `re-investigate` emergent node nucleates nothing at `epistemic_rounds = 1`
  (the default), as designed.
- Every node's `blocked-by` reproduced the declared DAG; every `${params.*}`
  interpolated into the germinated briefs.

**Rich parameter set** (non-financial entity, 3 epistemic rounds, live delivery,
pre-provisioned holders):

```
cs spore validate … --var entity_scope="essential-nis2" --var regimes="nis2,rgpd" \
    --var epistemic_rounds="3" --var delivery="live" \
    --var escrow_holders="client-ir,provider,external-counsel"
```

- **Result:** `22 call(s)`, **exit 0**. Fan-out re-indexed correctly to the NIS2 +
  RGPD sinks; the live-delivery / escrow params interpolated into the preservation
  gate and ratification briefs.

> `cs spore validate` does not itself enforce the DORA-over-NIS2 well-formedness
> expectation (that `regimes` must not contain both `dora` and `nis2`); that is
> declared in the param descriptions and the `regime-route` brief, and is the one
> cross-param rule a future `validate` rule could add. Not a blocker for this
> package — documented, not silently assumed.

## 2. Seal — TLC model check (PASS, GREEN)

```
export TLA2TOOLS_JAR=…/cosmon/docs/specs/tla2tools.jar
/opt/homebrew/opt/openjdk@21/bin/java -XX:+UseParallelGC -cp "$TLA2TOOLS_JAR" \
    tlc2.TLC -workers auto -config spore.cfg spore.tla
```

- **Result:** **"Model checking completed. No error has been found."**
- **122204 distinct states** (319584 generated), **depth 26**.
- **Timing depends entirely on the invocation, and the two numbers are far
  apart — budget for the slower one.** `-workers auto -XX:+UseParallelGC` (the
  command above): **~2 min 44 s** on 16 cores. **`cs spore run` invokes TLC
  single-worker** (`java -cp tla2tools.jar tlc2.TLC -config … …`, no `-workers`):
  **~27 min** on the same machine, with **no output at all** for the whole
  duration, because cosmon does not pass TLC's progress through. Measured on a
  recipient-side acceptance run, 2026-07-29. If you verify by hand, use the
  command above; if you let `cs spore run` do it, expect a long silence and do
  not take it for a hang.
- Figures below were measured with the parallel invocation (with
  the G4 realized-routing / model-lock / fallback-IOC properties; an earlier cut
  without them was 47324 distinct / depth 26).
- All 21 named properties hold — 20 safety invariants conjoined into
  `SealInvariant`, plus the liveness property `Termination`:
  `EvidenceBeforeRemediation`,
  `ActionRequiresSealedProvenance`, `CorroborationBeforeAction`,
  `TwoLegCountersign`, `GateNeverPromotesOnAbsence`, `DrillOnlyFloor`,
  `ClassifyBeforeEscalate`, `RoutingConfinement` (over
  realized bindings), `RoutingEnvelopeDeclared`, `ModelLockOnSensitive`,
  `FallbackStormIsIOC`, `NoSilentClockMiss`, `RatifiedClassificationBeforeNotice`,
  `BlindBeforeConfrontation`, `TraceCompleteness`, `SoDCapability`,
  `NoOffensiveArtifact`, `NoResourceCollision`, `DeterministicParametrization`,
  `ArtifactFlow`.

> **G4 (operator guard-rail, honored before sealing).** RoutingConfinement is
> carried explicitly in both `spore.tla` and `spore.toml`, as three named,
> TLC-checked things: (1) the envelope form quantified over the **realized**
> binding (the model a sensitive node actually ran on, incl. post-fallback), not
> the plan; (2) a **fail-closed model-lock** on sensitive nodes (`ModelLockOnSensitive`),
> so an attacker-induced fallback cannot route consequential authorship onto the
> guardrail-free model; (3) the **fallback storm as an IOC** (`FallbackStormIsIOC`),
> a refused sensitive-node fallback recorded as a signal, never silently absorbed.
> The README cites the opposable antecedent (EU AI Act Art. 12 logging + Art. 14
> human-oversight/identity, Reg. (EU) 2024/1689) and word-guards the unsealed
> content discipline against passing for the sealed P8 type-gate (G3).

### 2a. A defect found and fixed during authoring

The first draft placed the legal clock-tree (`classification-ratification`,
`notice`) as a fork off `intake` via `regime-route` only — **not** through the
sensitivity gate. Because those nodes are in `ExternalCapableRoles`, TLC would have
refuted `ClassifyBeforeEscalate` (a notice could "leave the building" carrying
personal data before its sensitivity was classified). **Fix:**
`classification-ratification` now also depends on the (intake-rooted, fast)
`sensitivity-gate`, so every external-capable legal node has the sensitivity gate
upstream, and the clock-tree still forks early. Both `spore.tla` and `spore.toml`
were corrected; the seal is green with the fix.

### 2b. Negative tests — the properties have teeth (MEASURED)

Each mutation below was applied to a copy of `spore.tla` and re-run against
`spore.cfg`; **every one broke the seal** (TLC reported a violation), confirming
the property is load-bearing and not decorative:

| Mutation | Property it must break | Result |
|---|---|---|
| Drop the `custody = "sealed"` clause from `GateDecision` | GateNeverPromotesOnAbsence | **VIOLATED** ✓ |
| Drop the `corr = "present"` clause | CorroborationBeforeAction | **VIOLATED** ✓ |
| Drop the `dis = "present"` clause | (dissent-required gate) | **VIOLATED** ✓ |
| Let `GateDecision` AUTHORIZE on `single_actor` | TwoLegCountersign | **VIOLATED** ✓ |
| Let `GateDecision` AUTHORIZE on `EXHAUSTED` loop | GateNeverPromotesOnAbsence | **VIOLATED** ✓ |
| Let `NoticeDecision` draft without ratification | RatifiedClassificationBeforeNotice | **VIOLATED** ✓ |
| Let `remediation = "applied"` under `drill_only` | DrillOnlyFloor | **VIOLATED** ✓ |
| Drop the `"ev" ∉ caps[a]` guard in the capability grant | SoDCapability | **VIOLATED** ✓ |
| Wire `blue_investigate` downstream of `red_reconstruct` | BlindBeforeConfrontation | **VIOLATED** ✓ |
| Add `external_free` to a restricted node's realizable set | RoutingEnvelopeDeclared | **VIOLATED** ✓ |
| Widen `realized_sens'` to include `external_free` | RoutingConfinement + ModelLockOnSensitive | **VIOLATED** ✓ |
| Break the IOC coupling (`fallback_ioc'` never raised on induced fallback) | FallbackStormIsIOC | **VIOLATED** ✓ |
| Make `RoundPath` constant (drop the round index) | NoResourceCollision | **VIOLATED** ✓ |

## 3. Package self-sufficiency (spot check, PASS)

- No absolute path from the origin machine appears in any germinated brief (paths
  are RELATIVE by construction; the delivery discipline is in every node topic).
- No partner name, client name, persona name, internal molecule/ticket id, or
  galaxy name is load-bearing content. Only public facts are cited by name (DORA,
  NIS2, RGPD, EU AI Act, Directive 2013/40/EU, dual-use control, NIST SP 800-61r3 /
  800-86, OASIS CACAO v2.0, STIX 2.1, TLP, RFC 3161, RFC 6962).
- External attribution is `Noogram` throughout (README header + footer). No other
  maker name appears.

## 4. Files in the package

```
spores/crisis-response/
├── README.md              recipient-facing; carries the "what the seal does NOT
│                          mean" block, the admissibility posture, the
│                          classification-preserving invariant, the live-phase
│                          escrow, the two-part red line, prerequisites, cost.
├── spore.toml             manifest: ParamSchema, 20 fixed nodes + notice fan-out,
│                          typed edges, [spore.seal].
├── spore.tla              the seal — 21 TLC-checked properties.
├── spore.cfg              the TLC model config (measured figures + negative tests).
├── VALIDATION.md          this file.
├── fleet.toml             the crew (17 roles) + constitution.
└── formulas/
    ├── task-work.formula.toml               generic base (no pin)
    ├── task-work-reasoning.formula.toml      opus-5 (pincers, confrontation, dissent)
    ├── task-work-build.formula.toml          opus-5 (plan, notices, remediation, verdict)
    ├── task-work-mechanical.formula.toml      sonnet-5 (trace, gates, corroboration)
    ├── converge-crisis.formula.toml           the bounded epistemic loop
    └── mycelium.formula.toml                  chronicle fold
```

## 5. Verdict

**PASS.** `cs spore validate` expands cleanly (exit 0) on both the minimal and rich
parameter sets; the seal verifies GREEN on TLC (122204 distinct states, depth 26); every
negative test bites. The package is self-contained and public-safe. `cs spore run`
was NOT executed here (it would germinate live molecules against the fleet — out of
scope for an authoring validation); the acceptance bench (PROTOCOL.md) owns the
germination run before any shipment.

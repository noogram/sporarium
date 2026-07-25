---
title: "Firoozbakht: a comparison of standalone Codex and Noogram clean room, with lessons for multi-model research"
date: 2026-07-25
status: publication-candidate
author: Noogram
kind: comparative-study
subjects:
  - Firoozbakht conjecture
  - math-attack
  - multi-provider research
  - reproducible reasoning
---

> French edition: [2026-07-25-firoozbakht-codex-cleanroom-comparison.md](2026-07-25-firoozbakht-codex-cleanroom-comparison.md)

# Firoozbakht: a comparison of standalone Codex and Noogram clean room

## Executive summary

Two independent studies attacked Firoozbakht's conjecture:

\[
  p_{n+1}^{1/(n+1)} < p_n^{1/n}\qquad(n\geq 1).
\]

The first was an autonomous Codex attack, produced in a few minutes as a single document. The second was a Noogram `math-attack` mission run in a clean room by a Claude fleet, with decomposition, literature research, computation, Lean formalization, adversarial critique, and editorial controls.

The two studies independently reach the same scientific diagnosis:

- the conjecture is neither proved nor disproved;
- it is exactly equivalent to a local bound on every prime gap;
- the critical barrier has size \(\log^2 p_n-\log p_n-1+o(1)\);
- the known unconditional bounds, the usual consequence of the Riemann hypothesis, and a simple Cramér-type bound do not suffice;
- the Cramér--Granville heuristic creates a serious tension with the conjecture, without constituting a disproof.

This independent convergence confirms the quality of the scientific intuition in the Codex benchmark. The Noogram fleet does not resolve the conjecture, but turns that intuition into a research state that can be verified, criticized, and handed on. That is its principal contribution.

The best next step is a multi-provider `math-attack` formula: parallel, blinded Claude and Codex branches during exploration, followed by cross-examination, then adjudication by computation, sources, and the formal kernel rather than by linguistic consensus.

## 1. Comparison protocol

### 1.1 Standalone Codex benchmark

The `task-20260724-f632` benchmark requested a solo attack, without a fleet or decomposition. It was executed by Codex, with observed model `gpt-5.6-sol`, in two stages: drafting, then validation.

- Start: 24 July 2026, 13:16 CEST.
- End: 13:20 CEST.
- Duration: approximately four minutes.
- Deliverable: `attack.md`, 241 lines.
- Checks: Pandoc rendering, link availability, and consistency of the statements that neither a proof nor a disproof had been obtained.

### 1.2 Noogram clean room mission

The second study was run in a fresh repository, [`noogram-labs/firoozbakht-cleanroom`](https://github.com/noogram-labs/firoozbakht-cleanroom), by 22 molecules: 17 selecting `claude-opus-5` and 5 selecting `claude-sonnet-5`. All 22 selections came from a formula pin; none came from a silent fallback to the adapter default. The model allocation is therefore auditable, not merely asserted. The repository is published as generated: no staging copy and no cleanup pass.

- Initialization: 25 July 2026, 10:50 CEST.
- End: 14:31 CEST.
- End-to-end duration: approximately 3 h 40.
- DAG result: 22/22 molecules completed.
- Deliverables: decomposition, source ledger, 30 concept cards, three proof attempts, three computation branches, Lean formalization, adversarial corpus, synthesis, and a LaTeX/PDF paper.

This difference in budget is essential: the comparison concerns two **working methods**, not a controlled ranking of providers.

### 1.3 Clean room control

The first Firoozbakht DAG had consulted the Codex analysis in several downstream branches. It therefore could not serve as a blinded comparison. The new mission was launched specifically to correct that defect.

Inspection of the clean room repository establishes that:

1. the decomposition declares the conjecture text and an empty list of prescribed sources as its only inputs;
2. at the time of that decomposition, the tree contained no mathematical file or draft;
3. no scientific artifact cites `attack.md`, `task-20260724-f632`, the Codex benchmark, or its text;
4. occurrences of the word `codex` are confined to generic comments in Cosmon formulas explaining their multi-provider portability.

This does not prove absolute cognitive independence: the models obviously possess prior knowledge of the public literature. It does, however, establish the absence of observable documentary leakage between the two studies, which is the relevant control here.

## 2. The common core recovered independently

Both studies begin with

\[
  g_n=p_{n+1}-p_n,\qquad L_n=\log p_n
\]

and obtain the exact barrier

\[
  g_n<T_n,
  \qquad
  T_n=p_n\left(e^{L_n/n}-1\right)
      =p_n\left(p_n^{1/n}-1\right).
\]

This reformulation localizes the problem: a proof must control **every** prime gap, not merely an average or infinitely many small gaps.

Both analyses then recover the same asymptotic scale:

\[
  T_n=\log^2p_n-\log p_n-1+O(1/\log p_n).
\]

The Codex benchmark alone carries the calculation further:

\[
  T_n=L_n^2-L_n-1-\frac{3}{L_n}-\frac{13}{L_n^2}
      +O(L_n^{-3}).
\]

The strategic diagnoses also converge:

- a bound \(g_n\ll p_n^\theta\), even with \(\theta<1\), remains asymptotically far too large;
- the standard RH route gives a scale close to \(\sqrt p\log p\), still far above \(\log^2p\);
- \(g_n=O(\log^2p_n)\) is insufficient without a leading constant at most 1 and control of lower-order corrections;
- average or global information does not control the single exceptional gap that could reverse the inequality;
- Granville's correction to the Cramér model suggests a limsup greater than 1 and is therefore incompatible with Firoozbakht if the heuristic accurately describes the primes.

This convergence is the most important comparative result. Once the contamination of the first DAG is removed, the core of the Codex analysis reappears in an independent study.

## 3. Strengths of the Codex benchmark

### 3.1 Scientific compression

In four minutes and 241 lines, Codex identifies almost the entire conceptual skeleton that the full mission would subsequently confirm: the exact barrier, the correct asymptotic scale, the standard dead ends, and the heuristic tension.

Its signal-to-noise ratio is excellent. It produces neither superfluous architecture nor a false promise of proof. Its final sentence delineates exactly the two credible outcomes: either a new universal bound with constant 1, or a certified prime gap exceeding the exact barrier.

### 3.2 Local analytical precision

The expansion through the \(-3/L\) and \(-13/L^2\) terms is finer than the formulation ultimately retained by the clean room. The first Noogram study classified this expansion as unsourced; this meant that it had to be derived or referenced before publication, not that it was false.

### 3.3 Exploratory heuristic

Codex also proposes a deliberately naive calculation: if gaps near \(x\) are modeled as exponentials with mean \(\log x\), the expected number of violations up to \(X\) grows as \(e\log\log X\). The document correctly labels this reasoning as non-rigorous.

This idea is not included in the clean room synthesis, which favors the better-supported Cramér--Granville formulation. It nonetheless remains a good example of Codex's value as an exploration node: rapidly producing a testable intuition without confusing it with a proof.

## 4. Distinct contributions of the Noogram mission

### 4.1 A formally certified reduction

The fleet transcribed several forms of the conjecture into Lean 4: a real-power form, a logarithmic form, an arithmetic form, and a prime-gap form. Four of the five initial `sorry` declarations were replaced with genuine proof terms.

The exhaustive audit covers 60 declarations and finds only one dependency on `sorryAx`: the conjecture itself, left explicitly open. The chain

\[
  \text{Conjecture}
  \Longleftrightarrow
  \text{ConjectureReal}
  \Longleftrightarrow
  (\forall n\geq1,\ g_n<T_n)
\]

is thus verified by the kernel rather than merely asserted in prose.

### 4.2 A more precise map of dead ends

The clean room does more than state that RH is insufficient. It establishes separate results that distinguish the levels of implication precisely:

- the strongest RH envelope used in the study certifies the conjecture at only an extremely limited number of indices within its domain;
- no envelope of the form \(Cp^\theta(\log p)^A\), with \(\theta>0\), can yield an asymptotic proof of Firoozbakht;
- merely reducing the constant in a \(C\sqrt p\log p\) bound does not repair this route;
- an abstract `limsup ≤ 1` hypothesis does not, by itself, imply the desired pointwise monotonicity: an explicit countermodel on increasing sequences separates the two statements.

These results do not disprove `RH ⇒ Firoozbakht` as a mathematical implication. They rule out **proof methods**, a distinction that the synthesis preserves explicitly.

### 4.3 Reproducible computation

Two independent branches report an exhaustive search up to \(10^{11}\), comprising 4 118 054 812 pairs of consecutive primes:

- no counterexample;
- maximum observed \(\rho_n=g_n/T_n\): approximately `0.8318`;
- calibration against comparisons in integer arithmetic;
- explicit failure when a margin is too close to the numerical error.

The mission also reconstructs the architecture of the published verification up to \(2^{64}\) and recovers the integer threshold `1920`. Finally, it isolates an analytic window requiring no table, approximately \(396\,738\leq p_n\leq777\,600\), presented cautiously as a result of the study rather than as a published novelty.

### 4.4 Sources and adversarial critique

The ledger contains 20 sources: 11 at the strongest localized primary level, 3 at the primary level with an edition caveat, 4 strongly corroborated, and 2 weakly corroborated. Seven PDFs were read in full and their fingerprints recorded.

The skeptic nevertheless found two `BLOCKER` issues in upstream artifacts:

1. three incompatible definitions of the same “guiding index”;
2. a poorly justified bound in a proof attempt, even though its conclusion could be repaired.

The final paper avoids or correctly discloses these defects, but the source artifacts were not corrected and then re-audited. The evidence gate therefore remains `BLOCKED`.

The citation gate also finds two of 22 references absent from the source ledger, although another branch had consulted them. The editorial verdict is consequently `REWRITE`. This strictness is a useful property of the system: completion of the DAG is not conflated with permission to publish.

## 5. Summary comparison

| Axis | Standalone Codex | Noogram clean room |
|---|---|---|
| Verdict on the conjecture | open | open |
| End-to-end time | ~4 min | ~3 h 40 |
| Organization | 1 molecule, 2 stages | 22 molecules |
| Exact reduction | yes | yes, certified in Lean |
| Asymptotic expansion | locally finer | more cautious and better sourced |
| Exploration of routes | concise, correct | broad, subdivided, and adversarially tested |
| Large-scale computation | no | yes, up to \(10^{11}\) as reported and reproduced by two branches |
| Formalization | no | Lean 4, four auxiliary obligations discharged |
| Bibliography | light checking | provenance ledger and locator-based audit |
| Adversarial review | self-validation | panel, skeptic, corpus of 27 cases, and fail-closed gates |
| Future continuation | standalone note | structured, transferable research state |
| Ready for publication | scoped note | no: `REWRITE` required |

## 6. Interpretation: what the Noogram approach demonstrates

The conjecture remains unresolved. Assessing the study solely by that standard would nevertheless obscure its principal product.

A traditional response concentrates its value in its conclusion. A Noogram mission also leaves a **continuation graph**:

- what is established, conjectural, heuristic, or refuted;
- the obligations still open;
- the routes attempted and the precise reason each stopped;
- the sources and their confidence levels;
- the programs and parameters of the experiments;
- the formal statements actually verified;
- the objections still live;
- the exact conditions for continuing the work and for publication.

A future contributor can therefore begin at the frontier of the existing work instead of reconstructing that frontier from a conclusion or a conversation history. Failure to solve an open problem becomes a cumulative scientific artifact, provided that the trace honestly distinguishes proof, computation, source, heuristic, and opinion.

The benchmark demonstrates the other half of the equation: a single model can reach the correct center of gravity of the problem very quickly. It would be inefficient to abandon that capability in favor of exclusively deep, sequential orchestration.

## 7. Recommendation: multi-provider `math-attack`

### 7.1 Principle

For high-entropy nodes—exploration, choice of reformulation, search for counterexamples, or adversarial critique—launch two independent branches, for example Claude and Codex, from the same sealed brief.

```text
                         sealed brief
                              |
                +-------------+-------------+
                |                           |
         Claude exploration          Codex exploration
                |                           |
                +-------------+-------------+
                              |
                     adversarial comparison
                    /                      \
          Claude critiques Codex    Codex critiques Claude
                    \                      /
                     +---------+----------+
                               |
                       disagreement synthesis
                               |
                  sources / computation / Lean / gates
```

### 7.2 Proposed invariants

1. **Identical brief.** Both branches receive the same statement, the same authorized sources, and the same explicit budget.
2. **Blinding before closure.** Neither branch reads the other before sealing its first artifact.
3. **Provenance of ideas.** The synthesis labels every result `independent-convergence`, `claude-only`, `codex-only`, `inherited`, or `disputed`.
4. **Alternating roles.** No provider is fixed as author or critic: each must in turn produce and attack.
5. **Disagreement preserved.** The synthesis does not erase a disagreement by vote. It names the test that could resolve it.
6. **External adjudicator where possible.** Lean, exact computation, reproduction, and reading of sources decide before any model preference.
7. **Anti-contamination gate.** Artifact hashes and access order make it possible to demonstrate that the initial branches were blinded.
8. **Equal-budget comparison.** Any performance claim across providers requires a separate sub-benchmark with comparable time, tools, and context.

### 7.3 Priority nodes for the two-model approach

Systematically duplicating the entire DAG would be costly and produce substantial redundancy. The expected benefit is greatest for:

- `decompose` and obligation generation;
- strategy exploration and countermodel search;
- selection of numerical experiments;
- adversarial review of informal proofs;
- review of formal statements before implementation;
- synthesis of contradictions between branches.

Mechanical tasks—trace collection, compilation, deterministic computation, hash verification, and format application—benefit less from duplication across providers.

### 7.4 Recommended next experiment

Preregister a new mathematical mission with four comparable outputs:

1. Claude solo, short budget;
2. Codex solo, same brief and same budget;
3. Claude + Codex in blinded parallel, without cross-examination;
4. the same pair with cross-examination and synthesis.

An evaluator unaware of the texts' origins then scores correctness, novelty of avenues, coverage of obligations, errors, provenance, and cost. This experiment would finally separate three effects that are currently confounded: model quality, the effect of parallelization, and the effect of the Noogram method itself.

## 8. Publication-ready conclusion

The Firoozbakht study does not show that a fleet automatically solves an open problem. It shows something more useful and more credible.

Within a few minutes, Codex recovered the mathematical core of the problem with remarkable density. The Noogram clean room independently recovered the same core, then transformed it into a research map: formal equivalences, reproducible experiments, dead ends demonstrated, an audited bibliography, objections, and conditions for continuation.

Noogram's value, then, is not to replace the rapid intuition of a strong model. It is to make that intuition cumulative. The best system combines both: different models explore independently, critique one another, and then deposit their results in a trace from which a human or future agent can resume the work without starting from scratch.

## 9. Audited artifacts

Unless otherwise stated, every artifact below is **publicly verifiable**: references of the form `firoozbakht-cleanroom@6664094` resolve on `main` in [`noogram-labs/firoozbakht-cleanroom`](https://github.com/noogram-labs/firoozbakht-cleanroom).

- Codex benchmark — **public**: [`noogram-labs/firoozbakht:runs/2026-07-24-full-lane/codex-solo-attack.md`](https://github.com/noogram-labs/firoozbakht/blob/main/runs/2026-07-24-full-lane/codex-solo-attack.md) (byte-for-byte identical to the original `attack.md`; because the public repository was rebuilt on an orphan root, the drafting hash `89715c2` does not exist there and therefore cannot serve as a reference)
- Benchmark state (molecule `task-20260724-f632`) — **private**, not publicly verifiable: it resides in the Cosmon state of the original galaxy, which is not published. The statements in §1.1 that depend on it (observed model, timestamp, duration) rely on this private source.
- Clean room decomposition: `firoozbakht-cleanroom@6664094:attack/decompose.md`
- Clean room synthesis: `firoozbakht-cleanroom@6664094:attack/synthesis.md`
- Lean report: `firoozbakht-cleanroom@6664094:attack/lean-probe-report.md`
- Source ledger: `firoozbakht-cleanroom@6664094:attack/source-ledger.md`
- Evidence gate: `firoozbakht-cleanroom@6664094:attack/evidence-verdict.md`
- Citation gate: `firoozbakht-cleanroom@6664094:attack/verification-report.md`
- Editorial verdict: `firoozbakht-cleanroom@6664094:attack/editorial-verdict.md`
- Clean room paper: `firoozbakht-cleanroom@6664094:paper/paper.tex`

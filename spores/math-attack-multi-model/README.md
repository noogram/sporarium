# `math-attack-multi-model` — two providers, blind, then cross-examined

A variant of [`math-attack`](../math-attack/) that frames the problem **twice, independently, on two different providers**, has each provider cross-examine the other's framing, and merges the two while labelling where they agreed, where they differed, and what would settle the difference.

`math-attack` is unchanged and remains the default choice. Use this one when the question is not only *what can a fleet establish* but *what did two independent framings see differently* — and when you are willing to pay for the second framing to find out.

## Why this exists

[The comparative study](../../docs/reports/2026-07-25-firoozbakht-codex-cleanroom-comparison.en.md) that motivated this spore ran a fleet and a single strong model against the same open conjecture. Both recovered the same mathematical core independently, which was the most informative result in the whole exercise — and it was visible only *because* the two runs had not read each other.

That study's own recommendation was to build the independence into the pipeline instead of reconstructing it after the fact. This is that pipeline.

## The one thing that is different, and why it is structural

Everything hinges on the two framings being genuinely independent when they seal. The obvious way to state that is a rule in the brief: *do not read the other branch.* We have direct evidence that this does not hold. In the run that produced the study, a delivery rule was stated in a brief, violated, restated more explicitly, and violated twice more within the hour. **A behavioural rule in a prompt is not a guarantee.**

So the blinding here is a property of the dependency graph, checked by TLC:

```tla
BlindBeforeConfrontation ==
    /\ decompose_a \notin ReachDeps(decompose_b)      \* nothing to read...
    /\ decompose_b \notin ReachDeps(decompose_a)      \* ...in either direction
    /\ \A n \in ConfrontationRoles :                  \* and no confrontation
         /\ decompose_a \in ReachDeps(n)              \* starts before BOTH
         /\ decompose_b \in ReachDeps(n)              \* branches have sealed
```

Neither branch has the other among its dependencies, so the other's artifact is not *available* to it — there is nothing to read, rather than a request not to look. And every confrontation node waits on both, so cross-examination cannot begin early.

The property has teeth. Two mutations were run against it and **both were rejected** by TLC:

| Mutation | Why someone would do it | Verdict |
|---|---|---|
| Wire branch B downstream of branch A | Cheaper — B "builds on" A instead of duplicating work | **REJECTED**, and this is the dangerous one: it looks like an optimisation while silently destroying the measurement |
| Let the merge run on one branch | Fewer edges, simpler graph | **REJECTED** |

The seal is green with six properties: the five `math-attack` already proves, plus this one. Model: 1406 distinct states, depth 31, about 4 seconds.

## The framing block

```
        decompose-a (provider A)        decompose-b (provider B)
                 |    \                    /    |
                 |     \                  /     |
                 |      \                /      |
        cross-critique-ba              cross-critique-ab
          (A examines B)                 (B examines A)
                  \                        /
                   \                      /
                    disagreement-synthesis
                             |
                    frame-deliberation -> ... (unchanged math-attack DAG)
```

Five nodes replace `math-attack`'s single `decompose`. The rest of the DAG is untouched: `disagreement-synthesis` produces `decompose_md`, so every downstream node keeps the requirement it already had.

**Roles alternate.** Provider B cross-examines A's framing; provider A cross-examines B's. Neither is fixed as author or as critic — a permanent hierarchy between providers would turn a comparison into a preference.

**The critiques must also concede.** Each cross-examination carries a mandatory section naming what the *other* branch saw that its own did not. A critique that only attacks is a weaker instrument than one that also concedes.

**The merge never votes.** Every load-bearing result is labelled `independent-convergence`, `A-only`, `B-only` or `disputed`. For each dispute the synthesis names the test that would settle it — a computation, a source to read, a Lean statement to check — and carries the disagreement forward intact. A merge that quietly picks a winner destroys the only thing two branches buy you.

## Cost, stated honestly

Four extra nodes over `math-attack` — 22 calls against 18 at the default fan-out — concentrated in the cheapest phase of the run. Doubling the whole DAG was considered and rejected: mechanical work such as trace capture, compilation, deterministic computation and hash checking gains nothing from a second provider, and the study says so. Where alternation costs nothing, it is done with a formula pin rather than a duplicated node.

## Prerequisites

Everything [`math-attack` requires](../math-attack/README.md) — `cs` on `PATH`, the `claude` adapter chosen, a TeX toolchain, and the spore's formulas copied into your mission's `.cosmon/formulas/` — **plus the second provider**:

- The **Codex CLI** installed and authenticated, for branch B.
- Your mission galaxy **trusted by Codex**, or the worker spawns and dies silently after about 30 seconds with no output:

  ```toml
  # ~/.codex/config.toml
  [projects."/abs/path/to/your/mission"]
  trust_level = "trusted"
  ```

- **No `claude-*` model pin on a codex-bound step.** The Codex CLI rejects a `claude-*` id outright — *"The 'claude-opus-5' model is not supported when using Codex with a ChatGPT account"*. `formulas/task-work-reasoning-b.formula.toml` therefore pins the adapter and *no* model, letting Codex's own default answer. If you fork a formula for branch B, keep that shape.

Verify the split actually took, rather than trusting it — a silently single-provider run looks exactly like a successful two-provider one:

```sh
python3 -c 'import json;[print(d["mol_id"],d["selection_source"].get("source"),d.get("adapter_name")) \
  for d in map(json.loads,open(".cosmon/state/events.jsonl")) \
  if d.get("type") in ("model_selected","adapter_selected")]'
# expect branch A molecules on adapter claude, branch B molecules on adapter codex
```

## What this spore does not claim

It does not measure which provider is better. Two branches with the same brief and the same budget tell you where independent framings **converge and diverge**; ranking providers needs a separate, pre-registered benchmark with equal tooling and equal context, and the study that motivated this spore is explicit that its own comparison was not one.

It also does not make the branches cognitively independent — both models have read the public literature. What the seal guarantees is the absence of *documentary* leakage between them during the run, which is the control that is actually available.

---

*Built by [Noogram](https://noogram.org). Licensing: see the repository root.*

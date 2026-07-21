# Sporarium

**The nursery and acceptance bench for cosmon spores.** A laboratory
repository where spores are grown (`spores/` — pure configuration: a spore
never requires building cosmon) and where every spore bound for an external
recipient is proven *exactly as the recipient will live it* — from the
package, never from a development checkout.

## Vocabulary (so this file stands on its own)

- **cosmon** — an open-source engine that runs a fleet of AI workers through a
  DAG of typed, ordered steps and records every step to disk. `cs` is its CLI.
- **spore** — a shareable, parameterized template of a whole cosmon mission: a
  fleet, per-node recipes (formulas), a parameter schema, a DAG of typed edges,
  and an optional TLA+ *seal*. A spore is data, not code; it ships as plain
  config files.
- **germinate** — expand a spore into live work with `cs spore run` (the spore
  analogue of creating one task).
- **seal** — a TLA+ model that TLC mechanically checks before germination,
  certifying named safety properties of the expanded DAG (termination,
  fail-closed gates, artifact flow).

Separation of concerns with cosmon: the spore *format* and its runtime
(`cs spore validate/run/export`, TLC seal verification) are cosmon code; a
spore's *content* (spore.toml, formulas, .tla/.cfg, README) is data, and lives
here.

## Why this repository exists

A spore is a parcel: what matters is not that the template works at its
author's desk, but that it germinates for someone who has none of our custom
agents, none of our reference tooling, none of our JVM, none of our paths.
The very first shipment caught two leaks of exactly this kind before
departure: a dependency on a local citation-audit agent, and a JVM path.
This bench institutionalizes that catch.

## Invariants

- **Test the parcel, not the source.** Every acceptance run starts from the
  package a recipient receives, never from a cosmon repo checkout. If the
  package and the repo diverge, the package tells the truth about what the
  recipient gets.
- **A sandbox is disposable; a report is durable.** Germinations happen in
  `bench/<version>/` (gitignored, recreated at will). The exact parcels
  (`drops/`, named `<spore>-v<N>-<date>.zip`) and the acceptance reports
  (`runs/`) are **local and gitignored**: the public repo publishes only
  `spores/` plus the protocol, README, and licenses. Drops and runs are
  archived privately at every milestone.
- **Simulate the bare-handed recipient first.** Every protocol starts with
  the no-tooling path (no JVM, no Lean) to verify that refusals are
  fail-closed and error messages are livable — that is the recipient's real
  first contact.
- **Verdict before shipping.** A spore leaves for a recipient only with an
  acceptance report at verdict SHIP.

## Protocol

The acceptance protocol lives in [PROTOCOL.md](PROTOCOL.md). Each acceptance
report cites it step by step.

## Feeding fixes back to cosmon

When bench work here uncovers a defect in the spore *runtime* itself — an
unlivable error message, a local dependency leaked into a bundle, a gate that
passes when it should refuse — that is a cosmon bug, not a bench bug. Report it
to the cosmon project rather than silently working around it here; the spore
content in this repo should never paper over a broken runtime primitive.

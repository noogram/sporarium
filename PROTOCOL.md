# Spore acceptance protocol

Each step produces one line of the report `runs/<date>-<spore>-v<N>.md`
(local, unpublished — archived privately):
step, exact command, expected, observed, verdict (✅ / ❌ / ⚠️).

## P0 — Package integrity

1. List the package contents — the file list is the announced one; no
   tracked file missing, no stray artifact.
2. If an `ro-crate-metadata.json` is present: its `spore:bundleHash` matches
   the `cs spore export` of the source at shipping time.

## P1 — Cold germination (the bare-handed recipient)

In a pristine `bench/<version>/`:

3. Unpack the package, `cs init`.
4. `cs spore validate <spore>/spore.toml` with the **minimal** parameter set
   (required params only) — full expansion, expected call count, `seal:`
   line displayed honestly.
5. `cs spore validate` with the **rich** set (multi-target fan-out,
   alternate backend) — fanout nodes index correctly, prompts interpolate
   the params.
6. `cs spore run` **without optional tooling** (no JVM/TLC) — the refusal
   must be fail-closed with a livable message that names the opt-in flag.
   A silent pass here is an eliminatory ❌.

## P2 — Real germination

7. `cs spore run … --allow-unchecked-seal` (or without the flag if P3 is
   already green on this machine) — every molecule germinates, `cs ensemble`
   sees them, the blocked-by edges reproduce the declared DAG.
8. Inspect one germinated prompt at random: no absolute path from the
   origin machine, no agent/tool outside the bundle invoked without a
   fallback clause.

## P3 — Verified seal (the tooled recipient)

9. With a JVM + `TLA2TOOLS_JAR` pointed: `cs spore run` must verify the
   seal (status `seal: verified <hash>`) and germinate without the flag.
10. Deliberately corrupt a `.tla` in the sandbox: the hash changes, TLC
    re-runs or refuses — the cache never launders a modified seal.

## P4 — Self-sufficiency

11. The package must be fully understandable by an external reader with no
    access to our internal world: no bare internal acronyms, galaxy names,
    persona names as load-bearing content, internal ticket/molecule IDs,
    or absolute local paths. Attribution-flavor references to universally
    known thinkers are allowed only when the operative content is
    self-contained prose.
12. Every external link in the package resolves publicly.
13. Preferred judge: a blank-context reading session in a pristine
    container, instructed to report every term, reference, or instruction
    it cannot resolve from the package alone plus general public knowledge.
    The grep codebook of internal tokens is the quick local filter; the
    blank reader is the authority.

## P5 — Verdict

- **SHIP**: P0–P2 and P4 green; P3 green or explicitly N/A (recipient
  without a JVM, README owns it).
- **REWRITE**: any ❌, or any ⚠️ not covered by a line in the README.

The report cites the `cs` binary version (`cs --version`) and the machine.

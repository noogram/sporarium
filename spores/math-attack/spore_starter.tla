-------------------------- MODULE spore_starter --------------------------
\* ==========================================================================
\* spore_starter.tla — the TLC-checked seal for the math-attack STARTER lane
\* (v3.2). A deliberately tiny model: the 4-node linear chain
\*   decompose -> proof-attempt -> skeptic -> trace
\* held to the same property vocabulary as the full lane MINUS GateFailClosed
\* (the starter has NO kernel / citation / editorial gate — honest boundary: it
\* never claims 'proved', so there is no promotion verdict to fail closed). The
\* four properties it DOES carry: Termination, NoResourceCollision,
\* DeterministicParametrization, and ArtifactFlow (v3.2 — every required
\* artifact has an upstream producer).
\*
\* Launch:  see spore_starter.cfg (the direct TLC command; any Java 11+).
\* ==========================================================================

EXTENDS Naturals, Sequences, FiniteSets, TLC

CONSTANTS NULL

\* The four fixed roles of the starter chain (declaration order).
Roles == { "decompose", "proof_attempt", "skeptic", "trace" }

Fix(r) == [role |-> r, sq |-> NULL]

Nodes == { Fix(r) : r \in Roles }

\* Linear dependency chain.
Deps(n) ==
    CASE n.role = "decompose"     -> {}
      [] n.role = "proof_attempt" -> { Fix("decompose") }
      [] n.role = "skeptic"       -> { Fix("proof_attempt") }
      [] n.role = "trace"         -> { Fix("skeptic") }

ArtifactPath(n) == n.role   \* no fan-out in the starter lane

Produces(n) ==
    CASE n.role = "decompose"     -> { "decompose_md" }
      [] n.role = "proof_attempt" -> { "proof_attempt" }
      [] n.role = "skeptic"       -> { "faults_md" }
      [] n.role = "trace"         -> { "trace_sidecar" }

Requires(n) ==
    CASE n.role = "decompose"     -> {}
      [] n.role = "proof_attempt" -> { "decompose_md" }
      [] n.role = "skeptic"       -> { "proof_attempt" }
      [] n.role = "trace"         -> { "faults_md" }

RECURSIVE ReachDeps(_)
ReachDeps(n) == Deps(n) \cup UNION { ReachDeps(d) : d \in Deps(n) }
ProducedUpstream(n) == UNION { Produces(m) : m \in ReachDeps(n) }

\* ==========================================================================
\* State — node drainage + the collision witness.
\* ==========================================================================
VARIABLES status, written
vars == << status, written >>

Runnable(n) ==
    /\ status[n] = "Pending"
    /\ \A d \in Deps(n) : status[d] = "Done"

Init ==
    /\ status  = [n \in Nodes |-> "Pending"]
    /\ written = {}

Execute(n) ==
    /\ Runnable(n)
    /\ status'  = [status EXCEPT ![n] = "Done"]
    /\ written' = written \cup { ArtifactPath(n) }

Next == \E n \in Nodes : Execute(n)

Fairness == \A n \in Nodes : WF_vars(Execute(n))

Spec == Init /\ [][Next]_vars /\ Fairness

\* ==========================================================================
\* Properties
\* ==========================================================================
TypeOK ==
    /\ status  \in [Nodes -> {"Pending", "Done"}]
    /\ written \subseteq { ArtifactPath(n) : n \in Nodes }

Termination == \A n \in Nodes : <>(status[n] = "Done")

NoResourceCollision ==
    \A m, n \in Nodes :
        (m # n /\ status[m] = "Done" /\ status[n] = "Done")
            => ArtifactPath(m) # ArtifactPath(n)

DeterministicParametrization ==
    Cardinality(Nodes) = Cardinality(Roles)

ArtifactFlow ==
    \A n \in Nodes : Requires(n) \subseteq ProducedUpstream(n)

SealInvariant ==
    /\ TypeOK
    /\ NoResourceCollision
    /\ DeterministicParametrization
    /\ ArtifactFlow

=============================================================================

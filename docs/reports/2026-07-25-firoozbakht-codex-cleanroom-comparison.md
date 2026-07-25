---
title: "Firoozbakht : comparaison Codex pur / Noogram clean room et enseignements multi-modèles"
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

# Firoozbakht : comparaison Codex pur / Noogram clean room

## Résumé exécutif

Deux études indépendantes ont attaqué la conjecture de Firoozbakht :

\[
  p_{n+1}^{1/(n+1)} < p_n^{1/n}\qquad(n\geq 1).
\]

La première est une attaque autonome de Codex, produite en quelques minutes dans un document unique. La seconde est une mission Noogram `math-attack` exécutée en clean room par une flotte Claude, avec décomposition, recherche bibliographique, calcul, formalisation Lean, critique contradictoire et contrôles éditoriaux.

Les deux études aboutissent indépendamment au même diagnostic scientifique :

- la conjecture n'est ni démontrée ni réfutée ;
- elle équivaut exactement à une borne locale sur chaque écart entre nombres premiers ;
- la barrière critique est de taille \(\log^2 p_n-\log p_n-1+o(1)\) ;
- les bornes inconditionnelles connues, la conséquence usuelle de l'hypothèse de Riemann et une simple borne de type Cramér ne suffisent pas ;
- l'heuristique de Cramér--Granville crée une tension sérieuse avec la conjecture, sans constituer une réfutation.

Cette convergence indépendante confirme la qualité de l'intuition scientifique du benchmark Codex. La flotte Noogram n'apporte pas une résolution de la conjecture, mais transforme cette intuition en un état de recherche vérifiable, critiquable et transmissible. C'est son apport principal.

Le meilleur prolongement est une formule `math-attack` multi-provider : branches Claude et Codex parallèles et aveugles pendant l'exploration, confrontation croisée ensuite, puis arbitrage par calcul, sources et noyau formel plutôt que par consensus linguistique.

## 1. Protocole de comparaison

### 1.1 Benchmark Codex pur

Le benchmark `task-20260724-f632` demandait une attaque solo, sans flotte ni décomposition. Il a été exécuté par Codex, modèle observé `gpt-5.6-sol`, en deux étapes : rédaction puis validation.

- Début : 24 juillet 2026, 13:16 CEST.
- Fin : 13:20 CEST.
- Durée : environ quatre minutes.
- Livrable : `attack.md`, 241 lignes.
- Contrôles : rendu Pandoc, disponibilité des liens et cohérence des déclarations de non-preuve/non-réfutation.

### 1.2 Mission Noogram clean room

La seconde étude a été exécutée dans un dépôt neuf, [`noogram-labs/firoozbakht-cleanroom`](https://github.com/noogram-labs/firoozbakht-cleanroom), par 22 molécules : 17 sélectionnant `claude-opus-5` et 5 sélectionnant `claude-sonnet-5`. Ces 22 sélections proviennent toutes d'un pin de formule, aucune d'un repli silencieux vers le défaut de l'adaptateur — l'allocation de modèles est donc auditable et non simplement affirmée. Le dépôt est publié tel qu'il a été généré : ni copie de préparation, ni passe de nettoyage.

- Initialisation : 25 juillet 2026, 10:50 CEST.
- Fin : 14:31 CEST.
- Durée de bout en bout : environ 3 h 40.
- Résultat du DAG : 22/22 molécules terminées.
- Livrables : décomposition, registre de sources, 30 fiches conceptuelles, trois tentatives de preuve, trois branches de calcul, formalisation Lean, corpus adversarial, synthèse et article LaTeX/PDF.

Cette différence de budget est essentielle : il s'agit d'une comparaison entre deux **méthodes de travail**, pas d'un classement contrôlé entre fournisseurs.

### 1.3 Contrôle de la clean room

Le premier DAG Firoozbakht avait consulté l'analyse Codex dans plusieurs branches aval. Il ne pouvait donc pas servir de comparaison aveugle. La nouvelle mission a été lancée précisément pour corriger ce défaut.

Le contrôle du dépôt clean room établit que :

1. la décomposition déclare comme seuls inputs le texte de la conjecture et une liste vide de sources imposées ;
2. au moment de cette décomposition, aucun fichier mathématique ou brouillon n'existait dans l'arbre ;
3. aucun artefact scientifique ne cite `attack.md`, `task-20260724-f632`, le benchmark Codex ou son texte ;
4. les occurrences du mot `codex` se limitent aux commentaires génériques des formules Cosmon expliquant leur portabilité multi-provider.

Cela ne prouve pas une indépendance cognitive absolue : les modèles possèdent évidemment une connaissance préalable de la littérature publique. Cela établit en revanche l'absence de fuite documentaire observable entre les deux études, qui est le contrôle pertinent ici.

## 2. Le noyau commun retrouvé indépendamment

Les deux études partent de

\[
  g_n=p_{n+1}-p_n,\qquad L_n=\log p_n
\]

et obtiennent la barrière exacte

\[
  g_n<T_n,
  \qquad
  T_n=p_n\left(e^{L_n/n}-1\right)
      =p_n\left(p_n^{1/n}-1\right).
\]

Cette reformulation localise le problème : une preuve doit contrôler **chaque** écart premier, pas seulement une moyenne ou une infinité de petits écarts.

Les deux analyses retrouvent ensuite la même échelle asymptotique :

\[
  T_n=\log^2p_n-\log p_n-1+O(1/\log p_n).
\]

Le benchmark Codex pousse seul le calcul plus loin :

\[
  T_n=L_n^2-L_n-1-\frac{3}{L_n}-\frac{13}{L_n^2}
      +O(L_n^{-3}).
\]

Les diagnostics stratégiques convergent également :

- une borne \(g_n\ll p_n^\theta\), même avec \(\theta<1\), reste asymptotiquement beaucoup trop grande ;
- la route RH standard donne une échelle proche de \(\sqrt p\log p\), encore très au-dessus de \(\log^2p\) ;
- \(g_n=O(\log^2p_n)\) ne suffit pas sans constante principale au plus égale à 1 et sans maîtrise des corrections inférieures ;
- les informations moyennes ou globales ne contrôlent pas l'écart exceptionnel unique qui pourrait inverser l'inégalité ;
- la correction de Granville au modèle de Cramér suggère un limsup supérieur à 1, donc incompatible avec Firoozbakht si l'heuristique décrit correctement les nombres premiers.

Cette convergence est le résultat comparatif le plus important. Après retrait de la contamination du premier DAG, le cœur de l'analyse Codex réapparaît dans une étude indépendante.

## 3. Forces du benchmark Codex

### 3.1 Compression scientifique

En quatre minutes et 241 lignes, Codex identifie presque tout le squelette conceptuel que la mission complète confirmera ensuite : barrière exacte, bonne échelle asymptotique, impasses classiques et tension heuristique.

Son rapport signal/bruit est excellent. Il ne produit ni architecture superflue ni fausse promesse de preuve. Sa phrase terminale délimite exactement les deux sorties crédibles : soit une borne universelle nouvelle à constante 1, soit un écart premier certifié dépassant la barrière exacte.

### 3.2 Précision analytique locale

Le développement jusqu'aux termes \(-3/L\) et \(-13/L^2\) est plus fin que la formulation finalement conservée par la clean room. La première étude Noogram avait classé ce développement comme non sourcé ; cela signifiait qu'il devait être dérivé ou référencé avant publication, non qu'il était faux.

### 3.3 Heuristique exploratoire

Codex propose aussi un calcul volontairement naïf : si les gaps proches de \(x\) sont modélisés par des exponentielles de moyenne \(\log x\), le nombre attendu de violations jusqu'à \(X\) croît comme \(e\log\log X\). Le document qualifie correctement ce raisonnement de non rigoureux.

Cette idée n'est pas reprise dans la synthèse clean room, qui privilégie la formulation plus étayée de Cramér--Granville. Elle demeure un bon exemple de la valeur de Codex comme nœud d'exploration : produire rapidement une intuition testable sans la confondre avec une preuve.

## 4. Apports propres de la mission Noogram

### 4.1 Une réduction formellement certifiée

La flotte a transcrit plusieurs formes de la conjecture dans Lean 4 : forme à puissances réelles, forme logarithmique, forme arithmétique et forme en écart premier. Quatre des cinq `sorry` initiaux ont été remplacés par de vrais termes de preuve.

L'audit exhaustif porte sur 60 déclarations et ne trouve qu'une dépendance à `sorryAx` : la conjecture elle-même, laissée explicitement ouverte. La chaîne

\[
  \text{Conjecture}
  \Longleftrightarrow
  \text{ConjectureReal}
  \Longleftrightarrow
  (\forall n\geq1,\ g_n<T_n)
\]

est ainsi vérifiée par le noyau plutôt que seulement affirmée en prose.

### 4.2 Une cartographie plus précise des routes mortes

La clean room ne se contente pas de dire que RH est insuffisante. Elle démontre des résultats séparant précisément les niveaux d'implication :

- la meilleure enveloppe RH utilisée dans l'étude ne certifie la conjecture qu'à un nombre extrêmement limité d'indices dans son domaine ;
- aucune enveloppe de type \(Cp^\theta(\log p)^A\), avec \(\theta>0\), ne peut fournir une preuve asymptotique de Firoozbakht ;
- diminuer seulement la constante d'une borne \(C\sqrt p\log p\) ne répare pas cette route ;
- une hypothèse abstraite de type `limsup ≤ 1` n'entraîne pas, à elle seule, la monotonie point par point recherchée : un contre-modèle explicite sur les suites croissantes sépare les deux énoncés.

Ces résultats ne réfutent pas `RH ⇒ Firoozbakht` comme implication mathématique. Ils ferment des **méthodes de preuve**, distinction que la synthèse conserve explicitement.

### 4.3 Calcul reproductible

Deux branches indépendantes annoncent une exploration exhaustive jusqu'à \(10^{11}\), soit 4 118 054 812 paires de nombres premiers consécutifs :

- aucun contre-exemple ;
- maximum observé de \(\rho_n=g_n/T_n\) : environ `0.8318` ;
- calibrations contre des comparaisons en arithmétique entière ;
- échec explicite en cas de marge trop proche de l'erreur numérique.

La mission reconstruit également l'architecture de la vérification publiée jusqu'à \(2^{64}\) et retrouve le seuil entier `1920`. Elle isole enfin une fenêtre analytique sans table, environ \(396\,738\leq p_n\leq777\,600\), présentée prudemment comme un résultat de l'étude et non comme une nouveauté publiée.

### 4.4 Sources et critique contradictoire

Le registre comprend 20 sources : 11 au niveau primaire localisé le plus fort, 3 au niveau primaire avec réserve d'édition, 4 corroborées fortement et 2 corroborées faiblement. Sept PDF ont été lus intégralement et leurs empreintes enregistrées.

Le sceptique a cependant trouvé deux `BLOCKER` dans les artefacts amont :

1. trois définitions incompatibles d'un même « indice directeur » ;
2. une borne mal justifiée dans une tentative de preuve, même si sa conclusion pouvait être réparée.

Le papier final évite ou expose correctement ces défauts, mais les artefacts sources n'ont pas été corrigés puis réaudités. L'evidence gate reste donc `BLOCKED`.

Le citation gate trouve en outre deux références sur 22 absentes du registre de sources, bien qu'elles aient été consultées par une autre branche. Le verdict éditorial est par conséquent `REWRITE`. Cette sévérité est une propriété utile du système : l'achèvement du DAG n'est pas confondu avec l'autorisation de publier.

## 5. Comparaison synthétique

| Axe | Codex pur | Noogram clean room |
|---|---|---|
| Verdict sur la conjecture | ouverte | ouverte |
| Temps de bout en bout | ~4 min | ~3 h 40 |
| Organisation | 1 molécule, 2 étapes | 22 molécules |
| Réduction exacte | oui | oui, certifiée dans Lean |
| Expansion asymptotique | plus fine localement | plus prudente et mieux sourcée |
| Exploration des routes | concise, juste | large, subdivisée et adversarialement testée |
| Calcul massif | non | oui, jusqu'à \(10^{11}\) annoncé et reproduit par deux branches |
| Formalisation | non | Lean 4, quatre obligations auxiliaires fermées |
| Bibliographie | contrôle léger | registre de provenance et audit par localisateur |
| Adversarial review | auto-validation | panel, skeptic, corpus de 27 cas et gates fail-closed |
| Reprise future | note autonome | état de recherche structuré et transmissible |
| Prêt à publier | note scoped | non : `REWRITE` requis |

## 6. Interprétation : ce que démontre l'approche Noogram

La conjecture n'est toujours pas résolue. Mesurer l'étude seulement à cette aune ferait pourtant disparaître son produit principal.

Une réponse traditionnelle concentre sa valeur dans sa conclusion. Une mission Noogram laisse aussi un **graphe de reprise** :

- ce qui est établi, conjectural, heuristique ou réfuté ;
- les obligations encore ouvertes ;
- les routes tentées et la raison précise de leur arrêt ;
- les sources et leur niveau de confiance ;
- les programmes et paramètres des expériences ;
- les énoncés formels réellement vérifiés ;
- les objections encore vivantes ;
- les conditions exactes de reprise et de publication.

Un futur contributeur peut donc commencer à la frontière du travail existant au lieu de reconstituer cette frontière depuis une conclusion ou un historique de conversation. L'échec à résoudre un problème ouvert devient un artefact scientifique cumulatif, à condition que la trace distingue honnêtement preuve, calcul, source, heuristique et opinion.

Le benchmark montre l'autre moitié de l'équation : un modèle unique peut atteindre très vite le bon centre de gravité du problème. Il serait inefficace d'abandonner cette capacité au profit d'une orchestration uniquement profonde et séquentielle.

## 7. Recommandation : `math-attack` multi-provider

### 7.1 Principe

Pour les nœuds à forte entropie — exploration, choix de reformulation, recherche de contre-exemple ou critique adversariale — lancer deux branches indépendantes, par exemple Claude et Codex, depuis le même brief scellé.

```text
                         brief scellé
                              |
                +-------------+-------------+
                |                           |
        exploration Claude          exploration Codex
                |                           |
                +-------------+-------------+
                              |
                   comparaison contradictoire
                    /                      \
          Claude critique Codex     Codex critique Claude
                    \                      /
                     +---------+----------+
                               |
                       synthèse de désaccord
                               |
                  sources / calcul / Lean / gates
```

### 7.2 Invariants proposés

1. **Brief identique.** Les deux branches reçoivent le même énoncé, les mêmes sources autorisées et le même budget explicite.
2. **Aveuglement avant clôture.** Aucune branche ne lit l'autre avant d'avoir scellé son premier artefact.
3. **Provenance des idées.** La synthèse marque chaque résultat `independent-convergence`, `claude-only`, `codex-only`, `inherited` ou `disputed`.
4. **Rôles alternés.** Aucun fournisseur n'est figé comme auteur ou critique : chacun doit successivement produire et attaquer.
5. **Désaccord conservé.** La synthèse n'efface pas un désaccord par vote. Elle nomme le test susceptible de le trancher.
6. **Arbitre externe quand possible.** Lean, calcul exact, reproduction et lecture de sources décident avant toute préférence de modèle.
7. **Gate anti-contamination.** Les hashes des artefacts et l'ordre d'accès permettent de démontrer que les branches initiales étaient aveugles.
8. **Comparaison à budget égal.** Toute affirmation de performance entre providers exige un sous-benchmark séparé avec temps, outils et contexte comparables.

### 7.3 Nœuds prioritaires pour le double modèle

Le doublement systématique de tout le DAG serait coûteux et produirait beaucoup de redondance. Le bénéfice attendu est maximal sur :

- `decompose` et génération des obligations ;
- exploration de stratégies et recherche de contre-modèles ;
- choix des expériences numériques ;
- revue adversariale des preuves informelles ;
- revue des énoncés formels avant implémentation ;
- synthèse des contradictions entre branches.

Les tâches mécaniques — collecte de traces, compilation, calcul déterministe, vérification de hashes et application de formats — gagnent moins à être dupliquées par fournisseur.

### 7.4 Expérience suivante recommandée

Préenregistrer une nouvelle mission mathématique avec quatre sorties comparables :

1. Claude solo, budget court ;
2. Codex solo, même brief et même budget ;
3. Claude + Codex en parallèle aveugle, sans confrontation ;
4. même paire avec confrontation croisée et synthèse.

Un évaluateur qui ne connaît pas l'origine des textes note ensuite : correction, nouveauté des pistes, couverture des obligations, erreurs, provenance et coût. Cette expérience séparerait enfin trois effets aujourd'hui confondus : qualité du modèle, effet de parallélisation et effet propre de la méthode Noogram.

## 8. Conclusion publiable

L'étude Firoozbakht ne montre pas qu'une flotte résout automatiquement un problème ouvert. Elle montre quelque chose de plus utile et de plus crédible.

Codex a retrouvé en quelques minutes le cœur mathématique du problème avec une remarquable densité. La clean room Noogram a retrouvé indépendamment le même cœur, puis l'a transformé en carte de recherche : équivalences formelles, expériences reproductibles, routes mortes démontrées, bibliographie auditée, objections et conditions de reprise.

La valeur de Noogram n'est donc pas de remplacer l'intuition rapide d'un grand modèle. Elle est de la rendre cumulative. Le meilleur système combine les deux : des modèles différents explorent indépendamment, se critiquent mutuellement, puis déposent leurs résultats dans une trace où un humain ou un futur agent peut reprendre le travail sans repartir de zéro.

## 9. Artefacts audités

Sauf mention contraire, chaque artefact ci-dessous est **publiquement vérifiable** : les références `firoozbakht-cleanroom@6664094` résolvent sur `main` de [`noogram-labs/firoozbakht-cleanroom`](https://github.com/noogram-labs/firoozbakht-cleanroom).

- Benchmark Codex — **public** : [`noogram-labs/firoozbakht:runs/2026-07-24-full-lane/codex-solo-attack.md`](https://github.com/noogram-labs/firoozbakht/blob/main/runs/2026-07-24-full-lane/codex-solo-attack.md) (octet pour octet identique à l'`attack.md` d'origine ; le dépôt public ayant été reconstruit sur une racine orpheline, le hash de rédaction `89715c2` n'y existe pas et ne peut donc pas servir de référence)
- État du benchmark (molécule `task-20260724-f632`) — **privé**, non publiquement vérifiable : il vit dans l'état cosmon de la galaxie d'origine, qui n'est pas publié. Les affirmations de la §1.1 qui en dépendent (modèle observé, horodatage, durée) reposent sur cette source privée.
- Décomposition clean room : `firoozbakht-cleanroom@6664094:attack/decompose.md`
- Synthèse clean room : `firoozbakht-cleanroom@6664094:attack/synthesis.md`
- Rapport Lean : `firoozbakht-cleanroom@6664094:attack/lean-probe-report.md`
- Registre de sources : `firoozbakht-cleanroom@6664094:attack/source-ledger.md`
- Evidence gate : `firoozbakht-cleanroom@6664094:attack/evidence-verdict.md`
- Citation gate : `firoozbakht-cleanroom@6664094:attack/verification-report.md`
- Verdict éditorial : `firoozbakht-cleanroom@6664094:attack/editorial-verdict.md`
- Article clean room : `firoozbakht-cleanroom@6664094:paper/paper.tex`

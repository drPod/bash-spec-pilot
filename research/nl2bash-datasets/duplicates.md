# Measured duplicates across NL→Bash datasets

Every claim below was measured, not read off a dataset card: each dataset's command column was
extracted from its Parquet export, whitespace-normalized, MD5-hashed, and compared by containment
(`|A ∩ B| / |A|`) and Jaccard. Where a dataset is too large to download whole, the figure comes
from a sample and is marked as such.

## Your two existing flags — both confirmed

| Flag on the sheet | Verdict | Measurement |
|---|---|---|
| `TRamesh2/NL2CMD` = copy of NL2Bash | **CONFIRMED** | 89% of its commands are in NL2Bash |
| `Romit2004/LinuxCommands` = copy of NL2CMD-Fu | **CONFIRMED** | 17,450 rows, exactly NL2CMD-Fu; also 73% ⊆ NL2SH-ALFA |

## New duplicate affecting a row already on the sheet

**`yogeshm/text_to_bash` (row 6) is 99% ⊆ NL2SH-ALFA.** 124 rows / 100 unique commands, essentially
all of which already appear in NL2SH-ALFA. It should be marked derived rather than counted as an
independent 124-example set.

**`westenfelder/InterCode-Corrections` (row 7) — the count on the sheet is wrong for the HF copy.**
The HuggingFace dataset has **193 rows, not 600**, and is 100% ⊆ NL2SH-ALFA. The real 600-pair /
300-task set lives in the `InterCode-ALFA` GitHub repo at
`src/icalfa/assets/datasets/nl2bash_fs_1..5.json`. Use the GitHub source if you want the 600.

## Duplicate clusters found

### The 6× "LinLM" cluster — identical files, six uploaders
Jaccard = 1.00 between all pairs; 5,451 unique commands each; every one reports 71,775 rows, so
each file is also ~13× internally duplicated.

- `missvector/linux-commands`
- `Rendra8631/linux-commands`
- `amechanicus/linux-commands`
- `chowmean/linux-commands`
- `jasmar2/linux-commands`
- `shantoislamdev/linux-commands`

Keep at most one, and count it as **5,451**, not 71,775.

### NL2Bash re-uploads and translations
- `jiacheng-ye/nl2bash` ≡ `GWHed/nl2bash` — identical, 7,559 unique. Note this is the *filtered*
  NL2Bash (9,305 pairs), not the raw 12,609 on your sheet.
- `rlawltjd/korean-nl2bash` — 100% ⊆ NL2Bash. Korean translation of the NL side only; the commands
  are unchanged.
- `AryaYT/nl2shell-training-v3` — 59% ⊆ NL2Bash, 65% ⊆ TRamesh2/NL2CMD. ~35% novel.
- `AnishJoshi/nl2bash-custom` — a **merge, and it is the containing set**. It holds all 8,513 of
  `TRamesh2/NL2CMD`, 7,558 of NL2Bash's 7,559, and all 6,381 of `rlawltjd/korean-nl2bash`. Of its
  12,659 unique commands, roughly 4,100 appear in none of the seven reference corpora. Reading it
  the other way (60% ⊆ NL2Bash, 67% ⊆ NL2CMD, 57% ⊆ NL2SH-ALFA) understates it: pick this one and
  you already have NL2CMD, NL2Bash and korean-nl2bash in full.
- `epinnock/intercode-nl2bash-curated` — 60% ⊆ NL2SH-ALFA.

### NL2SH-ALFA re-formats
- `abandonedmonk/NL2SH-ALPACA` — 99% ⊆ NL2SH-ALFA (40,579 vs 40,544 unique). Alpaca-format reformat.

### Documented merges (not new data)
- `Mitchins/NL-SHELL-MULTI` (78,768 rows / 63,862 unique) — its card documents it as NL2Bash +
  tldr-pages + NL2SH-ALFA. Hashing confirms it fully contains `jiacheng-ye/nl2bash` (7,559),
  `TRamesh2/NL2CMD` (8,513), and `rlawltjd/korean-nl2bash`.

### BashBench subsets
- `AISafety-Student/labeled-bashBench` — all 100 of its tasks are inside
  `Eccentricity/bashbench2` (637). A labelled 100-task slice, not a separate task set.

### Terminal-Bench and Nemotron re-uploads
- `XUO/terminal-bench` ≡ `ia03/terminal-bench` (112 rows each, identical).
- `nvidia/Nemotron-Terminal-Corpus` re-uploaded verbatim by `CathleenTico/`, `txchmechanicus/`,
  `nick007x/`, and `laion/nemotron-terminal-corpus-unified*`.

## What NL2SH-ALFA is actually made of

Measured containment of NL2SH-ALFA in each root corpus: **16% ⊆ NL2Bash, 31% ⊆ NL2CMD-Fu,
4% ⊆ tldr-pages** — so roughly half of it is recycled from the other three rows already on your
sheet, and about half is new.

## The ecosystem-level finding

Most HuggingFace "bash" datasets descend from just **three root corpora**: NL2Bash, NL2CMD-Fu, and
tldr-pages. Of the large sets surveyed, only these were measured to have **~0% overlap** with all
three, i.e. genuinely independent data:

| Dataset | Size | Source |
|---|---|---|
| `saurabh5/rlvr-code-data-bash` | 66,624 bash solutions, 100% multi-line, with test cases | synthetic/translated, RLVR |
| `ajibawa-2023/Shell-Code-Large` | 639,183 rows, 98.4% multi-line | real GitHub shell scripts |
| `b-mc2/cli-commands-explained` | 16,098 (15,679 unique) | commandlinefu.com |
| `adeelahmad/bash-agent-grpo-pairs` | 11,745, 46.2% multi-line | synthetic |
| `jragsdale1/ShIO-bash-26.1` | 4.8M command→output rows | ShIOEnv execution traces |

## Not duplicates — but do not add these as NL→Bash sets

- `harpomaxx/unix-commands` (100) and `mrheinen/linux-commands` (481) are *"you are a Unix terminal,
  produce the OUTPUT"* datasets — command → simulated stdout, the inverse of what we want.
- `Euroswarms/bash` advertises **1,000,000 rows** but a 483,553-row sample contains only **4,618
  unique responses**, and those responses are fragments of the Bash reference manual
  (e.g. `'${FUNCNAME[$i]}'`, `'job table (see Job Control Builtins) or suppress sending.'`).
  The headline number is meaningless.
- `CmdCaliper` / `CyPHER` (EMNLP 2024) is command↔command similarity, not NL→command.

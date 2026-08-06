"""Near-duplicate leakage scan for BashBench 2026's multi-line half.

The audit found 0 byte-identical multi-line tasks in the released training sets. But a
paraphrased task leaks just as effectively and is invisible to hashing. This asks: how close
is each held-out multi-line task to its nearest training-set neighbour, and is that closer
than training items are to *each other*?

Controls, in order of importance:
  POSITIVE  single-line benchmark prompts vs sft_command -- 709 are known byte-identical, so
            they must come back at ~1.0. If they don't, the retriever is broken.
  CLEAN REF the 64 known-clean single-line prompts -- the distribution a genuinely held-out
            task should produce, through this exact pipeline.
  SIBLING   hold-one-out nearest neighbour *within* the SFT script set. Both the eval tasks and
            the SFT scripts were emitted by the same generator with the same instruction
            string and the same <think> format, so they are stylistically identical by
            construction. This is the number that says what "same pipeline, different task"
            looks like -- without it, any similarity reading is meaningless.
  NULL      multi-line prompts vs sft_command prompts (same domain, different task type).
"""
import json, re, sys
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel

norm = lambda s: " ".join((s or "").split())


def code_of(output):
    """Reference script out of the <think>...</think> + fenced-block answer format."""
    t = re.sub(r"<think>.*?</think>", "", output or "", flags=re.S)
    m = re.search(r"```(?:bash|sh|shell)?\s*\n(.*?)```", t, re.S)
    if m:
        return m.group(1).strip()
    return t.strip()


def best_neighbour(queries, corpus, analyzer="word", ngram=(1, 2), self_exclude=False):
    """Max cosine similarity of each query against the corpus, TF-IDF."""
    vec = TfidfVectorizer(analyzer=analyzer, ngram_range=ngram, min_df=1, sublinear_tf=True)
    X = vec.fit_transform(corpus + queries)
    C, Q = X[:len(corpus)], X[len(corpus):]
    out = np.empty(len(queries))
    for i in range(0, len(queries), 256):          # block, keeps memory bounded
        S = linear_kernel(Q[i:i + 256], C)
        if self_exclude:                            # hold-one-out: kill the identity hit
            for r in range(S.shape[0]):
                S[r, i + r] = -1.0
        out[i:i + 256] = S.max(axis=1)
    return out


def describe(label, arr, n_show=(50, 90, 95, 99)):
    a = np.asarray(arr)
    q = ", ".join(f"p{p}={np.percentile(a, p):.3f}" for p in n_show)
    print(f"  {label:<46s} n={len(a):>5d}  mean={a.mean():.3f}  max={a.max():.3f}  {q}")
    return a


ml_eval = json.load(open("extract/data__evaluation__script__evaluation_multi-line_script.json"))
sl_eval = json.load(open("extract/data__evaluation__command__evaluation_single-line_command.json"))
sft_cmd = json.load(open("extract/data__sft__sft_command.json"))
sft_scr = json.load(open("extract/data__sft__sft_script.json"))
grpo_scr = json.load(open("extract/data__grpo__grpo_script.json"))

scored = [r for r in json.load(open("testres/singleline_eval_20251222_022036.json"))
          if r.get("has_test_script")]
SFT_CMD_PROMPTS = {norm(r.get("input", "")) for r in sft_cmd}

sl_leaked = [norm(r["input_task"]) for r in scored if norm(r["input_task"]) in SFT_CMD_PROMPTS]
sl_clean = sorted({norm(r["input_task"]) for r in scored if norm(r["input_task"]) not in SFT_CMD_PROMPTS})

ml_prompts = [norm(r["input"]) for r in ml_eval]
ml_code = [code_of(r["output"]) for r in ml_eval]
scr_prompts = [norm(r["input"]) for r in sft_scr] + [norm(r["input"]) for r in grpo_scr]
scr_code = [code_of(r["output"]) for r in sft_scr] + [code_of(r["output"]) for r in grpo_scr]
cmd_prompts = [norm(r.get("input", "")) for r in sft_cmd]

print(f"corpora: {len(ml_prompts)} multi-line eval | {len(scr_prompts)} script train "
      f"(sft {len(sft_scr)} + grpo {len(grpo_scr)}) | {len(cmd_prompts)} command train")
print(f"single-line controls: {len(sl_leaked)} leaked records, {len(sl_clean)} distinct clean prompts\n")

print("=" * 100)
print("PROMPT SIDE -- nearest training-set neighbour, TF-IDF word 1-2gram cosine")
print("=" * 100)
res = {}
res["ctrl_pos"] = describe("POSITIVE CONTROL leaked single-line vs sft_command",
                           best_neighbour(sl_leaked[:400], cmd_prompts))
res["ctrl_clean"] = describe("CLEAN REFERENCE  clean single-line vs sft_command",
                             best_neighbour(sl_clean, cmd_prompts))
res["sibling"] = describe("SIBLING CONTROL  sft_script vs other sft_script (hold-one-out)",
                          best_neighbour(scr_prompts[:1500], scr_prompts[:1500], self_exclude=True))
res["null"] = describe("NULL CONTROL     multi-line eval vs sft_command",
                       best_neighbour(ml_prompts, cmd_prompts))
res["test"] = describe("TEST             multi-line eval vs script train",
                       best_neighbour(ml_prompts, scr_prompts))

print("\n" + "=" * 100)
print("CODE SIDE -- nearest training-set neighbour, char 5-gram cosine (robust to renaming)")
print("=" * 100)
res["code_sibling"] = describe("SIBLING CONTROL  sft_script code vs other sft_script code",
                               best_neighbour(scr_code[:1200], scr_code[:1200],
                                              analyzer="char_wb", ngram=(5, 5), self_exclude=True))
res["code_test"] = describe("TEST             multi-line eval code vs script train code",
                            best_neighbour(ml_code, scr_code, analyzer="char_wb", ngram=(5, 5)))

print("\n" + "=" * 100)
print("VERDICT")
print("=" * 100)
sib_p95 = np.percentile(res["sibling"], 95)
over = (res["test"] > sib_p95).sum()
print(f"  sibling p95 (same generator, different task) = {sib_p95:.3f}")
print(f"  multi-line eval tasks above that threshold   = {over}/{len(res['test'])} "
      f"= {100*over/len(res['test']):.1f}%   (expected by chance if clean: 5%)")
csib_p95 = np.percentile(res["code_sibling"], 95)
cover = (res["code_test"] > csib_p95).sum()
print(f"  code-side sibling p95                        = {csib_p95:.3f}")
print(f"  multi-line eval code above that threshold    = {cover}/{len(res['code_test'])} "
      f"= {100*cover/len(res['code_test']):.1f}%")

json.dump({k: v.tolist() for k, v in res.items()}, open("neardup.json", "w"))
print("\nwrote neardup.json")

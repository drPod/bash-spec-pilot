# Source provenance

- Aaron-supplied `benchmarks.csv` and `astrogator_data.tgz`: byte-preserved in
  `data/source/`; hashes are in `corpus-audit.json`. Redistribution permission is not
  inferred; this working copy remains local.
- [Astrogator implementation](https://github.com/counc009/state_based/tree/7c62afa51986d87033af5112cdccd3b104b1c120):
  the pinned commit supplies the actual FQL parser, semantic analyzer, knowledge base,
  module definitions, verifier and preprocessing/evaluation drivers. A git archive is retained.
- Local papers: `../../../POPL_2027_Astrogator.pdf` and
  `../../../literature/councilman_2025_astrogator.pdf`. Earlier conversation cited the latter;
  implementation conclusions here are based on the pinned code and actual runs.
- [Ansible copy module](https://docs.ansible.com/projects/ansible/13/collections/ansible/builtin/copy_module.html),
  [user module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/user_module.html),
  [lineinfile module](https://docs.ansible.com/projects/ansible/latest/collections/ansible/builtin/lineinfile_module.html):
  consulted while designing preservation, ownership and configuration cases. Actual
  validation uses the installed, recorded Ansible core version, not an assumed docs version.
- [llama.cpp server documentation](https://github.com/ggml-org/llama.cpp/tree/master/tools/server):
  HTTP requests, grammar-based sampling, JSON response format and JSON schema parameters.
  Recorded requests and responses are the evidence of what the installed build accepted.
- [OCaml String interface](https://github.com/ocaml/ocaml/blob/trunk/stdlib/string.mli):
  `includes`, `find_first`, `replace_all` are documented as 5.5 additions. The three
  local 5.3 compatibility implementations follow substring/offset behavior and are
  exercised by 678 bounded independent comparisons. No full equivalence proof is claimed.

Documentation was consulted on 2026-09-24. Mutable documentation URLs are explanatory
references, not substitutes for pinned executable artifacts and version records.

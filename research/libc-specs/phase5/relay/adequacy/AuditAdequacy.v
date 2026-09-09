(* Assumption audit for the adequacy layer.  Expected: every theorem depends only
   on the standard axioms already used by VST/CompCert (Classical_Prop.classic,
   prop_ext, functional_extensionality_dep, eq_rect_eq, Extensionality_Ensembles,
   sig_not_dec/sig_forall_dec) plus, for relay_dry_safety, its explicit premise
   Jsub (a quantified hypothesis of the theorem, printed by Check, not an axiom).
   Any axiom named after a project lemma would indicate an Admitted. *)
Require Import Dry Safety.

Check Dry.relay_dry_spec.
Check Dry.dessicate.
Check Dry.inflate_store_VALspec_range.
Check Dry.inflate_store_data_at_.
Check Dry.juicy_dry_specs.
Check Dry.dry_spec_mem.
Check Safety.init_mem_exists.
Check Safety.relay_dry_safety.

Print Assumptions Dry.inflate_store_VALspec_range.
Print Assumptions Dry.inflate_store_data_at_.
Print Assumptions Dry.juicy_dry_specs.
Print Assumptions Dry.dry_spec_mem.
Print Assumptions Safety.init_mem_exists.
Print Assumptions Safety.relay_dry_safety.

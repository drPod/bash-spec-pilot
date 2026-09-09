(* PipeRR (a two-stage `relay | relay`-shaped pipeline) as ONE MORE atom of
   Shell.v's generic `command`/`exec`, exactly as `ratom` in Redirect.v adds
   `Redirect`. `command_refines`/`query_transfer` (Shell.v, unchanged,
   universally quantified over the atom/state types) therefore already cover
   any `seq`/`and_then`/`or_else` composition of `PipeRR` with ordinary relay
   atoms; nothing new is proved for composition, only applied.

   The producer side reads from the SAME ambient stdin the rest of the shell
   state was already tracking (`os s`); the consumer side writes to the same
   ambient stdout (`delivered (os s)` is extended). The consumer's own
   write-schedule is a fresh existential: which real downstream fd calls
   happen and how they are chunked is not part of the ambient relay state,
   exactly as the relay's own `pending`/schedule are existentially hidden by
   `relay_spec`'s postcondition (Specs.v). `pipe_prim` hardwires pipefail
   OFF (`pipeline_status false`, i.e. bash's default): the pipeline's exit
   status is `rc`, the CONSUMER's status, never the producer's. *)
From Coq Require Import List ZArith Lia.
From compcert Require Import Integers.
Require Import VST.zlist.sublist.
Require Import Protocol Reach ReachExamples Conservation Shell Pipeline.
Import ListNotations RelayProtocol RelayReach RelayConservation
  ShellComposition ShellPipeline.
Local Open Scope Z_scope.

Module ShellPipeBridge.

Inductive atom2 := FromShell (a : atom) | PipeRR.

Definition pipe_prim : primitive atom2 shell_state := fun a s rc t =>
  match a with
  | FromShell a0 => relay_prim a0 s rc t
  | PipeRR =>
      exists cons_writes fuel,
        let pw0 := PWorld (os s) [] None [] [] (World [] [] [] cons_writes 0%nat 0%nat) None [] in
        let pwF := prun fuel pw0 in
        pw_buf pwF = [] /\ pw_prod_status pwF <> None /\ pw_cons_status pwF = Some rc /\
        t = ShellState
              (World (unread (pw_producer pwF)) (delivered (os s) ++ delivered (pw_consumer pwF))
                     (reads (pw_producer pwF)) (writes (os s))
                     (read_calls (pw_producer pwF)) (write_calls (os s)))
              (lost s ++ pw_prod_lost pwF ++ pw_cons_lost pwF)
  end.

Definition command2 := command atom2.
Definition exec2 := exec pipe_prim.
Definition pipe_command_refines := @command_refines atom2.
Definition pipe_query_transfer := @query_transfer atom2.

(* `PipeRR ; mark` from the SAME stdin as `demo_pw0` (Pipeline.v: "abcdef",
   PIPE_CAP = 4): every byte crosses the internal 4-byte-capped buffer (not a
   naive whole-stream handoff, per Pipeline.v's backpressure example) and the
   result is exactly the bytes the pipeline delivered, then the mark byte. *)
Example pipe_then_mark_exec :
  exec pipe_prim (and_then (call PipeRR) (call (FromShell (Mark bang))))
    (ShellState demo_producer0 []) 0
    (ShellState (deliver
                   (World (unread (pw_producer (prun 20 demo_pw0)))
                     (delivered demo_producer0 ++ delivered (pw_consumer (prun 20 demo_pw0)))
                     (reads (pw_producer (prun 20 demo_pw0))) (writes demo_producer0)
                     (read_calls (pw_producer (prun 20 demo_pw0))) (write_calls demo_producer0))
                   bang) []).
Proof.
  eapply exec_and_zero.
  - apply exec_call. exists [], 20%nat. vm_compute. repeat split; (reflexivity || discriminate).
  - apply exec_call. vm_compute. repeat split; reflexivity.
Qed.

End ShellPipeBridge.

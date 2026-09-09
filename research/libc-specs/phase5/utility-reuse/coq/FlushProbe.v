Ltac loop := loop.
Goal True.
idtac "MARK_BEFORE".
loop.
idtac "MARK_AFTER".
Qed.

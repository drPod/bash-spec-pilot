import ClightSubset

/-!
# RelayClightDump: GENERATED, do not edit.
Source: CompCert 3.15 `clightgen -normalize` output `relay.v` for phase2/relay.c
  relay.v sha256 ce8c381c0027a227102e47605c274d8711e72fbf8d3c75d261d1e456fc0ab687
Generator: clight_to_lean.py sha256 75755153f30b7f8e8045c791582ae3b7027ccb8a4743017f6815010147ecc5ed
Constructor-for-constructor translation of `Definition f_relay`; `swhile` is CompCert's
definition of `Swhile`. Identifiers are the Clight idents' string names (`_t'1`/`_t'2` are
CompCert temporaries 128/129). -/

namespace RelayClightDump
open ClightSubset

def fRelay : Func :=
  { ret := .tint
    vars := [("buf", (.tarray .tuchar 32))]
    temps := [("n", .tlong), ("w", .tlong), ("off", .tulong), ("t'2", .tlong), ("t'1", .tlong)]
    body :=
    (.sloop
      (.ssequence
        .sskip
        (.ssequence
          (.ssequence
            (.scall (some "t'1") (.evar "read" (.tfunction [.tint, (.tptr .tvoid), .tulong] .tlong)) [(.econst_int 0 .tint), (.evar "buf" (.tarray .tuchar 32)), (.econst_int 32 .tint)])
            (.sset "n" (.etempvar "t'1" .tlong)))
          (.ssequence
            (.sifthenelse (.ebinop .olt (.etempvar "n" .tlong) (.econst_int 0 .tint) .tint)
              (.sreturn (some (.econst_int 1 .tint)))
              .sskip)
            (.ssequence
              (.sifthenelse (.ebinop .oeq (.etempvar "n" .tlong) (.econst_int 0 .tint) .tint)
                (.sreturn (some (.econst_int 0 .tint)))
                .sskip)
              (.ssequence
                (.sset "off" (.ecast (.econst_int 0 .tint) .tulong))
                (swhile (.ebinop .olt (.etempvar "off" .tulong) (.ecast (.etempvar "n" .tlong) .tulong) .tint)
                  (.ssequence
                    (.ssequence
                      (.scall (some "t'2") (.evar "write" (.tfunction [.tint, (.tptr .tvoid), .tulong] .tlong)) [(.econst_int 1 .tint), (.ebinop .oadd (.evar "buf" (.tarray .tuchar 32)) (.etempvar "off" .tulong) (.tptr .tuchar)), (.ebinop .osub (.ecast (.etempvar "n" .tlong) .tulong) (.etempvar "off" .tulong) .tulong)])
                      (.sset "w" (.etempvar "t'2" .tlong)))
                    (.ssequence
                      (.sifthenelse (.ebinop .ole (.etempvar "w" .tlong) (.econst_int 0 .tint) .tint)
                        (.sreturn (some (.econst_int 2 .tint)))
                        .sskip)
                      (.sset "off" (.ebinop .oadd (.etempvar "off" .tulong) (.ecast (.etempvar "w" .tlong) .tulong) .tulong))))))))))
      .sskip) }

end RelayClightDump

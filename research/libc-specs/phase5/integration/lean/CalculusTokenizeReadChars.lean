/- CalculusTokenizeReadChars leaves + right-spine concat (tokenizer-relay-read-115) -/
import CalculusTokenizeFull
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
namespace CalculusTokenizeReadChars
set_option maxRecDepth 100000
def calculustokenizereadchars_p0 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t0 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p0_tok : tokenizeT 5 calculustokenizereadchars_p0 = some calculustokenizereadchars_t0 := by
  decide +kernel
def calculustokenizereadchars_p1 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizereadchars_t1 : List String := ["(", "assign"]
theorem calculustokenizereadchars_p1_tok : tokenizeT 8 calculustokenizereadchars_p1 = some calculustokenizereadchars_t1 := by
  decide +kernel
def calculustokenizereadchars_p2 : List Char := ['b']
def calculustokenizereadchars_t2 : List String := ["b"]
theorem calculustokenizereadchars_p2_tok : tokenizeT 2 calculustokenizereadchars_p2 = some calculustokenizereadchars_t2 := by
  decide +kernel
def calculustokenizereadchars_p3 : List Char := [Char.ofNat 953, ')']
def calculustokenizereadchars_t3 : List String := ["ι", ")"]
theorem calculustokenizereadchars_p3_tok : tokenizeT 3 calculustokenizereadchars_p3 = some calculustokenizereadchars_t3 := by
  decide +kernel
def calculustokenizereadchars_p4 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t4 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p4_tok : tokenizeT 5 calculustokenizereadchars_p4 = some calculustokenizereadchars_t4 := by
  decide +kernel
def calculustokenizereadchars_p5 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t5 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p5_tok : tokenizeT 5 calculustokenizereadchars_p5 = some calculustokenizereadchars_t5 := by
  decide +kernel
def calculustokenizereadchars_p6 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t6 : List String := ["(", "get"]
theorem calculustokenizereadchars_p6_tok : tokenizeT 5 calculustokenizereadchars_p6 = some calculustokenizereadchars_t6 := by
  decide +kernel
def calculustokenizereadchars_p7 : List Char := ['$', 't', '1']
def calculustokenizereadchars_t7 : List String := ["$t1"]
theorem calculustokenizereadchars_p7_tok : tokenizeT 4 calculustokenizereadchars_p7 = some calculustokenizereadchars_t7 := by
  decide +kernel
def calculustokenizereadchars_p8 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t8 : List String := ["σ"]
theorem calculustokenizereadchars_p8_tok : tokenizeT 2 calculustokenizereadchars_p8 = some calculustokenizereadchars_t8 := by
  decide +kernel
def calculustokenizereadchars_p9 : List Char := ['r', 'e', 'a', 'd', 's', ')']
def calculustokenizereadchars_t9 : List String := ["reads", ")"]
theorem calculustokenizereadchars_p9_tok : tokenizeT 7 calculustokenizereadchars_p9 = some calculustokenizereadchars_t9 := by
  decide +kernel
def calculustokenizereadchars_p10 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t10 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p10_tok : tokenizeT 5 calculustokenizereadchars_p10 = some calculustokenizereadchars_t10 := by
  decide +kernel
def calculustokenizereadchars_p11 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t11 : List String := ["(", "get"]
theorem calculustokenizereadchars_p11_tok : tokenizeT 5 calculustokenizereadchars_p11 = some calculustokenizereadchars_t11 := by
  decide +kernel
def calculustokenizereadchars_p12 : List Char := ['$', 't', '2']
def calculustokenizereadchars_t12 : List String := ["$t2"]
theorem calculustokenizereadchars_p12_tok : tokenizeT 4 calculustokenizereadchars_p12 = some calculustokenizereadchars_t12 := by
  decide +kernel
def calculustokenizereadchars_p13 : List Char := ['b']
def calculustokenizereadchars_t13 : List String := ["b"]
theorem calculustokenizereadchars_p13_tok : tokenizeT 2 calculustokenizereadchars_p13 = some calculustokenizereadchars_t13 := by
  decide +kernel
def calculustokenizereadchars_p14 : List Char := ['c', 'a', 'p', ')']
def calculustokenizereadchars_t14 : List String := ["cap", ")"]
theorem calculustokenizereadchars_p14_tok : tokenizeT 5 calculustokenizereadchars_p14 = some calculustokenizereadchars_t14 := by
  decide +kernel
def calculustokenizereadchars_p15 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizereadchars_t15 : List String := ["(", "assign"]
theorem calculustokenizereadchars_p15_tok : tokenizeT 8 calculustokenizereadchars_p15 = some calculustokenizereadchars_t15 := by
  decide +kernel
def calculustokenizereadchars_p16 : List Char := ['q']
def calculustokenizereadchars_t16 : List String := ["q"]
theorem calculustokenizereadchars_p16_tok : tokenizeT 2 calculustokenizereadchars_p16 = some calculustokenizereadchars_t16 := by
  decide +kernel
def calculustokenizereadchars_p17 : List Char := ['(', 'h', 'e', 'a', 'd', '_', 'o', 'r']
def calculustokenizereadchars_t17 : List String := ["(", "head_or"]
theorem calculustokenizereadchars_p17_tok : tokenizeT 9 calculustokenizereadchars_p17 = some calculustokenizereadchars_t17 := by
  decide +kernel
def calculustokenizereadchars_p18 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t18 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p18_tok : tokenizeT 6 calculustokenizereadchars_p18 = some calculustokenizereadchars_t18 := by
  decide +kernel
def calculustokenizereadchars_p19 : List Char := ['$', 't', '1']
def calculustokenizereadchars_t19 : List String := ["$t1"]
theorem calculustokenizereadchars_p19_tok : tokenizeT 4 calculustokenizereadchars_p19 = some calculustokenizereadchars_t19 := by
  decide +kernel
def calculustokenizereadchars_p20 : List Char := ['$', 't', '2', ')', ')', ')', ')', ')']
def calculustokenizereadchars_t20 : List String := ["$t2", ")", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p20_tok : tokenizeT 9 calculustokenizereadchars_p20 = some calculustokenizereadchars_t20 := by
  decide +kernel
def calculustokenizereadchars_p21 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t21 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p21_tok : tokenizeT 5 calculustokenizereadchars_p21 = some calculustokenizereadchars_t21 := by
  decide +kernel
def calculustokenizereadchars_p22 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t22 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p22_tok : tokenizeT 5 calculustokenizereadchars_p22 = some calculustokenizereadchars_t22 := by
  decide +kernel
def calculustokenizereadchars_p23 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t23 : List String := ["(", "get"]
theorem calculustokenizereadchars_p23_tok : tokenizeT 5 calculustokenizereadchars_p23 = some calculustokenizereadchars_t23 := by
  decide +kernel
def calculustokenizereadchars_p24 : List Char := ['$', 't', '3']
def calculustokenizereadchars_t24 : List String := ["$t3"]
theorem calculustokenizereadchars_p24_tok : tokenizeT 4 calculustokenizereadchars_p24 = some calculustokenizereadchars_t24 := by
  decide +kernel
def calculustokenizereadchars_p25 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t25 : List String := ["σ"]
theorem calculustokenizereadchars_p25_tok : tokenizeT 2 calculustokenizereadchars_p25 = some calculustokenizereadchars_t25 := by
  decide +kernel
def calculustokenizereadchars_p26 : List Char := ['r', 'e', 'a', 'd', 's', ')']
def calculustokenizereadchars_t26 : List String := ["reads", ")"]
theorem calculustokenizereadchars_p26_tok : tokenizeT 7 calculustokenizereadchars_p26 = some calculustokenizereadchars_t26 := by
  decide +kernel
def calculustokenizereadchars_p27 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizereadchars_t27 : List String := ["(", "set-attr"]
theorem calculustokenizereadchars_p27_tok : tokenizeT 10 calculustokenizereadchars_p27 = some calculustokenizereadchars_t27 := by
  decide +kernel
def calculustokenizereadchars_p28 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t28 : List String := ["σ"]
theorem calculustokenizereadchars_p28_tok : tokenizeT 2 calculustokenizereadchars_p28 = some calculustokenizereadchars_t28 := by
  decide +kernel
def calculustokenizereadchars_p29 : List Char := ['r', 'e', 'a', 'd', 's']
def calculustokenizereadchars_t29 : List String := ["reads"]
theorem calculustokenizereadchars_p29_tok : tokenizeT 6 calculustokenizereadchars_p29 = some calculustokenizereadchars_t29 := by
  decide +kernel
def calculustokenizereadchars_p30 : List Char := ['(', 't', 'a', 'i', 'l']
def calculustokenizereadchars_t30 : List String := ["(", "tail"]
theorem calculustokenizereadchars_p30_tok : tokenizeT 6 calculustokenizereadchars_p30 = some calculustokenizereadchars_t30 := by
  decide +kernel
def calculustokenizereadchars_p31 : List Char := ['$', 't', '3', ')', ')', ')']
def calculustokenizereadchars_t31 : List String := ["$t3", ")", ")", ")"]
theorem calculustokenizereadchars_p31_tok : tokenizeT 7 calculustokenizereadchars_p31 = some calculustokenizereadchars_t31 := by
  decide +kernel
def calculustokenizereadchars_p32 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t32 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p32_tok : tokenizeT 5 calculustokenizereadchars_p32 = some calculustokenizereadchars_t32 := by
  decide +kernel
def calculustokenizereadchars_p33 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t33 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p33_tok : tokenizeT 5 calculustokenizereadchars_p33 = some calculustokenizereadchars_t33 := by
  decide +kernel
def calculustokenizereadchars_p34 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t34 : List String := ["(", "get"]
theorem calculustokenizereadchars_p34_tok : tokenizeT 5 calculustokenizereadchars_p34 = some calculustokenizereadchars_t34 := by
  decide +kernel
def calculustokenizereadchars_p35 : List Char := ['$', 't', '4']
def calculustokenizereadchars_t35 : List String := ["$t4"]
theorem calculustokenizereadchars_p35_tok : tokenizeT 4 calculustokenizereadchars_p35 = some calculustokenizereadchars_t35 := by
  decide +kernel
def calculustokenizereadchars_p36 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t36 : List String := ["σ"]
theorem calculustokenizereadchars_p36_tok : tokenizeT 2 calculustokenizereadchars_p36 = some calculustokenizereadchars_t36 := by
  decide +kernel
def calculustokenizereadchars_p37 : List Char := ['r', 'e', 'a', 'd', '_', 'c', 'a', 'l', 'l', 's', ')']
def calculustokenizereadchars_t37 : List String := ["read_calls", ")"]
theorem calculustokenizereadchars_p37_tok : tokenizeT 12 calculustokenizereadchars_p37 = some calculustokenizereadchars_t37 := by
  decide +kernel
def calculustokenizereadchars_p38 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizereadchars_t38 : List String := ["(", "set-attr"]
theorem calculustokenizereadchars_p38_tok : tokenizeT 10 calculustokenizereadchars_p38 = some calculustokenizereadchars_t38 := by
  decide +kernel
def calculustokenizereadchars_p39 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t39 : List String := ["σ"]
theorem calculustokenizereadchars_p39_tok : tokenizeT 2 calculustokenizereadchars_p39 = some calculustokenizereadchars_t39 := by
  decide +kernel
def calculustokenizereadchars_p40 : List Char := ['r', 'e', 'a', 'd', '_', 'c', 'a', 'l', 'l', 's']
def calculustokenizereadchars_t40 : List String := ["read_calls"]
theorem calculustokenizereadchars_p40_tok : tokenizeT 11 calculustokenizereadchars_p40 = some calculustokenizereadchars_t40 := by
  decide +kernel
def calculustokenizereadchars_p41 : List Char := ['(', '+']
def calculustokenizereadchars_t41 : List String := ["(", "+"]
theorem calculustokenizereadchars_p41_tok : tokenizeT 3 calculustokenizereadchars_p41 = some calculustokenizereadchars_t41 := by
  decide +kernel
def calculustokenizereadchars_p42 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t42 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p42_tok : tokenizeT 6 calculustokenizereadchars_p42 = some calculustokenizereadchars_t42 := by
  decide +kernel
def calculustokenizereadchars_p43 : List Char := ['$', 't', '4']
def calculustokenizereadchars_t43 : List String := ["$t4"]
theorem calculustokenizereadchars_p43_tok : tokenizeT 4 calculustokenizereadchars_p43 = some calculustokenizereadchars_t43 := by
  decide +kernel
def calculustokenizereadchars_p44 : List Char := ['1', ')', ')', ')', ')']
def calculustokenizereadchars_t44 : List String := ["1", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p44_tok : tokenizeT 6 calculustokenizereadchars_p44 = some calculustokenizereadchars_t44 := by
  decide +kernel
def calculustokenizereadchars_p45 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t45 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p45_tok : tokenizeT 5 calculustokenizereadchars_p45 = some calculustokenizereadchars_t45 := by
  decide +kernel
def calculustokenizereadchars_p46 : List Char := ['(', 'i', 'f']
def calculustokenizereadchars_t46 : List String := ["(", "if"]
theorem calculustokenizereadchars_p46_tok : tokenizeT 4 calculustokenizereadchars_p46 = some calculustokenizereadchars_t46 := by
  decide +kernel
def calculustokenizereadchars_p47 : List Char := ['(', '<']
def calculustokenizereadchars_t47 : List String := ["(", "<"]
theorem calculustokenizereadchars_p47_tok : tokenizeT 3 calculustokenizereadchars_p47 = some calculustokenizereadchars_t47 := by
  decide +kernel
def calculustokenizereadchars_p48 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t48 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p48_tok : tokenizeT 6 calculustokenizereadchars_p48 = some calculustokenizereadchars_t48 := by
  decide +kernel
def calculustokenizereadchars_p49 : List Char := ['q']
def calculustokenizereadchars_t49 : List String := ["q"]
theorem calculustokenizereadchars_p49_tok : tokenizeT 2 calculustokenizereadchars_p49 = some calculustokenizereadchars_t49 := by
  decide +kernel
def calculustokenizereadchars_p50 : List Char := ['0', ')', ')']
def calculustokenizereadchars_t50 : List String := ["0", ")", ")"]
theorem calculustokenizereadchars_p50_tok : tokenizeT 4 calculustokenizereadchars_p50 = some calculustokenizereadchars_t50 := by
  decide +kernel
def calculustokenizereadchars_p51 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def calculustokenizereadchars_t51 : List String := ["(", "return"]
theorem calculustokenizereadchars_p51_tok : tokenizeT 8 calculustokenizereadchars_p51 = some calculustokenizereadchars_t51 := by
  decide +kernel
def calculustokenizereadchars_p52 : List Char := ['-', '1', ')']
def calculustokenizereadchars_t52 : List String := ["-1", ")"]
theorem calculustokenizereadchars_p52_tok : tokenizeT 4 calculustokenizereadchars_p52 = some calculustokenizereadchars_t52 := by
  decide +kernel
def calculustokenizereadchars_p53 : List Char := ['p', 'a', 's', 's', ')']
def calculustokenizereadchars_t53 : List String := ["pass", ")"]
theorem calculustokenizereadchars_p53_tok : tokenizeT 6 calculustokenizereadchars_p53 = some calculustokenizereadchars_t53 := by
  decide +kernel
def calculustokenizereadchars_p54 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t54 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p54_tok : tokenizeT 5 calculustokenizereadchars_p54 = some calculustokenizereadchars_t54 := by
  decide +kernel
def calculustokenizereadchars_p55 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t55 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p55_tok : tokenizeT 5 calculustokenizereadchars_p55 = some calculustokenizereadchars_t55 := by
  decide +kernel
def calculustokenizereadchars_p56 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t56 : List String := ["(", "get"]
theorem calculustokenizereadchars_p56_tok : tokenizeT 5 calculustokenizereadchars_p56 = some calculustokenizereadchars_t56 := by
  decide +kernel
def calculustokenizereadchars_p57 : List Char := ['$', 't', '5']
def calculustokenizereadchars_t57 : List String := ["$t5"]
theorem calculustokenizereadchars_p57_tok : tokenizeT 4 calculustokenizereadchars_p57 = some calculustokenizereadchars_t57 := by
  decide +kernel
def calculustokenizereadchars_p58 : List Char := ['b']
def calculustokenizereadchars_t58 : List String := ["b"]
theorem calculustokenizereadchars_p58_tok : tokenizeT 2 calculustokenizereadchars_p58 = some calculustokenizereadchars_t58 := by
  decide +kernel
def calculustokenizereadchars_p59 : List Char := ['c', 'a', 'p', ')']
def calculustokenizereadchars_t59 : List String := ["cap", ")"]
theorem calculustokenizereadchars_p59_tok : tokenizeT 5 calculustokenizereadchars_p59 = some calculustokenizereadchars_t59 := by
  decide +kernel
def calculustokenizereadchars_p60 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t60 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p60_tok : tokenizeT 5 calculustokenizereadchars_p60 = some calculustokenizereadchars_t60 := by
  decide +kernel
def calculustokenizereadchars_p61 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t61 : List String := ["(", "get"]
theorem calculustokenizereadchars_p61_tok : tokenizeT 5 calculustokenizereadchars_p61 = some calculustokenizereadchars_t61 := by
  decide +kernel
def calculustokenizereadchars_p62 : List Char := ['$', 't', '6']
def calculustokenizereadchars_t62 : List String := ["$t6"]
theorem calculustokenizereadchars_p62_tok : tokenizeT 4 calculustokenizereadchars_p62 = some calculustokenizereadchars_t62 := by
  decide +kernel
def calculustokenizereadchars_p63 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t63 : List String := ["σ"]
theorem calculustokenizereadchars_p63_tok : tokenizeT 2 calculustokenizereadchars_p63 = some calculustokenizereadchars_t63 := by
  decide +kernel
def calculustokenizereadchars_p64 : List Char := ['i', 'n', 'p', 'u', 't', ')']
def calculustokenizereadchars_t64 : List String := ["input", ")"]
theorem calculustokenizereadchars_p64_tok : tokenizeT 7 calculustokenizereadchars_p64 = some calculustokenizereadchars_t64 := by
  decide +kernel
def calculustokenizereadchars_p65 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizereadchars_t65 : List String := ["(", "assign"]
theorem calculustokenizereadchars_p65_tok : tokenizeT 8 calculustokenizereadchars_p65 = some calculustokenizereadchars_t65 := by
  decide +kernel
def calculustokenizereadchars_p66 : List Char := ['k']
def calculustokenizereadchars_t66 : List String := ["k"]
theorem calculustokenizereadchars_p66_tok : tokenizeT 2 calculustokenizereadchars_p66 = some calculustokenizereadchars_t66 := by
  decide +kernel
def calculustokenizereadchars_p67 : List Char := ['(', 'm', 'i', 'n']
def calculustokenizereadchars_t67 : List String := ["(", "min"]
theorem calculustokenizereadchars_p67_tok : tokenizeT 5 calculustokenizereadchars_p67 = some calculustokenizereadchars_t67 := by
  decide +kernel
def calculustokenizereadchars_p68 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t68 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p68_tok : tokenizeT 6 calculustokenizereadchars_p68 = some calculustokenizereadchars_t68 := by
  decide +kernel
def calculustokenizereadchars_p69 : List Char := ['(', 'm', 'a', 'x']
def calculustokenizereadchars_t69 : List String := ["(", "max"]
theorem calculustokenizereadchars_p69_tok : tokenizeT 5 calculustokenizereadchars_p69 = some calculustokenizereadchars_t69 := by
  decide +kernel
def calculustokenizereadchars_p70 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t70 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p70_tok : tokenizeT 6 calculustokenizereadchars_p70 = some calculustokenizereadchars_t70 := by
  decide +kernel
def calculustokenizereadchars_p71 : List Char := ['1']
def calculustokenizereadchars_t71 : List String := ["1"]
theorem calculustokenizereadchars_p71_tok : tokenizeT 2 calculustokenizereadchars_p71 = some calculustokenizereadchars_t71 := by
  decide +kernel
def calculustokenizereadchars_p72 : List Char := ['q', ')', ')']
def calculustokenizereadchars_t72 : List String := ["q", ")", ")"]
theorem calculustokenizereadchars_p72_tok : tokenizeT 4 calculustokenizereadchars_p72 = some calculustokenizereadchars_t72 := by
  decide +kernel
def calculustokenizereadchars_p73 : List Char := ['(', 'm', 'i', 'n']
def calculustokenizereadchars_t73 : List String := ["(", "min"]
theorem calculustokenizereadchars_p73_tok : tokenizeT 5 calculustokenizereadchars_p73 = some calculustokenizereadchars_t73 := by
  decide +kernel
def calculustokenizereadchars_p74 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t74 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p74_tok : tokenizeT 6 calculustokenizereadchars_p74 = some calculustokenizereadchars_t74 := by
  decide +kernel
def calculustokenizereadchars_p75 : List Char := ['$', 't', '5']
def calculustokenizereadchars_t75 : List String := ["$t5"]
theorem calculustokenizereadchars_p75_tok : tokenizeT 4 calculustokenizereadchars_p75 = some calculustokenizereadchars_t75 := by
  decide +kernel
def calculustokenizereadchars_p76 : List Char := ['(', 'l', 'e', 'n', 'g', 't', 'h']
def calculustokenizereadchars_t76 : List String := ["(", "length"]
theorem calculustokenizereadchars_p76_tok : tokenizeT 8 calculustokenizereadchars_p76 = some calculustokenizereadchars_t76 := by
  decide +kernel
def calculustokenizereadchars_p77 : List Char := ['$', 't', '6', ')', ')', ')', ')', ')', ')', ')', ')']
def calculustokenizereadchars_t77 : List String := ["$t6", ")", ")", ")", ")", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p77_tok : tokenizeT 12 calculustokenizereadchars_p77 = some calculustokenizereadchars_t77 := by
  decide +kernel
def calculustokenizereadchars_p78 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t78 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p78_tok : tokenizeT 5 calculustokenizereadchars_p78 = some calculustokenizereadchars_t78 := by
  decide +kernel
def calculustokenizereadchars_p79 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t79 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p79_tok : tokenizeT 5 calculustokenizereadchars_p79 = some calculustokenizereadchars_t79 := by
  decide +kernel
def calculustokenizereadchars_p80 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t80 : List String := ["(", "get"]
theorem calculustokenizereadchars_p80_tok : tokenizeT 5 calculustokenizereadchars_p80 = some calculustokenizereadchars_t80 := by
  decide +kernel
def calculustokenizereadchars_p81 : List Char := ['$', 't', '7']
def calculustokenizereadchars_t81 : List String := ["$t7"]
theorem calculustokenizereadchars_p81_tok : tokenizeT 4 calculustokenizereadchars_p81 = some calculustokenizereadchars_t81 := by
  decide +kernel
def calculustokenizereadchars_p82 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t82 : List String := ["σ"]
theorem calculustokenizereadchars_p82_tok : tokenizeT 2 calculustokenizereadchars_p82 = some calculustokenizereadchars_t82 := by
  decide +kernel
def calculustokenizereadchars_p83 : List Char := ['i', 'n', 'p', 'u', 't', ')']
def calculustokenizereadchars_t83 : List String := ["input", ")"]
theorem calculustokenizereadchars_p83_tok : tokenizeT 7 calculustokenizereadchars_p83 = some calculustokenizereadchars_t83 := by
  decide +kernel
def calculustokenizereadchars_p84 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizereadchars_t84 : List String := ["(", "set-attr"]
theorem calculustokenizereadchars_p84_tok : tokenizeT 10 calculustokenizereadchars_p84 = some calculustokenizereadchars_t84 := by
  decide +kernel
def calculustokenizereadchars_p85 : List Char := ['b']
def calculustokenizereadchars_t85 : List String := ["b"]
theorem calculustokenizereadchars_p85_tok : tokenizeT 2 calculustokenizereadchars_p85 = some calculustokenizereadchars_t85 := by
  decide +kernel
def calculustokenizereadchars_p86 : List Char := ['b', 'y', 't', 'e', 's']
def calculustokenizereadchars_t86 : List String := ["bytes"]
theorem calculustokenizereadchars_p86_tok : tokenizeT 6 calculustokenizereadchars_p86 = some calculustokenizereadchars_t86 := by
  decide +kernel
def calculustokenizereadchars_p87 : List Char := ['(', 't', 'a', 'k', 'e']
def calculustokenizereadchars_t87 : List String := ["(", "take"]
theorem calculustokenizereadchars_p87_tok : tokenizeT 6 calculustokenizereadchars_p87 = some calculustokenizereadchars_t87 := by
  decide +kernel
def calculustokenizereadchars_p88 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t88 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p88_tok : tokenizeT 6 calculustokenizereadchars_p88 = some calculustokenizereadchars_t88 := by
  decide +kernel
def calculustokenizereadchars_p89 : List Char := ['$', 't', '7']
def calculustokenizereadchars_t89 : List String := ["$t7"]
theorem calculustokenizereadchars_p89_tok : tokenizeT 4 calculustokenizereadchars_p89 = some calculustokenizereadchars_t89 := by
  decide +kernel
def calculustokenizereadchars_p90 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizereadchars_t90 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizereadchars_p90_tok : tokenizeT 29 calculustokenizereadchars_p90 = some calculustokenizereadchars_t90 := by
  decide +kernel
def calculustokenizereadchars_p91 : List Char := ['k', ')', ')', ')', ')', ')']
def calculustokenizereadchars_t91 : List String := ["k", ")", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p91_tok : tokenizeT 7 calculustokenizereadchars_p91 = some calculustokenizereadchars_t91 := by
  decide +kernel
def calculustokenizereadchars_p92 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t92 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p92_tok : tokenizeT 5 calculustokenizereadchars_p92 = some calculustokenizereadchars_t92 := by
  decide +kernel
def calculustokenizereadchars_p93 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizereadchars_t93 : List String := ["(", "set-attr"]
theorem calculustokenizereadchars_p93_tok : tokenizeT 10 calculustokenizereadchars_p93 = some calculustokenizereadchars_t93 := by
  decide +kernel
def calculustokenizereadchars_p94 : List Char := ['b']
def calculustokenizereadchars_t94 : List String := ["b"]
theorem calculustokenizereadchars_p94_tok : tokenizeT 2 calculustokenizereadchars_p94 = some calculustokenizereadchars_t94 := by
  decide +kernel
def calculustokenizereadchars_p95 : List Char := ['l', 'e', 'n']
def calculustokenizereadchars_t95 : List String := ["len"]
theorem calculustokenizereadchars_p95_tok : tokenizeT 4 calculustokenizereadchars_p95 = some calculustokenizereadchars_t95 := by
  decide +kernel
def calculustokenizereadchars_p96 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizereadchars_t96 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizereadchars_p96_tok : tokenizeT 29 calculustokenizereadchars_p96 = some calculustokenizereadchars_t96 := by
  decide +kernel
def calculustokenizereadchars_p97 : List Char := ['k', ')', ')']
def calculustokenizereadchars_t97 : List String := ["k", ")", ")"]
theorem calculustokenizereadchars_p97_tok : tokenizeT 4 calculustokenizereadchars_p97 = some calculustokenizereadchars_t97 := by
  decide +kernel
def calculustokenizereadchars_p98 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t98 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p98_tok : tokenizeT 5 calculustokenizereadchars_p98 = some calculustokenizereadchars_t98 := by
  decide +kernel
def calculustokenizereadchars_p99 : List Char := ['(', 's', 'e', 'q']
def calculustokenizereadchars_t99 : List String := ["(", "seq"]
theorem calculustokenizereadchars_p99_tok : tokenizeT 5 calculustokenizereadchars_p99 = some calculustokenizereadchars_t99 := by
  decide +kernel
def calculustokenizereadchars_p100 : List Char := ['(', 'g', 'e', 't']
def calculustokenizereadchars_t100 : List String := ["(", "get"]
theorem calculustokenizereadchars_p100_tok : tokenizeT 5 calculustokenizereadchars_p100 = some calculustokenizereadchars_t100 := by
  decide +kernel
def calculustokenizereadchars_p101 : List Char := ['$', 't', '8']
def calculustokenizereadchars_t101 : List String := ["$t8"]
theorem calculustokenizereadchars_p101_tok : tokenizeT 4 calculustokenizereadchars_p101 = some calculustokenizereadchars_t101 := by
  decide +kernel
def calculustokenizereadchars_p102 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t102 : List String := ["σ"]
theorem calculustokenizereadchars_p102_tok : tokenizeT 2 calculustokenizereadchars_p102 = some calculustokenizereadchars_t102 := by
  decide +kernel
def calculustokenizereadchars_p103 : List Char := ['i', 'n', 'p', 'u', 't', ')']
def calculustokenizereadchars_t103 : List String := ["input", ")"]
theorem calculustokenizereadchars_p103_tok : tokenizeT 7 calculustokenizereadchars_p103 = some calculustokenizereadchars_t103 := by
  decide +kernel
def calculustokenizereadchars_p104 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizereadchars_t104 : List String := ["(", "set-attr"]
theorem calculustokenizereadchars_p104_tok : tokenizeT 10 calculustokenizereadchars_p104 = some calculustokenizereadchars_t104 := by
  decide +kernel
def calculustokenizereadchars_p105 : List Char := [Char.ofNat 963]
def calculustokenizereadchars_t105 : List String := ["σ"]
theorem calculustokenizereadchars_p105_tok : tokenizeT 2 calculustokenizereadchars_p105 = some calculustokenizereadchars_t105 := by
  decide +kernel
def calculustokenizereadchars_p106 : List Char := ['i', 'n', 'p', 'u', 't']
def calculustokenizereadchars_t106 : List String := ["input"]
theorem calculustokenizereadchars_p106_tok : tokenizeT 6 calculustokenizereadchars_p106 = some calculustokenizereadchars_t106 := by
  decide +kernel
def calculustokenizereadchars_p107 : List Char := ['(', 'd', 'r', 'o', 'p']
def calculustokenizereadchars_t107 : List String := ["(", "drop"]
theorem calculustokenizereadchars_p107_tok : tokenizeT 6 calculustokenizereadchars_p107 = some calculustokenizereadchars_t107 := by
  decide +kernel
def calculustokenizereadchars_p108 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizereadchars_t108 : List String := ["(", "pair"]
theorem calculustokenizereadchars_p108_tok : tokenizeT 6 calculustokenizereadchars_p108 = some calculustokenizereadchars_t108 := by
  decide +kernel
def calculustokenizereadchars_p109 : List Char := ['$', 't', '8']
def calculustokenizereadchars_t109 : List String := ["$t8"]
theorem calculustokenizereadchars_p109_tok : tokenizeT 4 calculustokenizereadchars_p109 = some calculustokenizereadchars_t109 := by
  decide +kernel
def calculustokenizereadchars_p110 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizereadchars_t110 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizereadchars_p110_tok : tokenizeT 29 calculustokenizereadchars_p110 = some calculustokenizereadchars_t110 := by
  decide +kernel
def calculustokenizereadchars_p111 : List Char := ['k', ')', ')', ')', ')', ')']
def calculustokenizereadchars_t111 : List String := ["k", ")", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p111_tok : tokenizeT 7 calculustokenizereadchars_p111 = some calculustokenizereadchars_t111 := by
  decide +kernel
def calculustokenizereadchars_p112 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def calculustokenizereadchars_t112 : List String := ["(", "return"]
theorem calculustokenizereadchars_p112_tok : tokenizeT 8 calculustokenizereadchars_p112 = some calculustokenizereadchars_t112 := by
  decide +kernel
def calculustokenizereadchars_p113 : List Char := ['k', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')']
def calculustokenizereadchars_t113 : List String := ["k", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")"]
theorem calculustokenizereadchars_p113_tok : tokenizeT 12 calculustokenizereadchars_p113 = some calculustokenizereadchars_t113 := by
  decide +kernel
def calculustokenizereadchars_s113 : List Char := calculustokenizereadchars_p113
def calculustokenizereadchars_st113 : List String := calculustokenizereadchars_t113
theorem calculustokenizereadchars_s113_tok : tokenizeT 12 calculustokenizereadchars_s113 = some calculustokenizereadchars_st113 := calculustokenizereadchars_p113_tok
def calculustokenizereadchars_s112 : List Char := calculustokenizereadchars_p112 ++ ' ' :: calculustokenizereadchars_s113
def calculustokenizereadchars_st112 : List String := calculustokenizereadchars_t112 ++ calculustokenizereadchars_st113
theorem calculustokenizereadchars_s112_tok : tokenizeT 21 calculustokenizereadchars_s112 = some calculustokenizereadchars_st112 :=
  tokenizeT_concat_space 8 12 _ _ _ _ calculustokenizereadchars_p112_tok calculustokenizereadchars_s113_tok
def calculustokenizereadchars_s111 : List Char := calculustokenizereadchars_p111 ++ ' ' :: calculustokenizereadchars_s112
def calculustokenizereadchars_st111 : List String := calculustokenizereadchars_t111 ++ calculustokenizereadchars_st112
theorem calculustokenizereadchars_s111_tok : tokenizeT 29 calculustokenizereadchars_s111 = some calculustokenizereadchars_st111 :=
  tokenizeT_concat_space 7 21 _ _ _ _ calculustokenizereadchars_p111_tok calculustokenizereadchars_s112_tok
def calculustokenizereadchars_s110 : List Char := calculustokenizereadchars_p110 ++ ' ' :: calculustokenizereadchars_s111
def calculustokenizereadchars_st110 : List String := calculustokenizereadchars_t110 ++ calculustokenizereadchars_st111
theorem calculustokenizereadchars_s110_tok : tokenizeT 59 calculustokenizereadchars_s110 = some calculustokenizereadchars_st110 :=
  tokenizeT_concat_space 29 29 _ _ _ _ calculustokenizereadchars_p110_tok calculustokenizereadchars_s111_tok
def calculustokenizereadchars_s109 : List Char := calculustokenizereadchars_p109 ++ ' ' :: calculustokenizereadchars_s110
def calculustokenizereadchars_st109 : List String := calculustokenizereadchars_t109 ++ calculustokenizereadchars_st110
theorem calculustokenizereadchars_s109_tok : tokenizeT 64 calculustokenizereadchars_s109 = some calculustokenizereadchars_st109 :=
  tokenizeT_concat_space 4 59 _ _ _ _ calculustokenizereadchars_p109_tok calculustokenizereadchars_s110_tok
def calculustokenizereadchars_s108 : List Char := calculustokenizereadchars_p108 ++ ' ' :: calculustokenizereadchars_s109
def calculustokenizereadchars_st108 : List String := calculustokenizereadchars_t108 ++ calculustokenizereadchars_st109
theorem calculustokenizereadchars_s108_tok : tokenizeT 71 calculustokenizereadchars_s108 = some calculustokenizereadchars_st108 :=
  tokenizeT_concat_space 6 64 _ _ _ _ calculustokenizereadchars_p108_tok calculustokenizereadchars_s109_tok
def calculustokenizereadchars_s107 : List Char := calculustokenizereadchars_p107 ++ ' ' :: calculustokenizereadchars_s108
def calculustokenizereadchars_st107 : List String := calculustokenizereadchars_t107 ++ calculustokenizereadchars_st108
theorem calculustokenizereadchars_s107_tok : tokenizeT 78 calculustokenizereadchars_s107 = some calculustokenizereadchars_st107 :=
  tokenizeT_concat_space 6 71 _ _ _ _ calculustokenizereadchars_p107_tok calculustokenizereadchars_s108_tok
def calculustokenizereadchars_s106 : List Char := calculustokenizereadchars_p106 ++ ' ' :: calculustokenizereadchars_s107
def calculustokenizereadchars_st106 : List String := calculustokenizereadchars_t106 ++ calculustokenizereadchars_st107
theorem calculustokenizereadchars_s106_tok : tokenizeT 85 calculustokenizereadchars_s106 = some calculustokenizereadchars_st106 :=
  tokenizeT_concat_space 6 78 _ _ _ _ calculustokenizereadchars_p106_tok calculustokenizereadchars_s107_tok
def calculustokenizereadchars_s105 : List Char := calculustokenizereadchars_p105 ++ ' ' :: calculustokenizereadchars_s106
def calculustokenizereadchars_st105 : List String := calculustokenizereadchars_t105 ++ calculustokenizereadchars_st106
theorem calculustokenizereadchars_s105_tok : tokenizeT 88 calculustokenizereadchars_s105 = some calculustokenizereadchars_st105 :=
  tokenizeT_concat_space 2 85 _ _ _ _ calculustokenizereadchars_p105_tok calculustokenizereadchars_s106_tok
def calculustokenizereadchars_s104 : List Char := calculustokenizereadchars_p104 ++ ' ' :: calculustokenizereadchars_s105
def calculustokenizereadchars_st104 : List String := calculustokenizereadchars_t104 ++ calculustokenizereadchars_st105
theorem calculustokenizereadchars_s104_tok : tokenizeT 99 calculustokenizereadchars_s104 = some calculustokenizereadchars_st104 :=
  tokenizeT_concat_space 10 88 _ _ _ _ calculustokenizereadchars_p104_tok calculustokenizereadchars_s105_tok
def calculustokenizereadchars_s103 : List Char := calculustokenizereadchars_p103 ++ ' ' :: calculustokenizereadchars_s104
def calculustokenizereadchars_st103 : List String := calculustokenizereadchars_t103 ++ calculustokenizereadchars_st104
theorem calculustokenizereadchars_s103_tok : tokenizeT 107 calculustokenizereadchars_s103 = some calculustokenizereadchars_st103 :=
  tokenizeT_concat_space 7 99 _ _ _ _ calculustokenizereadchars_p103_tok calculustokenizereadchars_s104_tok
def calculustokenizereadchars_s102 : List Char := calculustokenizereadchars_p102 ++ ' ' :: calculustokenizereadchars_s103
def calculustokenizereadchars_st102 : List String := calculustokenizereadchars_t102 ++ calculustokenizereadchars_st103
theorem calculustokenizereadchars_s102_tok : tokenizeT 110 calculustokenizereadchars_s102 = some calculustokenizereadchars_st102 :=
  tokenizeT_concat_space 2 107 _ _ _ _ calculustokenizereadchars_p102_tok calculustokenizereadchars_s103_tok
def calculustokenizereadchars_s101 : List Char := calculustokenizereadchars_p101 ++ ' ' :: calculustokenizereadchars_s102
def calculustokenizereadchars_st101 : List String := calculustokenizereadchars_t101 ++ calculustokenizereadchars_st102
theorem calculustokenizereadchars_s101_tok : tokenizeT 115 calculustokenizereadchars_s101 = some calculustokenizereadchars_st101 :=
  tokenizeT_concat_space 4 110 _ _ _ _ calculustokenizereadchars_p101_tok calculustokenizereadchars_s102_tok
def calculustokenizereadchars_s100 : List Char := calculustokenizereadchars_p100 ++ ' ' :: calculustokenizereadchars_s101
def calculustokenizereadchars_st100 : List String := calculustokenizereadchars_t100 ++ calculustokenizereadchars_st101
theorem calculustokenizereadchars_s100_tok : tokenizeT 121 calculustokenizereadchars_s100 = some calculustokenizereadchars_st100 :=
  tokenizeT_concat_space 5 115 _ _ _ _ calculustokenizereadchars_p100_tok calculustokenizereadchars_s101_tok
def calculustokenizereadchars_s99 : List Char := calculustokenizereadchars_p99 ++ ' ' :: calculustokenizereadchars_s100
def calculustokenizereadchars_st99 : List String := calculustokenizereadchars_t99 ++ calculustokenizereadchars_st100
theorem calculustokenizereadchars_s99_tok : tokenizeT 127 calculustokenizereadchars_s99 = some calculustokenizereadchars_st99 :=
  tokenizeT_concat_space 5 121 _ _ _ _ calculustokenizereadchars_p99_tok calculustokenizereadchars_s100_tok
def calculustokenizereadchars_s98 : List Char := calculustokenizereadchars_p98 ++ ' ' :: calculustokenizereadchars_s99
def calculustokenizereadchars_st98 : List String := calculustokenizereadchars_t98 ++ calculustokenizereadchars_st99
theorem calculustokenizereadchars_s98_tok : tokenizeT 133 calculustokenizereadchars_s98 = some calculustokenizereadchars_st98 :=
  tokenizeT_concat_space 5 127 _ _ _ _ calculustokenizereadchars_p98_tok calculustokenizereadchars_s99_tok
def calculustokenizereadchars_s97 : List Char := calculustokenizereadchars_p97 ++ ' ' :: calculustokenizereadchars_s98
def calculustokenizereadchars_st97 : List String := calculustokenizereadchars_t97 ++ calculustokenizereadchars_st98
theorem calculustokenizereadchars_s97_tok : tokenizeT 138 calculustokenizereadchars_s97 = some calculustokenizereadchars_st97 :=
  tokenizeT_concat_space 4 133 _ _ _ _ calculustokenizereadchars_p97_tok calculustokenizereadchars_s98_tok
def calculustokenizereadchars_s96 : List Char := calculustokenizereadchars_p96 ++ ' ' :: calculustokenizereadchars_s97
def calculustokenizereadchars_st96 : List String := calculustokenizereadchars_t96 ++ calculustokenizereadchars_st97
theorem calculustokenizereadchars_s96_tok : tokenizeT 168 calculustokenizereadchars_s96 = some calculustokenizereadchars_st96 :=
  tokenizeT_concat_space 29 138 _ _ _ _ calculustokenizereadchars_p96_tok calculustokenizereadchars_s97_tok
def calculustokenizereadchars_s95 : List Char := calculustokenizereadchars_p95 ++ ' ' :: calculustokenizereadchars_s96
def calculustokenizereadchars_st95 : List String := calculustokenizereadchars_t95 ++ calculustokenizereadchars_st96
theorem calculustokenizereadchars_s95_tok : tokenizeT 173 calculustokenizereadchars_s95 = some calculustokenizereadchars_st95 :=
  tokenizeT_concat_space 4 168 _ _ _ _ calculustokenizereadchars_p95_tok calculustokenizereadchars_s96_tok
def calculustokenizereadchars_s94 : List Char := calculustokenizereadchars_p94 ++ ' ' :: calculustokenizereadchars_s95
def calculustokenizereadchars_st94 : List String := calculustokenizereadchars_t94 ++ calculustokenizereadchars_st95
theorem calculustokenizereadchars_s94_tok : tokenizeT 176 calculustokenizereadchars_s94 = some calculustokenizereadchars_st94 :=
  tokenizeT_concat_space 2 173 _ _ _ _ calculustokenizereadchars_p94_tok calculustokenizereadchars_s95_tok
def calculustokenizereadchars_s93 : List Char := calculustokenizereadchars_p93 ++ ' ' :: calculustokenizereadchars_s94
def calculustokenizereadchars_st93 : List String := calculustokenizereadchars_t93 ++ calculustokenizereadchars_st94
theorem calculustokenizereadchars_s93_tok : tokenizeT 187 calculustokenizereadchars_s93 = some calculustokenizereadchars_st93 :=
  tokenizeT_concat_space 10 176 _ _ _ _ calculustokenizereadchars_p93_tok calculustokenizereadchars_s94_tok
def calculustokenizereadchars_s92 : List Char := calculustokenizereadchars_p92 ++ ' ' :: calculustokenizereadchars_s93
def calculustokenizereadchars_st92 : List String := calculustokenizereadchars_t92 ++ calculustokenizereadchars_st93
theorem calculustokenizereadchars_s92_tok : tokenizeT 193 calculustokenizereadchars_s92 = some calculustokenizereadchars_st92 :=
  tokenizeT_concat_space 5 187 _ _ _ _ calculustokenizereadchars_p92_tok calculustokenizereadchars_s93_tok
def calculustokenizereadchars_s91 : List Char := calculustokenizereadchars_p91 ++ ' ' :: calculustokenizereadchars_s92
def calculustokenizereadchars_st91 : List String := calculustokenizereadchars_t91 ++ calculustokenizereadchars_st92
theorem calculustokenizereadchars_s91_tok : tokenizeT 201 calculustokenizereadchars_s91 = some calculustokenizereadchars_st91 :=
  tokenizeT_concat_space 7 193 _ _ _ _ calculustokenizereadchars_p91_tok calculustokenizereadchars_s92_tok
def calculustokenizereadchars_s90 : List Char := calculustokenizereadchars_p90 ++ ' ' :: calculustokenizereadchars_s91
def calculustokenizereadchars_st90 : List String := calculustokenizereadchars_t90 ++ calculustokenizereadchars_st91
theorem calculustokenizereadchars_s90_tok : tokenizeT 231 calculustokenizereadchars_s90 = some calculustokenizereadchars_st90 :=
  tokenizeT_concat_space 29 201 _ _ _ _ calculustokenizereadchars_p90_tok calculustokenizereadchars_s91_tok
def calculustokenizereadchars_s89 : List Char := calculustokenizereadchars_p89 ++ ' ' :: calculustokenizereadchars_s90
def calculustokenizereadchars_st89 : List String := calculustokenizereadchars_t89 ++ calculustokenizereadchars_st90
theorem calculustokenizereadchars_s89_tok : tokenizeT 236 calculustokenizereadchars_s89 = some calculustokenizereadchars_st89 :=
  tokenizeT_concat_space 4 231 _ _ _ _ calculustokenizereadchars_p89_tok calculustokenizereadchars_s90_tok
def calculustokenizereadchars_s88 : List Char := calculustokenizereadchars_p88 ++ ' ' :: calculustokenizereadchars_s89
def calculustokenizereadchars_st88 : List String := calculustokenizereadchars_t88 ++ calculustokenizereadchars_st89
theorem calculustokenizereadchars_s88_tok : tokenizeT 243 calculustokenizereadchars_s88 = some calculustokenizereadchars_st88 :=
  tokenizeT_concat_space 6 236 _ _ _ _ calculustokenizereadchars_p88_tok calculustokenizereadchars_s89_tok
def calculustokenizereadchars_s87 : List Char := calculustokenizereadchars_p87 ++ ' ' :: calculustokenizereadchars_s88
def calculustokenizereadchars_st87 : List String := calculustokenizereadchars_t87 ++ calculustokenizereadchars_st88
theorem calculustokenizereadchars_s87_tok : tokenizeT 250 calculustokenizereadchars_s87 = some calculustokenizereadchars_st87 :=
  tokenizeT_concat_space 6 243 _ _ _ _ calculustokenizereadchars_p87_tok calculustokenizereadchars_s88_tok
def calculustokenizereadchars_s86 : List Char := calculustokenizereadchars_p86 ++ ' ' :: calculustokenizereadchars_s87
def calculustokenizereadchars_st86 : List String := calculustokenizereadchars_t86 ++ calculustokenizereadchars_st87
theorem calculustokenizereadchars_s86_tok : tokenizeT 257 calculustokenizereadchars_s86 = some calculustokenizereadchars_st86 :=
  tokenizeT_concat_space 6 250 _ _ _ _ calculustokenizereadchars_p86_tok calculustokenizereadchars_s87_tok
def calculustokenizereadchars_s85 : List Char := calculustokenizereadchars_p85 ++ ' ' :: calculustokenizereadchars_s86
def calculustokenizereadchars_st85 : List String := calculustokenizereadchars_t85 ++ calculustokenizereadchars_st86
theorem calculustokenizereadchars_s85_tok : tokenizeT 260 calculustokenizereadchars_s85 = some calculustokenizereadchars_st85 :=
  tokenizeT_concat_space 2 257 _ _ _ _ calculustokenizereadchars_p85_tok calculustokenizereadchars_s86_tok
def calculustokenizereadchars_s84 : List Char := calculustokenizereadchars_p84 ++ ' ' :: calculustokenizereadchars_s85
def calculustokenizereadchars_st84 : List String := calculustokenizereadchars_t84 ++ calculustokenizereadchars_st85
theorem calculustokenizereadchars_s84_tok : tokenizeT 271 calculustokenizereadchars_s84 = some calculustokenizereadchars_st84 :=
  tokenizeT_concat_space 10 260 _ _ _ _ calculustokenizereadchars_p84_tok calculustokenizereadchars_s85_tok
def calculustokenizereadchars_s83 : List Char := calculustokenizereadchars_p83 ++ ' ' :: calculustokenizereadchars_s84
def calculustokenizereadchars_st83 : List String := calculustokenizereadchars_t83 ++ calculustokenizereadchars_st84
theorem calculustokenizereadchars_s83_tok : tokenizeT 279 calculustokenizereadchars_s83 = some calculustokenizereadchars_st83 :=
  tokenizeT_concat_space 7 271 _ _ _ _ calculustokenizereadchars_p83_tok calculustokenizereadchars_s84_tok
def calculustokenizereadchars_s82 : List Char := calculustokenizereadchars_p82 ++ ' ' :: calculustokenizereadchars_s83
def calculustokenizereadchars_st82 : List String := calculustokenizereadchars_t82 ++ calculustokenizereadchars_st83
theorem calculustokenizereadchars_s82_tok : tokenizeT 282 calculustokenizereadchars_s82 = some calculustokenizereadchars_st82 :=
  tokenizeT_concat_space 2 279 _ _ _ _ calculustokenizereadchars_p82_tok calculustokenizereadchars_s83_tok
def calculustokenizereadchars_s81 : List Char := calculustokenizereadchars_p81 ++ ' ' :: calculustokenizereadchars_s82
def calculustokenizereadchars_st81 : List String := calculustokenizereadchars_t81 ++ calculustokenizereadchars_st82
theorem calculustokenizereadchars_s81_tok : tokenizeT 287 calculustokenizereadchars_s81 = some calculustokenizereadchars_st81 :=
  tokenizeT_concat_space 4 282 _ _ _ _ calculustokenizereadchars_p81_tok calculustokenizereadchars_s82_tok
def calculustokenizereadchars_s80 : List Char := calculustokenizereadchars_p80 ++ ' ' :: calculustokenizereadchars_s81
def calculustokenizereadchars_st80 : List String := calculustokenizereadchars_t80 ++ calculustokenizereadchars_st81
theorem calculustokenizereadchars_s80_tok : tokenizeT 293 calculustokenizereadchars_s80 = some calculustokenizereadchars_st80 :=
  tokenizeT_concat_space 5 287 _ _ _ _ calculustokenizereadchars_p80_tok calculustokenizereadchars_s81_tok
def calculustokenizereadchars_s79 : List Char := calculustokenizereadchars_p79 ++ ' ' :: calculustokenizereadchars_s80
def calculustokenizereadchars_st79 : List String := calculustokenizereadchars_t79 ++ calculustokenizereadchars_st80
theorem calculustokenizereadchars_s79_tok : tokenizeT 299 calculustokenizereadchars_s79 = some calculustokenizereadchars_st79 :=
  tokenizeT_concat_space 5 293 _ _ _ _ calculustokenizereadchars_p79_tok calculustokenizereadchars_s80_tok
def calculustokenizereadchars_s78 : List Char := calculustokenizereadchars_p78 ++ ' ' :: calculustokenizereadchars_s79
def calculustokenizereadchars_st78 : List String := calculustokenizereadchars_t78 ++ calculustokenizereadchars_st79
theorem calculustokenizereadchars_s78_tok : tokenizeT 305 calculustokenizereadchars_s78 = some calculustokenizereadchars_st78 :=
  tokenizeT_concat_space 5 299 _ _ _ _ calculustokenizereadchars_p78_tok calculustokenizereadchars_s79_tok
def calculustokenizereadchars_s77 : List Char := calculustokenizereadchars_p77 ++ ' ' :: calculustokenizereadchars_s78
def calculustokenizereadchars_st77 : List String := calculustokenizereadchars_t77 ++ calculustokenizereadchars_st78
theorem calculustokenizereadchars_s77_tok : tokenizeT 318 calculustokenizereadchars_s77 = some calculustokenizereadchars_st77 :=
  tokenizeT_concat_space 12 305 _ _ _ _ calculustokenizereadchars_p77_tok calculustokenizereadchars_s78_tok
def calculustokenizereadchars_s76 : List Char := calculustokenizereadchars_p76 ++ ' ' :: calculustokenizereadchars_s77
def calculustokenizereadchars_st76 : List String := calculustokenizereadchars_t76 ++ calculustokenizereadchars_st77
theorem calculustokenizereadchars_s76_tok : tokenizeT 327 calculustokenizereadchars_s76 = some calculustokenizereadchars_st76 :=
  tokenizeT_concat_space 8 318 _ _ _ _ calculustokenizereadchars_p76_tok calculustokenizereadchars_s77_tok
def calculustokenizereadchars_s75 : List Char := calculustokenizereadchars_p75 ++ ' ' :: calculustokenizereadchars_s76
def calculustokenizereadchars_st75 : List String := calculustokenizereadchars_t75 ++ calculustokenizereadchars_st76
theorem calculustokenizereadchars_s75_tok : tokenizeT 332 calculustokenizereadchars_s75 = some calculustokenizereadchars_st75 :=
  tokenizeT_concat_space 4 327 _ _ _ _ calculustokenizereadchars_p75_tok calculustokenizereadchars_s76_tok
def calculustokenizereadchars_s74 : List Char := calculustokenizereadchars_p74 ++ ' ' :: calculustokenizereadchars_s75
def calculustokenizereadchars_st74 : List String := calculustokenizereadchars_t74 ++ calculustokenizereadchars_st75
theorem calculustokenizereadchars_s74_tok : tokenizeT 339 calculustokenizereadchars_s74 = some calculustokenizereadchars_st74 :=
  tokenizeT_concat_space 6 332 _ _ _ _ calculustokenizereadchars_p74_tok calculustokenizereadchars_s75_tok
def calculustokenizereadchars_s73 : List Char := calculustokenizereadchars_p73 ++ ' ' :: calculustokenizereadchars_s74
def calculustokenizereadchars_st73 : List String := calculustokenizereadchars_t73 ++ calculustokenizereadchars_st74
theorem calculustokenizereadchars_s73_tok : tokenizeT 345 calculustokenizereadchars_s73 = some calculustokenizereadchars_st73 :=
  tokenizeT_concat_space 5 339 _ _ _ _ calculustokenizereadchars_p73_tok calculustokenizereadchars_s74_tok
def calculustokenizereadchars_s72 : List Char := calculustokenizereadchars_p72 ++ ' ' :: calculustokenizereadchars_s73
def calculustokenizereadchars_st72 : List String := calculustokenizereadchars_t72 ++ calculustokenizereadchars_st73
theorem calculustokenizereadchars_s72_tok : tokenizeT 350 calculustokenizereadchars_s72 = some calculustokenizereadchars_st72 :=
  tokenizeT_concat_space 4 345 _ _ _ _ calculustokenizereadchars_p72_tok calculustokenizereadchars_s73_tok
def calculustokenizereadchars_s71 : List Char := calculustokenizereadchars_p71 ++ ' ' :: calculustokenizereadchars_s72
def calculustokenizereadchars_st71 : List String := calculustokenizereadchars_t71 ++ calculustokenizereadchars_st72
theorem calculustokenizereadchars_s71_tok : tokenizeT 353 calculustokenizereadchars_s71 = some calculustokenizereadchars_st71 :=
  tokenizeT_concat_space 2 350 _ _ _ _ calculustokenizereadchars_p71_tok calculustokenizereadchars_s72_tok
def calculustokenizereadchars_s70 : List Char := calculustokenizereadchars_p70 ++ ' ' :: calculustokenizereadchars_s71
def calculustokenizereadchars_st70 : List String := calculustokenizereadchars_t70 ++ calculustokenizereadchars_st71
theorem calculustokenizereadchars_s70_tok : tokenizeT 360 calculustokenizereadchars_s70 = some calculustokenizereadchars_st70 :=
  tokenizeT_concat_space 6 353 _ _ _ _ calculustokenizereadchars_p70_tok calculustokenizereadchars_s71_tok
def calculustokenizereadchars_s69 : List Char := calculustokenizereadchars_p69 ++ ' ' :: calculustokenizereadchars_s70
def calculustokenizereadchars_st69 : List String := calculustokenizereadchars_t69 ++ calculustokenizereadchars_st70
theorem calculustokenizereadchars_s69_tok : tokenizeT 366 calculustokenizereadchars_s69 = some calculustokenizereadchars_st69 :=
  tokenizeT_concat_space 5 360 _ _ _ _ calculustokenizereadchars_p69_tok calculustokenizereadchars_s70_tok
def calculustokenizereadchars_s68 : List Char := calculustokenizereadchars_p68 ++ ' ' :: calculustokenizereadchars_s69
def calculustokenizereadchars_st68 : List String := calculustokenizereadchars_t68 ++ calculustokenizereadchars_st69
theorem calculustokenizereadchars_s68_tok : tokenizeT 373 calculustokenizereadchars_s68 = some calculustokenizereadchars_st68 :=
  tokenizeT_concat_space 6 366 _ _ _ _ calculustokenizereadchars_p68_tok calculustokenizereadchars_s69_tok
def calculustokenizereadchars_s67 : List Char := calculustokenizereadchars_p67 ++ ' ' :: calculustokenizereadchars_s68
def calculustokenizereadchars_st67 : List String := calculustokenizereadchars_t67 ++ calculustokenizereadchars_st68
theorem calculustokenizereadchars_s67_tok : tokenizeT 379 calculustokenizereadchars_s67 = some calculustokenizereadchars_st67 :=
  tokenizeT_concat_space 5 373 _ _ _ _ calculustokenizereadchars_p67_tok calculustokenizereadchars_s68_tok
def calculustokenizereadchars_s66 : List Char := calculustokenizereadchars_p66 ++ ' ' :: calculustokenizereadchars_s67
def calculustokenizereadchars_st66 : List String := calculustokenizereadchars_t66 ++ calculustokenizereadchars_st67
theorem calculustokenizereadchars_s66_tok : tokenizeT 382 calculustokenizereadchars_s66 = some calculustokenizereadchars_st66 :=
  tokenizeT_concat_space 2 379 _ _ _ _ calculustokenizereadchars_p66_tok calculustokenizereadchars_s67_tok
def calculustokenizereadchars_s65 : List Char := calculustokenizereadchars_p65 ++ ' ' :: calculustokenizereadchars_s66
def calculustokenizereadchars_st65 : List String := calculustokenizereadchars_t65 ++ calculustokenizereadchars_st66
theorem calculustokenizereadchars_s65_tok : tokenizeT 391 calculustokenizereadchars_s65 = some calculustokenizereadchars_st65 :=
  tokenizeT_concat_space 8 382 _ _ _ _ calculustokenizereadchars_p65_tok calculustokenizereadchars_s66_tok
def calculustokenizereadchars_s64 : List Char := calculustokenizereadchars_p64 ++ ' ' :: calculustokenizereadchars_s65
def calculustokenizereadchars_st64 : List String := calculustokenizereadchars_t64 ++ calculustokenizereadchars_st65
theorem calculustokenizereadchars_s64_tok : tokenizeT 399 calculustokenizereadchars_s64 = some calculustokenizereadchars_st64 :=
  tokenizeT_concat_space 7 391 _ _ _ _ calculustokenizereadchars_p64_tok calculustokenizereadchars_s65_tok
def calculustokenizereadchars_s63 : List Char := calculustokenizereadchars_p63 ++ ' ' :: calculustokenizereadchars_s64
def calculustokenizereadchars_st63 : List String := calculustokenizereadchars_t63 ++ calculustokenizereadchars_st64
theorem calculustokenizereadchars_s63_tok : tokenizeT 402 calculustokenizereadchars_s63 = some calculustokenizereadchars_st63 :=
  tokenizeT_concat_space 2 399 _ _ _ _ calculustokenizereadchars_p63_tok calculustokenizereadchars_s64_tok
def calculustokenizereadchars_s62 : List Char := calculustokenizereadchars_p62 ++ ' ' :: calculustokenizereadchars_s63
def calculustokenizereadchars_st62 : List String := calculustokenizereadchars_t62 ++ calculustokenizereadchars_st63
theorem calculustokenizereadchars_s62_tok : tokenizeT 407 calculustokenizereadchars_s62 = some calculustokenizereadchars_st62 :=
  tokenizeT_concat_space 4 402 _ _ _ _ calculustokenizereadchars_p62_tok calculustokenizereadchars_s63_tok
def calculustokenizereadchars_s61 : List Char := calculustokenizereadchars_p61 ++ ' ' :: calculustokenizereadchars_s62
def calculustokenizereadchars_st61 : List String := calculustokenizereadchars_t61 ++ calculustokenizereadchars_st62
theorem calculustokenizereadchars_s61_tok : tokenizeT 413 calculustokenizereadchars_s61 = some calculustokenizereadchars_st61 :=
  tokenizeT_concat_space 5 407 _ _ _ _ calculustokenizereadchars_p61_tok calculustokenizereadchars_s62_tok
def calculustokenizereadchars_s60 : List Char := calculustokenizereadchars_p60 ++ ' ' :: calculustokenizereadchars_s61
def calculustokenizereadchars_st60 : List String := calculustokenizereadchars_t60 ++ calculustokenizereadchars_st61
theorem calculustokenizereadchars_s60_tok : tokenizeT 419 calculustokenizereadchars_s60 = some calculustokenizereadchars_st60 :=
  tokenizeT_concat_space 5 413 _ _ _ _ calculustokenizereadchars_p60_tok calculustokenizereadchars_s61_tok
def calculustokenizereadchars_s59 : List Char := calculustokenizereadchars_p59 ++ ' ' :: calculustokenizereadchars_s60
def calculustokenizereadchars_st59 : List String := calculustokenizereadchars_t59 ++ calculustokenizereadchars_st60
theorem calculustokenizereadchars_s59_tok : tokenizeT 425 calculustokenizereadchars_s59 = some calculustokenizereadchars_st59 :=
  tokenizeT_concat_space 5 419 _ _ _ _ calculustokenizereadchars_p59_tok calculustokenizereadchars_s60_tok
def calculustokenizereadchars_s58 : List Char := calculustokenizereadchars_p58 ++ ' ' :: calculustokenizereadchars_s59
def calculustokenizereadchars_st58 : List String := calculustokenizereadchars_t58 ++ calculustokenizereadchars_st59
theorem calculustokenizereadchars_s58_tok : tokenizeT 428 calculustokenizereadchars_s58 = some calculustokenizereadchars_st58 :=
  tokenizeT_concat_space 2 425 _ _ _ _ calculustokenizereadchars_p58_tok calculustokenizereadchars_s59_tok
def calculustokenizereadchars_s57 : List Char := calculustokenizereadchars_p57 ++ ' ' :: calculustokenizereadchars_s58
def calculustokenizereadchars_st57 : List String := calculustokenizereadchars_t57 ++ calculustokenizereadchars_st58
theorem calculustokenizereadchars_s57_tok : tokenizeT 433 calculustokenizereadchars_s57 = some calculustokenizereadchars_st57 :=
  tokenizeT_concat_space 4 428 _ _ _ _ calculustokenizereadchars_p57_tok calculustokenizereadchars_s58_tok
def calculustokenizereadchars_s56 : List Char := calculustokenizereadchars_p56 ++ ' ' :: calculustokenizereadchars_s57
def calculustokenizereadchars_st56 : List String := calculustokenizereadchars_t56 ++ calculustokenizereadchars_st57
theorem calculustokenizereadchars_s56_tok : tokenizeT 439 calculustokenizereadchars_s56 = some calculustokenizereadchars_st56 :=
  tokenizeT_concat_space 5 433 _ _ _ _ calculustokenizereadchars_p56_tok calculustokenizereadchars_s57_tok
def calculustokenizereadchars_s55 : List Char := calculustokenizereadchars_p55 ++ ' ' :: calculustokenizereadchars_s56
def calculustokenizereadchars_st55 : List String := calculustokenizereadchars_t55 ++ calculustokenizereadchars_st56
theorem calculustokenizereadchars_s55_tok : tokenizeT 445 calculustokenizereadchars_s55 = some calculustokenizereadchars_st55 :=
  tokenizeT_concat_space 5 439 _ _ _ _ calculustokenizereadchars_p55_tok calculustokenizereadchars_s56_tok
def calculustokenizereadchars_s54 : List Char := calculustokenizereadchars_p54 ++ ' ' :: calculustokenizereadchars_s55
def calculustokenizereadchars_st54 : List String := calculustokenizereadchars_t54 ++ calculustokenizereadchars_st55
theorem calculustokenizereadchars_s54_tok : tokenizeT 451 calculustokenizereadchars_s54 = some calculustokenizereadchars_st54 :=
  tokenizeT_concat_space 5 445 _ _ _ _ calculustokenizereadchars_p54_tok calculustokenizereadchars_s55_tok
def calculustokenizereadchars_s53 : List Char := calculustokenizereadchars_p53 ++ ' ' :: calculustokenizereadchars_s54
def calculustokenizereadchars_st53 : List String := calculustokenizereadchars_t53 ++ calculustokenizereadchars_st54
theorem calculustokenizereadchars_s53_tok : tokenizeT 458 calculustokenizereadchars_s53 = some calculustokenizereadchars_st53 :=
  tokenizeT_concat_space 6 451 _ _ _ _ calculustokenizereadchars_p53_tok calculustokenizereadchars_s54_tok
def calculustokenizereadchars_s52 : List Char := calculustokenizereadchars_p52 ++ ' ' :: calculustokenizereadchars_s53
def calculustokenizereadchars_st52 : List String := calculustokenizereadchars_t52 ++ calculustokenizereadchars_st53
theorem calculustokenizereadchars_s52_tok : tokenizeT 463 calculustokenizereadchars_s52 = some calculustokenizereadchars_st52 :=
  tokenizeT_concat_space 4 458 _ _ _ _ calculustokenizereadchars_p52_tok calculustokenizereadchars_s53_tok
def calculustokenizereadchars_s51 : List Char := calculustokenizereadchars_p51 ++ ' ' :: calculustokenizereadchars_s52
def calculustokenizereadchars_st51 : List String := calculustokenizereadchars_t51 ++ calculustokenizereadchars_st52
theorem calculustokenizereadchars_s51_tok : tokenizeT 472 calculustokenizereadchars_s51 = some calculustokenizereadchars_st51 :=
  tokenizeT_concat_space 8 463 _ _ _ _ calculustokenizereadchars_p51_tok calculustokenizereadchars_s52_tok
def calculustokenizereadchars_s50 : List Char := calculustokenizereadchars_p50 ++ ' ' :: calculustokenizereadchars_s51
def calculustokenizereadchars_st50 : List String := calculustokenizereadchars_t50 ++ calculustokenizereadchars_st51
theorem calculustokenizereadchars_s50_tok : tokenizeT 477 calculustokenizereadchars_s50 = some calculustokenizereadchars_st50 :=
  tokenizeT_concat_space 4 472 _ _ _ _ calculustokenizereadchars_p50_tok calculustokenizereadchars_s51_tok
def calculustokenizereadchars_s49 : List Char := calculustokenizereadchars_p49 ++ ' ' :: calculustokenizereadchars_s50
def calculustokenizereadchars_st49 : List String := calculustokenizereadchars_t49 ++ calculustokenizereadchars_st50
theorem calculustokenizereadchars_s49_tok : tokenizeT 480 calculustokenizereadchars_s49 = some calculustokenizereadchars_st49 :=
  tokenizeT_concat_space 2 477 _ _ _ _ calculustokenizereadchars_p49_tok calculustokenizereadchars_s50_tok
def calculustokenizereadchars_s48 : List Char := calculustokenizereadchars_p48 ++ ' ' :: calculustokenizereadchars_s49
def calculustokenizereadchars_st48 : List String := calculustokenizereadchars_t48 ++ calculustokenizereadchars_st49
theorem calculustokenizereadchars_s48_tok : tokenizeT 487 calculustokenizereadchars_s48 = some calculustokenizereadchars_st48 :=
  tokenizeT_concat_space 6 480 _ _ _ _ calculustokenizereadchars_p48_tok calculustokenizereadchars_s49_tok
def calculustokenizereadchars_s47 : List Char := calculustokenizereadchars_p47 ++ ' ' :: calculustokenizereadchars_s48
def calculustokenizereadchars_st47 : List String := calculustokenizereadchars_t47 ++ calculustokenizereadchars_st48
theorem calculustokenizereadchars_s47_tok : tokenizeT 491 calculustokenizereadchars_s47 = some calculustokenizereadchars_st47 :=
  tokenizeT_concat_space 3 487 _ _ _ _ calculustokenizereadchars_p47_tok calculustokenizereadchars_s48_tok
def calculustokenizereadchars_s46 : List Char := calculustokenizereadchars_p46 ++ ' ' :: calculustokenizereadchars_s47
def calculustokenizereadchars_st46 : List String := calculustokenizereadchars_t46 ++ calculustokenizereadchars_st47
theorem calculustokenizereadchars_s46_tok : tokenizeT 496 calculustokenizereadchars_s46 = some calculustokenizereadchars_st46 :=
  tokenizeT_concat_space 4 491 _ _ _ _ calculustokenizereadchars_p46_tok calculustokenizereadchars_s47_tok
def calculustokenizereadchars_s45 : List Char := calculustokenizereadchars_p45 ++ ' ' :: calculustokenizereadchars_s46
def calculustokenizereadchars_st45 : List String := calculustokenizereadchars_t45 ++ calculustokenizereadchars_st46
theorem calculustokenizereadchars_s45_tok : tokenizeT 502 calculustokenizereadchars_s45 = some calculustokenizereadchars_st45 :=
  tokenizeT_concat_space 5 496 _ _ _ _ calculustokenizereadchars_p45_tok calculustokenizereadchars_s46_tok
def calculustokenizereadchars_s44 : List Char := calculustokenizereadchars_p44 ++ ' ' :: calculustokenizereadchars_s45
def calculustokenizereadchars_st44 : List String := calculustokenizereadchars_t44 ++ calculustokenizereadchars_st45
theorem calculustokenizereadchars_s44_tok : tokenizeT 509 calculustokenizereadchars_s44 = some calculustokenizereadchars_st44 :=
  tokenizeT_concat_space 6 502 _ _ _ _ calculustokenizereadchars_p44_tok calculustokenizereadchars_s45_tok
def calculustokenizereadchars_s43 : List Char := calculustokenizereadchars_p43 ++ ' ' :: calculustokenizereadchars_s44
def calculustokenizereadchars_st43 : List String := calculustokenizereadchars_t43 ++ calculustokenizereadchars_st44
theorem calculustokenizereadchars_s43_tok : tokenizeT 514 calculustokenizereadchars_s43 = some calculustokenizereadchars_st43 :=
  tokenizeT_concat_space 4 509 _ _ _ _ calculustokenizereadchars_p43_tok calculustokenizereadchars_s44_tok
def calculustokenizereadchars_s42 : List Char := calculustokenizereadchars_p42 ++ ' ' :: calculustokenizereadchars_s43
def calculustokenizereadchars_st42 : List String := calculustokenizereadchars_t42 ++ calculustokenizereadchars_st43
theorem calculustokenizereadchars_s42_tok : tokenizeT 521 calculustokenizereadchars_s42 = some calculustokenizereadchars_st42 :=
  tokenizeT_concat_space 6 514 _ _ _ _ calculustokenizereadchars_p42_tok calculustokenizereadchars_s43_tok
def calculustokenizereadchars_s41 : List Char := calculustokenizereadchars_p41 ++ ' ' :: calculustokenizereadchars_s42
def calculustokenizereadchars_st41 : List String := calculustokenizereadchars_t41 ++ calculustokenizereadchars_st42
theorem calculustokenizereadchars_s41_tok : tokenizeT 525 calculustokenizereadchars_s41 = some calculustokenizereadchars_st41 :=
  tokenizeT_concat_space 3 521 _ _ _ _ calculustokenizereadchars_p41_tok calculustokenizereadchars_s42_tok
def calculustokenizereadchars_s40 : List Char := calculustokenizereadchars_p40 ++ ' ' :: calculustokenizereadchars_s41
def calculustokenizereadchars_st40 : List String := calculustokenizereadchars_t40 ++ calculustokenizereadchars_st41
theorem calculustokenizereadchars_s40_tok : tokenizeT 537 calculustokenizereadchars_s40 = some calculustokenizereadchars_st40 :=
  tokenizeT_concat_space 11 525 _ _ _ _ calculustokenizereadchars_p40_tok calculustokenizereadchars_s41_tok
def calculustokenizereadchars_s39 : List Char := calculustokenizereadchars_p39 ++ ' ' :: calculustokenizereadchars_s40
def calculustokenizereadchars_st39 : List String := calculustokenizereadchars_t39 ++ calculustokenizereadchars_st40
theorem calculustokenizereadchars_s39_tok : tokenizeT 540 calculustokenizereadchars_s39 = some calculustokenizereadchars_st39 :=
  tokenizeT_concat_space 2 537 _ _ _ _ calculustokenizereadchars_p39_tok calculustokenizereadchars_s40_tok
def calculustokenizereadchars_s38 : List Char := calculustokenizereadchars_p38 ++ ' ' :: calculustokenizereadchars_s39
def calculustokenizereadchars_st38 : List String := calculustokenizereadchars_t38 ++ calculustokenizereadchars_st39
theorem calculustokenizereadchars_s38_tok : tokenizeT 551 calculustokenizereadchars_s38 = some calculustokenizereadchars_st38 :=
  tokenizeT_concat_space 10 540 _ _ _ _ calculustokenizereadchars_p38_tok calculustokenizereadchars_s39_tok
def calculustokenizereadchars_s37 : List Char := calculustokenizereadchars_p37 ++ ' ' :: calculustokenizereadchars_s38
def calculustokenizereadchars_st37 : List String := calculustokenizereadchars_t37 ++ calculustokenizereadchars_st38
theorem calculustokenizereadchars_s37_tok : tokenizeT 564 calculustokenizereadchars_s37 = some calculustokenizereadchars_st37 :=
  tokenizeT_concat_space 12 551 _ _ _ _ calculustokenizereadchars_p37_tok calculustokenizereadchars_s38_tok
def calculustokenizereadchars_s36 : List Char := calculustokenizereadchars_p36 ++ ' ' :: calculustokenizereadchars_s37
def calculustokenizereadchars_st36 : List String := calculustokenizereadchars_t36 ++ calculustokenizereadchars_st37
theorem calculustokenizereadchars_s36_tok : tokenizeT 567 calculustokenizereadchars_s36 = some calculustokenizereadchars_st36 :=
  tokenizeT_concat_space 2 564 _ _ _ _ calculustokenizereadchars_p36_tok calculustokenizereadchars_s37_tok
def calculustokenizereadchars_s35 : List Char := calculustokenizereadchars_p35 ++ ' ' :: calculustokenizereadchars_s36
def calculustokenizereadchars_st35 : List String := calculustokenizereadchars_t35 ++ calculustokenizereadchars_st36
theorem calculustokenizereadchars_s35_tok : tokenizeT 572 calculustokenizereadchars_s35 = some calculustokenizereadchars_st35 :=
  tokenizeT_concat_space 4 567 _ _ _ _ calculustokenizereadchars_p35_tok calculustokenizereadchars_s36_tok
def calculustokenizereadchars_s34 : List Char := calculustokenizereadchars_p34 ++ ' ' :: calculustokenizereadchars_s35
def calculustokenizereadchars_st34 : List String := calculustokenizereadchars_t34 ++ calculustokenizereadchars_st35
theorem calculustokenizereadchars_s34_tok : tokenizeT 578 calculustokenizereadchars_s34 = some calculustokenizereadchars_st34 :=
  tokenizeT_concat_space 5 572 _ _ _ _ calculustokenizereadchars_p34_tok calculustokenizereadchars_s35_tok
def calculustokenizereadchars_s33 : List Char := calculustokenizereadchars_p33 ++ ' ' :: calculustokenizereadchars_s34
def calculustokenizereadchars_st33 : List String := calculustokenizereadchars_t33 ++ calculustokenizereadchars_st34
theorem calculustokenizereadchars_s33_tok : tokenizeT 584 calculustokenizereadchars_s33 = some calculustokenizereadchars_st33 :=
  tokenizeT_concat_space 5 578 _ _ _ _ calculustokenizereadchars_p33_tok calculustokenizereadchars_s34_tok
def calculustokenizereadchars_s32 : List Char := calculustokenizereadchars_p32 ++ ' ' :: calculustokenizereadchars_s33
def calculustokenizereadchars_st32 : List String := calculustokenizereadchars_t32 ++ calculustokenizereadchars_st33
theorem calculustokenizereadchars_s32_tok : tokenizeT 590 calculustokenizereadchars_s32 = some calculustokenizereadchars_st32 :=
  tokenizeT_concat_space 5 584 _ _ _ _ calculustokenizereadchars_p32_tok calculustokenizereadchars_s33_tok
def calculustokenizereadchars_s31 : List Char := calculustokenizereadchars_p31 ++ ' ' :: calculustokenizereadchars_s32
def calculustokenizereadchars_st31 : List String := calculustokenizereadchars_t31 ++ calculustokenizereadchars_st32
theorem calculustokenizereadchars_s31_tok : tokenizeT 598 calculustokenizereadchars_s31 = some calculustokenizereadchars_st31 :=
  tokenizeT_concat_space 7 590 _ _ _ _ calculustokenizereadchars_p31_tok calculustokenizereadchars_s32_tok
def calculustokenizereadchars_s30 : List Char := calculustokenizereadchars_p30 ++ ' ' :: calculustokenizereadchars_s31
def calculustokenizereadchars_st30 : List String := calculustokenizereadchars_t30 ++ calculustokenizereadchars_st31
theorem calculustokenizereadchars_s30_tok : tokenizeT 605 calculustokenizereadchars_s30 = some calculustokenizereadchars_st30 :=
  tokenizeT_concat_space 6 598 _ _ _ _ calculustokenizereadchars_p30_tok calculustokenizereadchars_s31_tok
def calculustokenizereadchars_s29 : List Char := calculustokenizereadchars_p29 ++ ' ' :: calculustokenizereadchars_s30
def calculustokenizereadchars_st29 : List String := calculustokenizereadchars_t29 ++ calculustokenizereadchars_st30
theorem calculustokenizereadchars_s29_tok : tokenizeT 612 calculustokenizereadchars_s29 = some calculustokenizereadchars_st29 :=
  tokenizeT_concat_space 6 605 _ _ _ _ calculustokenizereadchars_p29_tok calculustokenizereadchars_s30_tok
def calculustokenizereadchars_s28 : List Char := calculustokenizereadchars_p28 ++ ' ' :: calculustokenizereadchars_s29
def calculustokenizereadchars_st28 : List String := calculustokenizereadchars_t28 ++ calculustokenizereadchars_st29
theorem calculustokenizereadchars_s28_tok : tokenizeT 615 calculustokenizereadchars_s28 = some calculustokenizereadchars_st28 :=
  tokenizeT_concat_space 2 612 _ _ _ _ calculustokenizereadchars_p28_tok calculustokenizereadchars_s29_tok
def calculustokenizereadchars_s27 : List Char := calculustokenizereadchars_p27 ++ ' ' :: calculustokenizereadchars_s28
def calculustokenizereadchars_st27 : List String := calculustokenizereadchars_t27 ++ calculustokenizereadchars_st28
theorem calculustokenizereadchars_s27_tok : tokenizeT 626 calculustokenizereadchars_s27 = some calculustokenizereadchars_st27 :=
  tokenizeT_concat_space 10 615 _ _ _ _ calculustokenizereadchars_p27_tok calculustokenizereadchars_s28_tok
def calculustokenizereadchars_s26 : List Char := calculustokenizereadchars_p26 ++ ' ' :: calculustokenizereadchars_s27
def calculustokenizereadchars_st26 : List String := calculustokenizereadchars_t26 ++ calculustokenizereadchars_st27
theorem calculustokenizereadchars_s26_tok : tokenizeT 634 calculustokenizereadchars_s26 = some calculustokenizereadchars_st26 :=
  tokenizeT_concat_space 7 626 _ _ _ _ calculustokenizereadchars_p26_tok calculustokenizereadchars_s27_tok
def calculustokenizereadchars_s25 : List Char := calculustokenizereadchars_p25 ++ ' ' :: calculustokenizereadchars_s26
def calculustokenizereadchars_st25 : List String := calculustokenizereadchars_t25 ++ calculustokenizereadchars_st26
theorem calculustokenizereadchars_s25_tok : tokenizeT 637 calculustokenizereadchars_s25 = some calculustokenizereadchars_st25 :=
  tokenizeT_concat_space 2 634 _ _ _ _ calculustokenizereadchars_p25_tok calculustokenizereadchars_s26_tok
def calculustokenizereadchars_s24 : List Char := calculustokenizereadchars_p24 ++ ' ' :: calculustokenizereadchars_s25
def calculustokenizereadchars_st24 : List String := calculustokenizereadchars_t24 ++ calculustokenizereadchars_st25
theorem calculustokenizereadchars_s24_tok : tokenizeT 642 calculustokenizereadchars_s24 = some calculustokenizereadchars_st24 :=
  tokenizeT_concat_space 4 637 _ _ _ _ calculustokenizereadchars_p24_tok calculustokenizereadchars_s25_tok
def calculustokenizereadchars_s23 : List Char := calculustokenizereadchars_p23 ++ ' ' :: calculustokenizereadchars_s24
def calculustokenizereadchars_st23 : List String := calculustokenizereadchars_t23 ++ calculustokenizereadchars_st24
theorem calculustokenizereadchars_s23_tok : tokenizeT 648 calculustokenizereadchars_s23 = some calculustokenizereadchars_st23 :=
  tokenizeT_concat_space 5 642 _ _ _ _ calculustokenizereadchars_p23_tok calculustokenizereadchars_s24_tok
def calculustokenizereadchars_s22 : List Char := calculustokenizereadchars_p22 ++ ' ' :: calculustokenizereadchars_s23
def calculustokenizereadchars_st22 : List String := calculustokenizereadchars_t22 ++ calculustokenizereadchars_st23
theorem calculustokenizereadchars_s22_tok : tokenizeT 654 calculustokenizereadchars_s22 = some calculustokenizereadchars_st22 :=
  tokenizeT_concat_space 5 648 _ _ _ _ calculustokenizereadchars_p22_tok calculustokenizereadchars_s23_tok
def calculustokenizereadchars_s21 : List Char := calculustokenizereadchars_p21 ++ ' ' :: calculustokenizereadchars_s22
def calculustokenizereadchars_st21 : List String := calculustokenizereadchars_t21 ++ calculustokenizereadchars_st22
theorem calculustokenizereadchars_s21_tok : tokenizeT 660 calculustokenizereadchars_s21 = some calculustokenizereadchars_st21 :=
  tokenizeT_concat_space 5 654 _ _ _ _ calculustokenizereadchars_p21_tok calculustokenizereadchars_s22_tok
def calculustokenizereadchars_s20 : List Char := calculustokenizereadchars_p20 ++ ' ' :: calculustokenizereadchars_s21
def calculustokenizereadchars_st20 : List String := calculustokenizereadchars_t20 ++ calculustokenizereadchars_st21
theorem calculustokenizereadchars_s20_tok : tokenizeT 670 calculustokenizereadchars_s20 = some calculustokenizereadchars_st20 :=
  tokenizeT_concat_space 9 660 _ _ _ _ calculustokenizereadchars_p20_tok calculustokenizereadchars_s21_tok
def calculustokenizereadchars_s19 : List Char := calculustokenizereadchars_p19 ++ ' ' :: calculustokenizereadchars_s20
def calculustokenizereadchars_st19 : List String := calculustokenizereadchars_t19 ++ calculustokenizereadchars_st20
theorem calculustokenizereadchars_s19_tok : tokenizeT 675 calculustokenizereadchars_s19 = some calculustokenizereadchars_st19 :=
  tokenizeT_concat_space 4 670 _ _ _ _ calculustokenizereadchars_p19_tok calculustokenizereadchars_s20_tok
def calculustokenizereadchars_s18 : List Char := calculustokenizereadchars_p18 ++ ' ' :: calculustokenizereadchars_s19
def calculustokenizereadchars_st18 : List String := calculustokenizereadchars_t18 ++ calculustokenizereadchars_st19
theorem calculustokenizereadchars_s18_tok : tokenizeT 682 calculustokenizereadchars_s18 = some calculustokenizereadchars_st18 :=
  tokenizeT_concat_space 6 675 _ _ _ _ calculustokenizereadchars_p18_tok calculustokenizereadchars_s19_tok
def calculustokenizereadchars_s17 : List Char := calculustokenizereadchars_p17 ++ ' ' :: calculustokenizereadchars_s18
def calculustokenizereadchars_st17 : List String := calculustokenizereadchars_t17 ++ calculustokenizereadchars_st18
theorem calculustokenizereadchars_s17_tok : tokenizeT 692 calculustokenizereadchars_s17 = some calculustokenizereadchars_st17 :=
  tokenizeT_concat_space 9 682 _ _ _ _ calculustokenizereadchars_p17_tok calculustokenizereadchars_s18_tok
def calculustokenizereadchars_s16 : List Char := calculustokenizereadchars_p16 ++ ' ' :: calculustokenizereadchars_s17
def calculustokenizereadchars_st16 : List String := calculustokenizereadchars_t16 ++ calculustokenizereadchars_st17
theorem calculustokenizereadchars_s16_tok : tokenizeT 695 calculustokenizereadchars_s16 = some calculustokenizereadchars_st16 :=
  tokenizeT_concat_space 2 692 _ _ _ _ calculustokenizereadchars_p16_tok calculustokenizereadchars_s17_tok
def calculustokenizereadchars_s15 : List Char := calculustokenizereadchars_p15 ++ ' ' :: calculustokenizereadchars_s16
def calculustokenizereadchars_st15 : List String := calculustokenizereadchars_t15 ++ calculustokenizereadchars_st16
theorem calculustokenizereadchars_s15_tok : tokenizeT 704 calculustokenizereadchars_s15 = some calculustokenizereadchars_st15 :=
  tokenizeT_concat_space 8 695 _ _ _ _ calculustokenizereadchars_p15_tok calculustokenizereadchars_s16_tok
def calculustokenizereadchars_s14 : List Char := calculustokenizereadchars_p14 ++ ' ' :: calculustokenizereadchars_s15
def calculustokenizereadchars_st14 : List String := calculustokenizereadchars_t14 ++ calculustokenizereadchars_st15
theorem calculustokenizereadchars_s14_tok : tokenizeT 710 calculustokenizereadchars_s14 = some calculustokenizereadchars_st14 :=
  tokenizeT_concat_space 5 704 _ _ _ _ calculustokenizereadchars_p14_tok calculustokenizereadchars_s15_tok
def calculustokenizereadchars_s13 : List Char := calculustokenizereadchars_p13 ++ ' ' :: calculustokenizereadchars_s14
def calculustokenizereadchars_st13 : List String := calculustokenizereadchars_t13 ++ calculustokenizereadchars_st14
theorem calculustokenizereadchars_s13_tok : tokenizeT 713 calculustokenizereadchars_s13 = some calculustokenizereadchars_st13 :=
  tokenizeT_concat_space 2 710 _ _ _ _ calculustokenizereadchars_p13_tok calculustokenizereadchars_s14_tok
def calculustokenizereadchars_s12 : List Char := calculustokenizereadchars_p12 ++ ' ' :: calculustokenizereadchars_s13
def calculustokenizereadchars_st12 : List String := calculustokenizereadchars_t12 ++ calculustokenizereadchars_st13
theorem calculustokenizereadchars_s12_tok : tokenizeT 718 calculustokenizereadchars_s12 = some calculustokenizereadchars_st12 :=
  tokenizeT_concat_space 4 713 _ _ _ _ calculustokenizereadchars_p12_tok calculustokenizereadchars_s13_tok
def calculustokenizereadchars_s11 : List Char := calculustokenizereadchars_p11 ++ ' ' :: calculustokenizereadchars_s12
def calculustokenizereadchars_st11 : List String := calculustokenizereadchars_t11 ++ calculustokenizereadchars_st12
theorem calculustokenizereadchars_s11_tok : tokenizeT 724 calculustokenizereadchars_s11 = some calculustokenizereadchars_st11 :=
  tokenizeT_concat_space 5 718 _ _ _ _ calculustokenizereadchars_p11_tok calculustokenizereadchars_s12_tok
def calculustokenizereadchars_s10 : List Char := calculustokenizereadchars_p10 ++ ' ' :: calculustokenizereadchars_s11
def calculustokenizereadchars_st10 : List String := calculustokenizereadchars_t10 ++ calculustokenizereadchars_st11
theorem calculustokenizereadchars_s10_tok : tokenizeT 730 calculustokenizereadchars_s10 = some calculustokenizereadchars_st10 :=
  tokenizeT_concat_space 5 724 _ _ _ _ calculustokenizereadchars_p10_tok calculustokenizereadchars_s11_tok
def calculustokenizereadchars_s9 : List Char := calculustokenizereadchars_p9 ++ ' ' :: calculustokenizereadchars_s10
def calculustokenizereadchars_st9 : List String := calculustokenizereadchars_t9 ++ calculustokenizereadchars_st10
theorem calculustokenizereadchars_s9_tok : tokenizeT 738 calculustokenizereadchars_s9 = some calculustokenizereadchars_st9 :=
  tokenizeT_concat_space 7 730 _ _ _ _ calculustokenizereadchars_p9_tok calculustokenizereadchars_s10_tok
def calculustokenizereadchars_s8 : List Char := calculustokenizereadchars_p8 ++ ' ' :: calculustokenizereadchars_s9
def calculustokenizereadchars_st8 : List String := calculustokenizereadchars_t8 ++ calculustokenizereadchars_st9
theorem calculustokenizereadchars_s8_tok : tokenizeT 741 calculustokenizereadchars_s8 = some calculustokenizereadchars_st8 :=
  tokenizeT_concat_space 2 738 _ _ _ _ calculustokenizereadchars_p8_tok calculustokenizereadchars_s9_tok
def calculustokenizereadchars_s7 : List Char := calculustokenizereadchars_p7 ++ ' ' :: calculustokenizereadchars_s8
def calculustokenizereadchars_st7 : List String := calculustokenizereadchars_t7 ++ calculustokenizereadchars_st8
theorem calculustokenizereadchars_s7_tok : tokenizeT 746 calculustokenizereadchars_s7 = some calculustokenizereadchars_st7 :=
  tokenizeT_concat_space 4 741 _ _ _ _ calculustokenizereadchars_p7_tok calculustokenizereadchars_s8_tok
def calculustokenizereadchars_s6 : List Char := calculustokenizereadchars_p6 ++ ' ' :: calculustokenizereadchars_s7
def calculustokenizereadchars_st6 : List String := calculustokenizereadchars_t6 ++ calculustokenizereadchars_st7
theorem calculustokenizereadchars_s6_tok : tokenizeT 752 calculustokenizereadchars_s6 = some calculustokenizereadchars_st6 :=
  tokenizeT_concat_space 5 746 _ _ _ _ calculustokenizereadchars_p6_tok calculustokenizereadchars_s7_tok
def calculustokenizereadchars_s5 : List Char := calculustokenizereadchars_p5 ++ ' ' :: calculustokenizereadchars_s6
def calculustokenizereadchars_st5 : List String := calculustokenizereadchars_t5 ++ calculustokenizereadchars_st6
theorem calculustokenizereadchars_s5_tok : tokenizeT 758 calculustokenizereadchars_s5 = some calculustokenizereadchars_st5 :=
  tokenizeT_concat_space 5 752 _ _ _ _ calculustokenizereadchars_p5_tok calculustokenizereadchars_s6_tok
def calculustokenizereadchars_s4 : List Char := calculustokenizereadchars_p4 ++ ' ' :: calculustokenizereadchars_s5
def calculustokenizereadchars_st4 : List String := calculustokenizereadchars_t4 ++ calculustokenizereadchars_st5
theorem calculustokenizereadchars_s4_tok : tokenizeT 764 calculustokenizereadchars_s4 = some calculustokenizereadchars_st4 :=
  tokenizeT_concat_space 5 758 _ _ _ _ calculustokenizereadchars_p4_tok calculustokenizereadchars_s5_tok
def calculustokenizereadchars_s3 : List Char := calculustokenizereadchars_p3 ++ ' ' :: calculustokenizereadchars_s4
def calculustokenizereadchars_st3 : List String := calculustokenizereadchars_t3 ++ calculustokenizereadchars_st4
theorem calculustokenizereadchars_s3_tok : tokenizeT 768 calculustokenizereadchars_s3 = some calculustokenizereadchars_st3 :=
  tokenizeT_concat_space 3 764 _ _ _ _ calculustokenizereadchars_p3_tok calculustokenizereadchars_s4_tok
def calculustokenizereadchars_s2 : List Char := calculustokenizereadchars_p2 ++ ' ' :: calculustokenizereadchars_s3
def calculustokenizereadchars_st2 : List String := calculustokenizereadchars_t2 ++ calculustokenizereadchars_st3
theorem calculustokenizereadchars_s2_tok : tokenizeT 771 calculustokenizereadchars_s2 = some calculustokenizereadchars_st2 :=
  tokenizeT_concat_space 2 768 _ _ _ _ calculustokenizereadchars_p2_tok calculustokenizereadchars_s3_tok
def calculustokenizereadchars_s1 : List Char := calculustokenizereadchars_p1 ++ ' ' :: calculustokenizereadchars_s2
def calculustokenizereadchars_st1 : List String := calculustokenizereadchars_t1 ++ calculustokenizereadchars_st2
theorem calculustokenizereadchars_s1_tok : tokenizeT 780 calculustokenizereadchars_s1 = some calculustokenizereadchars_st1 :=
  tokenizeT_concat_space 8 771 _ _ _ _ calculustokenizereadchars_p1_tok calculustokenizereadchars_s2_tok
def calculustokenizereadchars_s0 : List Char := calculustokenizereadchars_p0 ++ ' ' :: calculustokenizereadchars_s1
def calculustokenizereadchars_st0 : List String := calculustokenizereadchars_t0 ++ calculustokenizereadchars_st1
theorem calculustokenizereadchars_s0_tok : tokenizeT 786 calculustokenizereadchars_s0 = some calculustokenizereadchars_st0 :=
  tokenizeT_concat_space 5 780 _ _ _ _ calculustokenizereadchars_p0_tok calculustokenizereadchars_s1_tok
end CalculusTokenizeReadChars

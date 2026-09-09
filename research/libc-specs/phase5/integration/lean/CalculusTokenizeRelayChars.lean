/- CalculusTokenizeRelayChars leaves + right-spine concat (tokenizer-relay-read-115) -/
import CalculusTokenizeFull
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull
namespace CalculusTokenizeRelayChars
set_option maxRecDepth 100000
def calculustokenizerelaychars_p0 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t0 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p0_tok : tokenizeT 5 calculustokenizerelaychars_p0 = some calculustokenizerelaychars_t0 := by
  decide +kernel
def calculustokenizerelaychars_p1 : List Char := ['(', 'r', 'e', 'm', 'o', 'v', 'e', '-', 'e', 'l', 'e', 'm']
def calculustokenizerelaychars_t1 : List String := ["(", "remove-elem"]
theorem calculustokenizerelaychars_p1_tok : tokenizeT 13 calculustokenizerelaychars_p1 = some calculustokenizerelaychars_t1 := by
  decide +kernel
def calculustokenizerelaychars_p2 : List Char := [Char.ofNat 963]
def calculustokenizerelaychars_t2 : List String := ["σ"]
theorem calculustokenizerelaychars_p2_tok : tokenizeT 2 calculustokenizerelaychars_p2 = some calculustokenizerelaychars_t2 := by
  decide +kernel
def calculustokenizerelaychars_p3 : List Char := ['b', 'l', 'o', 'c', 'k']
def calculustokenizerelaychars_t3 : List String := ["block"]
theorem calculustokenizerelaychars_p3_tok : tokenizeT 6 calculustokenizerelaychars_p3 = some calculustokenizerelaychars_t3 := by
  decide +kernel
def calculustokenizerelaychars_p4 : List Char := ['0', ')']
def calculustokenizerelaychars_t4 : List String := ["0", ")"]
theorem calculustokenizerelaychars_p4_tok : tokenizeT 3 calculustokenizerelaychars_p4 = some calculustokenizerelaychars_t4 := by
  decide +kernel
def calculustokenizerelaychars_p5 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t5 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p5_tok : tokenizeT 5 calculustokenizerelaychars_p5 = some calculustokenizerelaychars_t5 := by
  decide +kernel
def calculustokenizerelaychars_p6 : List Char := ['(', 'a', 'd', 'd', '-', 'e', 'l', 'e', 'm']
def calculustokenizerelaychars_t6 : List String := ["(", "add-elem"]
theorem calculustokenizerelaychars_p6_tok : tokenizeT 10 calculustokenizerelaychars_p6 = some calculustokenizerelaychars_t6 := by
  decide +kernel
def calculustokenizerelaychars_p7 : List Char := [Char.ofNat 963]
def calculustokenizerelaychars_t7 : List String := ["σ"]
theorem calculustokenizerelaychars_p7_tok : tokenizeT 2 calculustokenizerelaychars_p7 = some calculustokenizerelaychars_t7 := by
  decide +kernel
def calculustokenizerelaychars_p8 : List Char := ['b', 'l', 'o', 'c', 'k']
def calculustokenizerelaychars_t8 : List String := ["block"]
theorem calculustokenizerelaychars_p8_tok : tokenizeT 6 calculustokenizerelaychars_p8 = some calculustokenizerelaychars_t8 := by
  decide +kernel
def calculustokenizerelaychars_p9 : List Char := ['0', ')']
def calculustokenizerelaychars_t9 : List String := ["0", ")"]
theorem calculustokenizerelaychars_p9_tok : tokenizeT 3 calculustokenizerelaychars_p9 = some calculustokenizerelaychars_t9 := by
  decide +kernel
def calculustokenizerelaychars_p10 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t10 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p10_tok : tokenizeT 5 calculustokenizerelaychars_p10 = some calculustokenizerelaychars_t10 := by
  decide +kernel
def calculustokenizerelaychars_p11 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizerelaychars_t11 : List String := ["(", "assign"]
theorem calculustokenizerelaychars_p11_tok : tokenizeT 8 calculustokenizerelaychars_p11 = some calculustokenizerelaychars_t11 := by
  decide +kernel
def calculustokenizerelaychars_p12 : List Char := ['b']
def calculustokenizerelaychars_t12 : List String := ["b"]
theorem calculustokenizerelaychars_p12_tok : tokenizeT 2 calculustokenizerelaychars_p12 = some calculustokenizerelaychars_t12 := by
  decide +kernel
def calculustokenizerelaychars_p13 : List Char := ['(', 'e', 'l', 'e', 'm']
def calculustokenizerelaychars_t13 : List String := ["(", "elem"]
theorem calculustokenizerelaychars_p13_tok : tokenizeT 6 calculustokenizerelaychars_p13 = some calculustokenizerelaychars_t13 := by
  decide +kernel
def calculustokenizerelaychars_p14 : List Char := [Char.ofNat 963]
def calculustokenizerelaychars_t14 : List String := ["σ"]
theorem calculustokenizerelaychars_p14_tok : tokenizeT 2 calculustokenizerelaychars_p14 = some calculustokenizerelaychars_t14 := by
  decide +kernel
def calculustokenizerelaychars_p15 : List Char := ['b', 'l', 'o', 'c', 'k']
def calculustokenizerelaychars_t15 : List String := ["block"]
theorem calculustokenizerelaychars_p15_tok : tokenizeT 6 calculustokenizerelaychars_p15 = some calculustokenizerelaychars_t15 := by
  decide +kernel
def calculustokenizerelaychars_p16 : List Char := ['0', ')', ')']
def calculustokenizerelaychars_t16 : List String := ["0", ")", ")"]
theorem calculustokenizerelaychars_p16_tok : tokenizeT 4 calculustokenizerelaychars_p16 = some calculustokenizerelaychars_t16 := by
  decide +kernel
def calculustokenizerelaychars_p17 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t17 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p17_tok : tokenizeT 5 calculustokenizerelaychars_p17 = some calculustokenizerelaychars_t17 := by
  decide +kernel
def calculustokenizerelaychars_p18 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizerelaychars_t18 : List String := ["(", "set-attr"]
theorem calculustokenizerelaychars_p18_tok : tokenizeT 10 calculustokenizerelaychars_p18 = some calculustokenizerelaychars_t18 := by
  decide +kernel
def calculustokenizerelaychars_p19 : List Char := ['b']
def calculustokenizerelaychars_t19 : List String := ["b"]
theorem calculustokenizerelaychars_p19_tok : tokenizeT 2 calculustokenizerelaychars_p19 = some calculustokenizerelaychars_t19 := by
  decide +kernel
def calculustokenizerelaychars_p20 : List Char := ['c', 'a', 'p']
def calculustokenizerelaychars_t20 : List String := ["cap"]
theorem calculustokenizerelaychars_p20_tok : tokenizeT 4 calculustokenizerelaychars_p20 = some calculustokenizerelaychars_t20 := by
  decide +kernel
def calculustokenizerelaychars_p21 : List Char := ['3', '2', ')']
def calculustokenizerelaychars_t21 : List String := ["32", ")"]
theorem calculustokenizerelaychars_p21_tok : tokenizeT 4 calculustokenizerelaychars_p21 = some calculustokenizerelaychars_t21 := by
  decide +kernel
def calculustokenizerelaychars_p22 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t22 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p22_tok : tokenizeT 5 calculustokenizerelaychars_p22 = some calculustokenizerelaychars_t22 := by
  decide +kernel
def calculustokenizerelaychars_p23 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizerelaychars_t23 : List String := ["(", "set-attr"]
theorem calculustokenizerelaychars_p23_tok : tokenizeT 10 calculustokenizerelaychars_p23 = some calculustokenizerelaychars_t23 := by
  decide +kernel
def calculustokenizerelaychars_p24 : List Char := ['b']
def calculustokenizerelaychars_t24 : List String := ["b"]
theorem calculustokenizerelaychars_p24_tok : tokenizeT 2 calculustokenizerelaychars_p24 = some calculustokenizerelaychars_t24 := by
  decide +kernel
def calculustokenizerelaychars_p25 : List Char := ['l', 'e', 'n']
def calculustokenizerelaychars_t25 : List String := ["len"]
theorem calculustokenizerelaychars_p25_tok : tokenizeT 4 calculustokenizerelaychars_p25 = some calculustokenizerelaychars_t25 := by
  decide +kernel
def calculustokenizerelaychars_p26 : List Char := ['0', ')']
def calculustokenizerelaychars_t26 : List String := ["0", ")"]
theorem calculustokenizerelaychars_p26_tok : tokenizeT 3 calculustokenizerelaychars_p26 = some calculustokenizerelaychars_t26 := by
  decide +kernel
def calculustokenizerelaychars_p27 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t27 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p27_tok : tokenizeT 5 calculustokenizerelaychars_p27 = some calculustokenizerelaychars_t27 := by
  decide +kernel
def calculustokenizerelaychars_p28 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizerelaychars_t28 : List String := ["(", "set-attr"]
theorem calculustokenizerelaychars_p28_tok : tokenizeT 10 calculustokenizerelaychars_p28 = some calculustokenizerelaychars_t28 := by
  decide +kernel
def calculustokenizerelaychars_p29 : List Char := ['b']
def calculustokenizerelaychars_t29 : List String := ["b"]
theorem calculustokenizerelaychars_p29_tok : tokenizeT 2 calculustokenizerelaychars_p29 = some calculustokenizerelaychars_t29 := by
  decide +kernel
def calculustokenizerelaychars_p30 : List Char := ['b', 'y', 't', 'e', 's']
def calculustokenizerelaychars_t30 : List String := ["bytes"]
theorem calculustokenizerelaychars_p30_tok : tokenizeT 6 calculustokenizerelaychars_p30 = some calculustokenizerelaychars_t30 := by
  decide +kernel
def calculustokenizerelaychars_p31 : List Char := ['(', 'e', 'm', 'p', 't', 'y']
def calculustokenizerelaychars_t31 : List String := ["(", "empty"]
theorem calculustokenizerelaychars_p31_tok : tokenizeT 7 calculustokenizerelaychars_p31 = some calculustokenizerelaychars_t31 := by
  decide +kernel
def calculustokenizerelaychars_p32 : List Char := ['(', ')', ')', ')']
def calculustokenizerelaychars_t32 : List String := ["(", ")", ")", ")"]
theorem calculustokenizerelaychars_p32_tok : tokenizeT 5 calculustokenizerelaychars_p32 = some calculustokenizerelaychars_t32 := by
  decide +kernel
def calculustokenizerelaychars_p33 : List Char := ['(', 'w', 'h', 'i', 'l', 'e']
def calculustokenizerelaychars_t33 : List String := ["(", "while"]
theorem calculustokenizerelaychars_p33_tok : tokenizeT 7 calculustokenizerelaychars_p33 = some calculustokenizerelaychars_t33 := by
  decide +kernel
def calculustokenizerelaychars_p34 : List Char := ['t', 'r', 'u', 'e']
def calculustokenizerelaychars_t34 : List String := ["true"]
theorem calculustokenizerelaychars_p34_tok : tokenizeT 5 calculustokenizerelaychars_p34 = some calculustokenizerelaychars_t34 := by
  decide +kernel
def calculustokenizerelaychars_p35 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t35 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p35_tok : tokenizeT 5 calculustokenizerelaychars_p35 = some calculustokenizerelaychars_t35 := by
  decide +kernel
def calculustokenizerelaychars_p36 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t36 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p36_tok : tokenizeT 5 calculustokenizerelaychars_p36 = some calculustokenizerelaychars_t36 := by
  decide +kernel
def calculustokenizerelaychars_p37 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t37 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p37_tok : tokenizeT 5 calculustokenizerelaychars_p37 = some calculustokenizerelaychars_t37 := by
  decide +kernel
def calculustokenizerelaychars_p38 : List Char := ['(', 'a', 'c', 't', 'i', 'o', 'n']
def calculustokenizerelaychars_t38 : List String := ["(", "action"]
theorem calculustokenizerelaychars_p38_tok : tokenizeT 8 calculustokenizerelaychars_p38 = some calculustokenizerelaychars_t38 := by
  decide +kernel
def calculustokenizerelaychars_p39 : List Char := ['$', 't', '1', '7']
def calculustokenizerelaychars_t39 : List String := ["$t17"]
theorem calculustokenizerelaychars_p39_tok : tokenizeT 5 calculustokenizerelaychars_p39 = some calculustokenizerelaychars_t39 := by
  decide +kernel
def calculustokenizerelaychars_p40 : List Char := ['r', 'e', 'a', 'd', '_', 'b', 'l', 'o', 'c', 'k']
def calculustokenizerelaychars_t40 : List String := ["read_block"]
theorem calculustokenizerelaychars_p40_tok : tokenizeT 11 calculustokenizerelaychars_p40 = some calculustokenizerelaychars_t40 := by
  decide +kernel
def calculustokenizerelaychars_p41 : List Char := ['b', ')']
def calculustokenizerelaychars_t41 : List String := ["b", ")"]
theorem calculustokenizerelaychars_p41_tok : tokenizeT 3 calculustokenizerelaychars_p41 = some calculustokenizerelaychars_t41 := by
  decide +kernel
def calculustokenizerelaychars_p42 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizerelaychars_t42 : List String := ["(", "assign"]
theorem calculustokenizerelaychars_p42_tok : tokenizeT 8 calculustokenizerelaychars_p42 = some calculustokenizerelaychars_t42 := by
  decide +kernel
def calculustokenizerelaychars_p43 : List Char := ['r']
def calculustokenizerelaychars_t43 : List String := ["r"]
theorem calculustokenizerelaychars_p43_tok : tokenizeT 2 calculustokenizerelaychars_p43 = some calculustokenizerelaychars_t43 := by
  decide +kernel
def calculustokenizerelaychars_p44 : List Char := ['$', 't', '1', '7', ')', ')']
def calculustokenizerelaychars_t44 : List String := ["$t17", ")", ")"]
theorem calculustokenizerelaychars_p44_tok : tokenizeT 7 calculustokenizerelaychars_p44 = some calculustokenizerelaychars_t44 := by
  decide +kernel
def calculustokenizerelaychars_p45 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t45 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p45_tok : tokenizeT 5 calculustokenizerelaychars_p45 = some calculustokenizerelaychars_t45 := by
  decide +kernel
def calculustokenizerelaychars_p46 : List Char := ['(', 'i', 'f']
def calculustokenizerelaychars_t46 : List String := ["(", "if"]
theorem calculustokenizerelaychars_p46_tok : tokenizeT 4 calculustokenizerelaychars_p46 = some calculustokenizerelaychars_t46 := by
  decide +kernel
def calculustokenizerelaychars_p47 : List Char := ['(', '<']
def calculustokenizerelaychars_t47 : List String := ["(", "<"]
theorem calculustokenizerelaychars_p47_tok : tokenizeT 3 calculustokenizerelaychars_p47 = some calculustokenizerelaychars_t47 := by
  decide +kernel
def calculustokenizerelaychars_p48 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t48 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p48_tok : tokenizeT 6 calculustokenizerelaychars_p48 = some calculustokenizerelaychars_t48 := by
  decide +kernel
def calculustokenizerelaychars_p49 : List Char := ['r']
def calculustokenizerelaychars_t49 : List String := ["r"]
theorem calculustokenizerelaychars_p49_tok : tokenizeT 2 calculustokenizerelaychars_p49 = some calculustokenizerelaychars_t49 := by
  decide +kernel
def calculustokenizerelaychars_p50 : List Char := ['0', ')', ')']
def calculustokenizerelaychars_t50 : List String := ["0", ")", ")"]
theorem calculustokenizerelaychars_p50_tok : tokenizeT 4 calculustokenizerelaychars_p50 = some calculustokenizerelaychars_t50 := by
  decide +kernel
def calculustokenizerelaychars_p51 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def calculustokenizerelaychars_t51 : List String := ["(", "return"]
theorem calculustokenizerelaychars_p51_tok : tokenizeT 8 calculustokenizerelaychars_p51 = some calculustokenizerelaychars_t51 := by
  decide +kernel
def calculustokenizerelaychars_p52 : List Char := ['1', ')']
def calculustokenizerelaychars_t52 : List String := ["1", ")"]
theorem calculustokenizerelaychars_p52_tok : tokenizeT 3 calculustokenizerelaychars_p52 = some calculustokenizerelaychars_t52 := by
  decide +kernel
def calculustokenizerelaychars_p53 : List Char := ['p', 'a', 's', 's', ')']
def calculustokenizerelaychars_t53 : List String := ["pass", ")"]
theorem calculustokenizerelaychars_p53_tok : tokenizeT 6 calculustokenizerelaychars_p53 = some calculustokenizerelaychars_t53 := by
  decide +kernel
def calculustokenizerelaychars_p54 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t54 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p54_tok : tokenizeT 5 calculustokenizerelaychars_p54 = some calculustokenizerelaychars_t54 := by
  decide +kernel
def calculustokenizerelaychars_p55 : List Char := ['(', 'i', 'f']
def calculustokenizerelaychars_t55 : List String := ["(", "if"]
theorem calculustokenizerelaychars_p55_tok : tokenizeT 4 calculustokenizerelaychars_p55 = some calculustokenizerelaychars_t55 := by
  decide +kernel
def calculustokenizerelaychars_p56 : List Char := ['(', '=', '=']
def calculustokenizerelaychars_t56 : List String := ["(", "=="]
theorem calculustokenizerelaychars_p56_tok : tokenizeT 4 calculustokenizerelaychars_p56 = some calculustokenizerelaychars_t56 := by
  decide +kernel
def calculustokenizerelaychars_p57 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t57 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p57_tok : tokenizeT 6 calculustokenizerelaychars_p57 = some calculustokenizerelaychars_t57 := by
  decide +kernel
def calculustokenizerelaychars_p58 : List Char := ['r']
def calculustokenizerelaychars_t58 : List String := ["r"]
theorem calculustokenizerelaychars_p58_tok : tokenizeT 2 calculustokenizerelaychars_p58 = some calculustokenizerelaychars_t58 := by
  decide +kernel
def calculustokenizerelaychars_p59 : List Char := ['0', ')', ')']
def calculustokenizerelaychars_t59 : List String := ["0", ")", ")"]
theorem calculustokenizerelaychars_p59_tok : tokenizeT 4 calculustokenizerelaychars_p59 = some calculustokenizerelaychars_t59 := by
  decide +kernel
def calculustokenizerelaychars_p60 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def calculustokenizerelaychars_t60 : List String := ["(", "return"]
theorem calculustokenizerelaychars_p60_tok : tokenizeT 8 calculustokenizerelaychars_p60 = some calculustokenizerelaychars_t60 := by
  decide +kernel
def calculustokenizerelaychars_p61 : List Char := ['0', ')']
def calculustokenizerelaychars_t61 : List String := ["0", ")"]
theorem calculustokenizerelaychars_p61_tok : tokenizeT 3 calculustokenizerelaychars_p61 = some calculustokenizerelaychars_t61 := by
  decide +kernel
def calculustokenizerelaychars_p62 : List Char := ['p', 'a', 's', 's', ')']
def calculustokenizerelaychars_t62 : List String := ["pass", ")"]
theorem calculustokenizerelaychars_p62_tok : tokenizeT 6 calculustokenizerelaychars_p62 = some calculustokenizerelaychars_t62 := by
  decide +kernel
def calculustokenizerelaychars_p63 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t63 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p63_tok : tokenizeT 5 calculustokenizerelaychars_p63 = some calculustokenizerelaychars_t63 := by
  decide +kernel
def calculustokenizerelaychars_p64 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizerelaychars_t64 : List String := ["(", "assign"]
theorem calculustokenizerelaychars_p64_tok : tokenizeT 8 calculustokenizerelaychars_p64 = some calculustokenizerelaychars_t64 := by
  decide +kernel
def calculustokenizerelaychars_p65 : List Char := ['o', 'f', 'f']
def calculustokenizerelaychars_t65 : List String := ["off"]
theorem calculustokenizerelaychars_p65_tok : tokenizeT 4 calculustokenizerelaychars_p65 = some calculustokenizerelaychars_t65 := by
  decide +kernel
def calculustokenizerelaychars_p66 : List Char := ['0', ')']
def calculustokenizerelaychars_t66 : List String := ["0", ")"]
theorem calculustokenizerelaychars_p66_tok : tokenizeT 3 calculustokenizerelaychars_p66 = some calculustokenizerelaychars_t66 := by
  decide +kernel
def calculustokenizerelaychars_p67 : List Char := ['(', 'w', 'h', 'i', 'l', 'e']
def calculustokenizerelaychars_t67 : List String := ["(", "while"]
theorem calculustokenizerelaychars_p67_tok : tokenizeT 7 calculustokenizerelaychars_p67 = some calculustokenizerelaychars_t67 := by
  decide +kernel
def calculustokenizerelaychars_p68 : List Char := ['(', '<']
def calculustokenizerelaychars_t68 : List String := ["(", "<"]
theorem calculustokenizerelaychars_p68_tok : tokenizeT 3 calculustokenizerelaychars_p68 = some calculustokenizerelaychars_t68 := by
  decide +kernel
def calculustokenizerelaychars_p69 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t69 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p69_tok : tokenizeT 6 calculustokenizerelaychars_p69 = some calculustokenizerelaychars_t69 := by
  decide +kernel
def calculustokenizerelaychars_p70 : List Char := ['o', 'f', 'f']
def calculustokenizerelaychars_t70 : List String := ["off"]
theorem calculustokenizerelaychars_p70_tok : tokenizeT 4 calculustokenizerelaychars_p70 = some calculustokenizerelaychars_t70 := by
  decide +kernel
def calculustokenizerelaychars_p71 : List Char := ['r', ')', ')']
def calculustokenizerelaychars_t71 : List String := ["r", ")", ")"]
theorem calculustokenizerelaychars_p71_tok : tokenizeT 4 calculustokenizerelaychars_p71 = some calculustokenizerelaychars_t71 := by
  decide +kernel
def calculustokenizerelaychars_p72 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t72 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p72_tok : tokenizeT 5 calculustokenizerelaychars_p72 = some calculustokenizerelaychars_t72 := by
  decide +kernel
def calculustokenizerelaychars_p73 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t73 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p73_tok : tokenizeT 5 calculustokenizerelaychars_p73 = some calculustokenizerelaychars_t73 := by
  decide +kernel
def calculustokenizerelaychars_p74 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t74 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p74_tok : tokenizeT 5 calculustokenizerelaychars_p74 = some calculustokenizerelaychars_t74 := by
  decide +kernel
def calculustokenizerelaychars_p75 : List Char := ['(', 'a', 'c', 't', 'i', 'o', 'n']
def calculustokenizerelaychars_t75 : List String := ["(", "action"]
theorem calculustokenizerelaychars_p75_tok : tokenizeT 8 calculustokenizerelaychars_p75 = some calculustokenizerelaychars_t75 := by
  decide +kernel
def calculustokenizerelaychars_p76 : List Char := ['$', 't', '1', '8']
def calculustokenizerelaychars_t76 : List String := ["$t18"]
theorem calculustokenizerelaychars_p76_tok : tokenizeT 5 calculustokenizerelaychars_p76 = some calculustokenizerelaychars_t76 := by
  decide +kernel
def calculustokenizerelaychars_p77 : List Char := ['w', 'r', 'i', 't', 'e', '_', 'b', 'l', 'o', 'c', 'k']
def calculustokenizerelaychars_t77 : List String := ["write_block"]
theorem calculustokenizerelaychars_p77_tok : tokenizeT 12 calculustokenizerelaychars_p77 = some calculustokenizerelaychars_t77 := by
  decide +kernel
def calculustokenizerelaychars_p78 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t78 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p78_tok : tokenizeT 6 calculustokenizerelaychars_p78 = some calculustokenizerelaychars_t78 := by
  decide +kernel
def calculustokenizerelaychars_p79 : List Char := ['b']
def calculustokenizerelaychars_t79 : List String := ["b"]
theorem calculustokenizerelaychars_p79_tok : tokenizeT 2 calculustokenizerelaychars_p79 = some calculustokenizerelaychars_t79 := by
  decide +kernel
def calculustokenizerelaychars_p80 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t80 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p80_tok : tokenizeT 6 calculustokenizerelaychars_p80 = some calculustokenizerelaychars_t80 := by
  decide +kernel
def calculustokenizerelaychars_p81 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizerelaychars_t81 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizerelaychars_p81_tok : tokenizeT 29 calculustokenizerelaychars_p81 = some calculustokenizerelaychars_t81 := by
  decide +kernel
def calculustokenizerelaychars_p82 : List Char := ['o', 'f', 'f', ')']
def calculustokenizerelaychars_t82 : List String := ["off", ")"]
theorem calculustokenizerelaychars_p82_tok : tokenizeT 5 calculustokenizerelaychars_p82 = some calculustokenizerelaychars_t82 := by
  decide +kernel
def calculustokenizerelaychars_p83 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizerelaychars_t83 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizerelaychars_p83_tok : tokenizeT 29 calculustokenizerelaychars_p83 = some calculustokenizerelaychars_t83 := by
  decide +kernel
def calculustokenizerelaychars_p84 : List Char := ['r', ')', ')', ')', ')']
def calculustokenizerelaychars_t84 : List String := ["r", ")", ")", ")", ")"]
theorem calculustokenizerelaychars_p84_tok : tokenizeT 6 calculustokenizerelaychars_p84 = some calculustokenizerelaychars_t84 := by
  decide +kernel
def calculustokenizerelaychars_p85 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizerelaychars_t85 : List String := ["(", "assign"]
theorem calculustokenizerelaychars_p85_tok : tokenizeT 8 calculustokenizerelaychars_p85 = some calculustokenizerelaychars_t85 := by
  decide +kernel
def calculustokenizerelaychars_p86 : List Char := ['w']
def calculustokenizerelaychars_t86 : List String := ["w"]
theorem calculustokenizerelaychars_p86_tok : tokenizeT 2 calculustokenizerelaychars_p86 = some calculustokenizerelaychars_t86 := by
  decide +kernel
def calculustokenizerelaychars_p87 : List Char := ['$', 't', '1', '8', ')', ')']
def calculustokenizerelaychars_t87 : List String := ["$t18", ")", ")"]
theorem calculustokenizerelaychars_p87_tok : tokenizeT 7 calculustokenizerelaychars_p87 = some calculustokenizerelaychars_t87 := by
  decide +kernel
def calculustokenizerelaychars_p88 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t88 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p88_tok : tokenizeT 5 calculustokenizerelaychars_p88 = some calculustokenizerelaychars_t88 := by
  decide +kernel
def calculustokenizerelaychars_p89 : List Char := ['(', 'i', 'f']
def calculustokenizerelaychars_t89 : List String := ["(", "if"]
theorem calculustokenizerelaychars_p89_tok : tokenizeT 4 calculustokenizerelaychars_p89 = some calculustokenizerelaychars_t89 := by
  decide +kernel
def calculustokenizerelaychars_p90 : List Char := ['(', '<', '=']
def calculustokenizerelaychars_t90 : List String := ["(", "<="]
theorem calculustokenizerelaychars_p90_tok : tokenizeT 4 calculustokenizerelaychars_p90 = some calculustokenizerelaychars_t90 := by
  decide +kernel
def calculustokenizerelaychars_p91 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t91 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p91_tok : tokenizeT 6 calculustokenizerelaychars_p91 = some calculustokenizerelaychars_t91 := by
  decide +kernel
def calculustokenizerelaychars_p92 : List Char := ['w']
def calculustokenizerelaychars_t92 : List String := ["w"]
theorem calculustokenizerelaychars_p92_tok : tokenizeT 2 calculustokenizerelaychars_p92 = some calculustokenizerelaychars_t92 := by
  decide +kernel
def calculustokenizerelaychars_p93 : List Char := ['0', ')', ')']
def calculustokenizerelaychars_t93 : List String := ["0", ")", ")"]
theorem calculustokenizerelaychars_p93_tok : tokenizeT 4 calculustokenizerelaychars_p93 = some calculustokenizerelaychars_t93 := by
  decide +kernel
def calculustokenizerelaychars_p94 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t94 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p94_tok : tokenizeT 5 calculustokenizerelaychars_p94 = some calculustokenizerelaychars_t94 := by
  decide +kernel
def calculustokenizerelaychars_p95 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t95 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p95_tok : tokenizeT 5 calculustokenizerelaychars_p95 = some calculustokenizerelaychars_t95 := by
  decide +kernel
def calculustokenizerelaychars_p96 : List Char := ['(', 'g', 'e', 't']
def calculustokenizerelaychars_t96 : List String := ["(", "get"]
theorem calculustokenizerelaychars_p96_tok : tokenizeT 5 calculustokenizerelaychars_p96 = some calculustokenizerelaychars_t96 := by
  decide +kernel
def calculustokenizerelaychars_p97 : List Char := ['$', 't', '1', '9']
def calculustokenizerelaychars_t97 : List String := ["$t19"]
theorem calculustokenizerelaychars_p97_tok : tokenizeT 5 calculustokenizerelaychars_p97 = some calculustokenizerelaychars_t97 := by
  decide +kernel
def calculustokenizerelaychars_p98 : List Char := [Char.ofNat 963]
def calculustokenizerelaychars_t98 : List String := ["σ"]
theorem calculustokenizerelaychars_p98_tok : tokenizeT 2 calculustokenizerelaychars_p98 = some calculustokenizerelaychars_t98 := by
  decide +kernel
def calculustokenizerelaychars_p99 : List Char := ['l', 'o', 's', 't', ')']
def calculustokenizerelaychars_t99 : List String := ["lost", ")"]
theorem calculustokenizerelaychars_p99_tok : tokenizeT 6 calculustokenizerelaychars_p99 = some calculustokenizerelaychars_t99 := by
  decide +kernel
def calculustokenizerelaychars_p100 : List Char := ['(', 's', 'e', 'q']
def calculustokenizerelaychars_t100 : List String := ["(", "seq"]
theorem calculustokenizerelaychars_p100_tok : tokenizeT 5 calculustokenizerelaychars_p100 = some calculustokenizerelaychars_t100 := by
  decide +kernel
def calculustokenizerelaychars_p101 : List Char := ['(', 'g', 'e', 't']
def calculustokenizerelaychars_t101 : List String := ["(", "get"]
theorem calculustokenizerelaychars_p101_tok : tokenizeT 5 calculustokenizerelaychars_p101 = some calculustokenizerelaychars_t101 := by
  decide +kernel
def calculustokenizerelaychars_p102 : List Char := ['$', 't', '2', '0']
def calculustokenizerelaychars_t102 : List String := ["$t20"]
theorem calculustokenizerelaychars_p102_tok : tokenizeT 5 calculustokenizerelaychars_p102 = some calculustokenizerelaychars_t102 := by
  decide +kernel
def calculustokenizerelaychars_p103 : List Char := ['b']
def calculustokenizerelaychars_t103 : List String := ["b"]
theorem calculustokenizerelaychars_p103_tok : tokenizeT 2 calculustokenizerelaychars_p103 = some calculustokenizerelaychars_t103 := by
  decide +kernel
def calculustokenizerelaychars_p104 : List Char := ['b', 'y', 't', 'e', 's', ')']
def calculustokenizerelaychars_t104 : List String := ["bytes", ")"]
theorem calculustokenizerelaychars_p104_tok : tokenizeT 7 calculustokenizerelaychars_p104 = some calculustokenizerelaychars_t104 := by
  decide +kernel
def calculustokenizerelaychars_p105 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def calculustokenizerelaychars_t105 : List String := ["(", "set-attr"]
theorem calculustokenizerelaychars_p105_tok : tokenizeT 10 calculustokenizerelaychars_p105 = some calculustokenizerelaychars_t105 := by
  decide +kernel
def calculustokenizerelaychars_p106 : List Char := [Char.ofNat 963]
def calculustokenizerelaychars_t106 : List String := ["σ"]
theorem calculustokenizerelaychars_p106_tok : tokenizeT 2 calculustokenizerelaychars_p106 = some calculustokenizerelaychars_t106 := by
  decide +kernel
def calculustokenizerelaychars_p107 : List Char := ['l', 'o', 's', 't']
def calculustokenizerelaychars_t107 : List String := ["lost"]
theorem calculustokenizerelaychars_p107_tok : tokenizeT 5 calculustokenizerelaychars_p107 = some calculustokenizerelaychars_t107 := by
  decide +kernel
def calculustokenizerelaychars_p108 : List Char := ['(', 'a', 'p', 'p', 'e', 'n', 'd']
def calculustokenizerelaychars_t108 : List String := ["(", "append"]
theorem calculustokenizerelaychars_p108_tok : tokenizeT 8 calculustokenizerelaychars_p108 = some calculustokenizerelaychars_t108 := by
  decide +kernel
def calculustokenizerelaychars_p109 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t109 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p109_tok : tokenizeT 6 calculustokenizerelaychars_p109 = some calculustokenizerelaychars_t109 := by
  decide +kernel
def calculustokenizerelaychars_p110 : List Char := ['$', 't', '1', '9']
def calculustokenizerelaychars_t110 : List String := ["$t19"]
theorem calculustokenizerelaychars_p110_tok : tokenizeT 5 calculustokenizerelaychars_p110 = some calculustokenizerelaychars_t110 := by
  decide +kernel
def calculustokenizerelaychars_p111 : List Char := ['(', 's', 'l', 'i', 'c', 'e']
def calculustokenizerelaychars_t111 : List String := ["(", "slice"]
theorem calculustokenizerelaychars_p111_tok : tokenizeT 7 calculustokenizerelaychars_p111 = some calculustokenizerelaychars_t111 := by
  decide +kernel
def calculustokenizerelaychars_p112 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t112 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p112_tok : tokenizeT 6 calculustokenizerelaychars_p112 = some calculustokenizerelaychars_t112 := by
  decide +kernel
def calculustokenizerelaychars_p113 : List Char := ['$', 't', '2', '0']
def calculustokenizerelaychars_t113 : List String := ["$t20"]
theorem calculustokenizerelaychars_p113_tok : tokenizeT 5 calculustokenizerelaychars_p113 = some calculustokenizerelaychars_t113 := by
  decide +kernel
def calculustokenizerelaychars_p114 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t114 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p114_tok : tokenizeT 6 calculustokenizerelaychars_p114 = some calculustokenizerelaychars_t114 := by
  decide +kernel
def calculustokenizerelaychars_p115 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizerelaychars_t115 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizerelaychars_p115_tok : tokenizeT 29 calculustokenizerelaychars_p115 = some calculustokenizerelaychars_t115 := by
  decide +kernel
def calculustokenizerelaychars_p116 : List Char := ['o', 'f', 'f', ')']
def calculustokenizerelaychars_t116 : List String := ["off", ")"]
theorem calculustokenizerelaychars_p116_tok : tokenizeT 5 calculustokenizerelaychars_p116 = some calculustokenizerelaychars_t116 := by
  decide +kernel
def calculustokenizerelaychars_p117 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def calculustokenizerelaychars_t117 : List String := ["(", "range:0:4611686018427387903"]
theorem calculustokenizerelaychars_p117_tok : tokenizeT 29 calculustokenizerelaychars_p117 = some calculustokenizerelaychars_t117 := by
  decide +kernel
def calculustokenizerelaychars_p118 : List Char := ['r', ')', ')', ')', ')', ')', ')', ')', ')', ')']
def calculustokenizerelaychars_t118 : List String := ["r", ")", ")", ")", ")", ")", ")", ")", ")", ")"]
theorem calculustokenizerelaychars_p118_tok : tokenizeT 11 calculustokenizerelaychars_p118 = some calculustokenizerelaychars_t118 := by
  decide +kernel
def calculustokenizerelaychars_p119 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def calculustokenizerelaychars_t119 : List String := ["(", "return"]
theorem calculustokenizerelaychars_p119_tok : tokenizeT 8 calculustokenizerelaychars_p119 = some calculustokenizerelaychars_t119 := by
  decide +kernel
def calculustokenizerelaychars_p120 : List Char := ['2', ')', ')']
def calculustokenizerelaychars_t120 : List String := ["2", ")", ")"]
theorem calculustokenizerelaychars_p120_tok : tokenizeT 4 calculustokenizerelaychars_p120 = some calculustokenizerelaychars_t120 := by
  decide +kernel
def calculustokenizerelaychars_p121 : List Char := ['p', 'a', 's', 's', ')']
def calculustokenizerelaychars_t121 : List String := ["pass", ")"]
theorem calculustokenizerelaychars_p121_tok : tokenizeT 6 calculustokenizerelaychars_p121 = some calculustokenizerelaychars_t121 := by
  decide +kernel
def calculustokenizerelaychars_p122 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def calculustokenizerelaychars_t122 : List String := ["(", "assign"]
theorem calculustokenizerelaychars_p122_tok : tokenizeT 8 calculustokenizerelaychars_p122 = some calculustokenizerelaychars_t122 := by
  decide +kernel
def calculustokenizerelaychars_p123 : List Char := ['o', 'f', 'f']
def calculustokenizerelaychars_t123 : List String := ["off"]
theorem calculustokenizerelaychars_p123_tok : tokenizeT 4 calculustokenizerelaychars_p123 = some calculustokenizerelaychars_t123 := by
  decide +kernel
def calculustokenizerelaychars_p124 : List Char := ['(', '+']
def calculustokenizerelaychars_t124 : List String := ["(", "+"]
theorem calculustokenizerelaychars_p124_tok : tokenizeT 3 calculustokenizerelaychars_p124 = some calculustokenizerelaychars_t124 := by
  decide +kernel
def calculustokenizerelaychars_p125 : List Char := ['(', 'p', 'a', 'i', 'r']
def calculustokenizerelaychars_t125 : List String := ["(", "pair"]
theorem calculustokenizerelaychars_p125_tok : tokenizeT 6 calculustokenizerelaychars_p125 = some calculustokenizerelaychars_t125 := by
  decide +kernel
def calculustokenizerelaychars_p126 : List Char := ['o', 'f', 'f']
def calculustokenizerelaychars_t126 : List String := ["off"]
theorem calculustokenizerelaychars_p126_tok : tokenizeT 4 calculustokenizerelaychars_p126 = some calculustokenizerelaychars_t126 := by
  decide +kernel
def calculustokenizerelaychars_p127 : List Char := ['w', ')', ')', ')', ')', ')']
def calculustokenizerelaychars_t127 : List String := ["w", ")", ")", ")", ")", ")"]
theorem calculustokenizerelaychars_p127_tok : tokenizeT 7 calculustokenizerelaychars_p127 = some calculustokenizerelaychars_t127 := by
  decide +kernel
def calculustokenizerelaychars_p128 : List Char := ['p', 'a', 's', 's', ')', ')', ')', ')', ')', ')']
def calculustokenizerelaychars_t128 : List String := ["pass", ")", ")", ")", ")", ")", ")"]
theorem calculustokenizerelaychars_p128_tok : tokenizeT 11 calculustokenizerelaychars_p128 = some calculustokenizerelaychars_t128 := by
  decide +kernel
def calculustokenizerelaychars_p129 : List Char := ['p', 'a', 's', 's', ')', ')', ')', ')', ')', ')', ')', ')']
def calculustokenizerelaychars_t129 : List String := ["pass", ")", ")", ")", ")", ")", ")", ")", ")"]
theorem calculustokenizerelaychars_p129_tok : tokenizeT 13 calculustokenizerelaychars_p129 = some calculustokenizerelaychars_t129 := by
  decide +kernel
def calculustokenizerelaychars_s129 : List Char := calculustokenizerelaychars_p129
def calculustokenizerelaychars_st129 : List String := calculustokenizerelaychars_t129
theorem calculustokenizerelaychars_s129_tok : tokenizeT 13 calculustokenizerelaychars_s129 = some calculustokenizerelaychars_st129 := calculustokenizerelaychars_p129_tok
def calculustokenizerelaychars_s128 : List Char := calculustokenizerelaychars_p128 ++ ' ' :: calculustokenizerelaychars_s129
def calculustokenizerelaychars_st128 : List String := calculustokenizerelaychars_t128 ++ calculustokenizerelaychars_st129
theorem calculustokenizerelaychars_s128_tok : tokenizeT 25 calculustokenizerelaychars_s128 = some calculustokenizerelaychars_st128 :=
  tokenizeT_concat_space 11 13 _ _ _ _ calculustokenizerelaychars_p128_tok calculustokenizerelaychars_s129_tok
def calculustokenizerelaychars_s127 : List Char := calculustokenizerelaychars_p127 ++ ' ' :: calculustokenizerelaychars_s128
def calculustokenizerelaychars_st127 : List String := calculustokenizerelaychars_t127 ++ calculustokenizerelaychars_st128
theorem calculustokenizerelaychars_s127_tok : tokenizeT 33 calculustokenizerelaychars_s127 = some calculustokenizerelaychars_st127 :=
  tokenizeT_concat_space 7 25 _ _ _ _ calculustokenizerelaychars_p127_tok calculustokenizerelaychars_s128_tok
def calculustokenizerelaychars_s126 : List Char := calculustokenizerelaychars_p126 ++ ' ' :: calculustokenizerelaychars_s127
def calculustokenizerelaychars_st126 : List String := calculustokenizerelaychars_t126 ++ calculustokenizerelaychars_st127
theorem calculustokenizerelaychars_s126_tok : tokenizeT 38 calculustokenizerelaychars_s126 = some calculustokenizerelaychars_st126 :=
  tokenizeT_concat_space 4 33 _ _ _ _ calculustokenizerelaychars_p126_tok calculustokenizerelaychars_s127_tok
def calculustokenizerelaychars_s125 : List Char := calculustokenizerelaychars_p125 ++ ' ' :: calculustokenizerelaychars_s126
def calculustokenizerelaychars_st125 : List String := calculustokenizerelaychars_t125 ++ calculustokenizerelaychars_st126
theorem calculustokenizerelaychars_s125_tok : tokenizeT 45 calculustokenizerelaychars_s125 = some calculustokenizerelaychars_st125 :=
  tokenizeT_concat_space 6 38 _ _ _ _ calculustokenizerelaychars_p125_tok calculustokenizerelaychars_s126_tok
def calculustokenizerelaychars_s124 : List Char := calculustokenizerelaychars_p124 ++ ' ' :: calculustokenizerelaychars_s125
def calculustokenizerelaychars_st124 : List String := calculustokenizerelaychars_t124 ++ calculustokenizerelaychars_st125
theorem calculustokenizerelaychars_s124_tok : tokenizeT 49 calculustokenizerelaychars_s124 = some calculustokenizerelaychars_st124 :=
  tokenizeT_concat_space 3 45 _ _ _ _ calculustokenizerelaychars_p124_tok calculustokenizerelaychars_s125_tok
def calculustokenizerelaychars_s123 : List Char := calculustokenizerelaychars_p123 ++ ' ' :: calculustokenizerelaychars_s124
def calculustokenizerelaychars_st123 : List String := calculustokenizerelaychars_t123 ++ calculustokenizerelaychars_st124
theorem calculustokenizerelaychars_s123_tok : tokenizeT 54 calculustokenizerelaychars_s123 = some calculustokenizerelaychars_st123 :=
  tokenizeT_concat_space 4 49 _ _ _ _ calculustokenizerelaychars_p123_tok calculustokenizerelaychars_s124_tok
def calculustokenizerelaychars_s122 : List Char := calculustokenizerelaychars_p122 ++ ' ' :: calculustokenizerelaychars_s123
def calculustokenizerelaychars_st122 : List String := calculustokenizerelaychars_t122 ++ calculustokenizerelaychars_st123
theorem calculustokenizerelaychars_s122_tok : tokenizeT 63 calculustokenizerelaychars_s122 = some calculustokenizerelaychars_st122 :=
  tokenizeT_concat_space 8 54 _ _ _ _ calculustokenizerelaychars_p122_tok calculustokenizerelaychars_s123_tok
def calculustokenizerelaychars_s121 : List Char := calculustokenizerelaychars_p121 ++ ' ' :: calculustokenizerelaychars_s122
def calculustokenizerelaychars_st121 : List String := calculustokenizerelaychars_t121 ++ calculustokenizerelaychars_st122
theorem calculustokenizerelaychars_s121_tok : tokenizeT 70 calculustokenizerelaychars_s121 = some calculustokenizerelaychars_st121 :=
  tokenizeT_concat_space 6 63 _ _ _ _ calculustokenizerelaychars_p121_tok calculustokenizerelaychars_s122_tok
def calculustokenizerelaychars_s120 : List Char := calculustokenizerelaychars_p120 ++ ' ' :: calculustokenizerelaychars_s121
def calculustokenizerelaychars_st120 : List String := calculustokenizerelaychars_t120 ++ calculustokenizerelaychars_st121
theorem calculustokenizerelaychars_s120_tok : tokenizeT 75 calculustokenizerelaychars_s120 = some calculustokenizerelaychars_st120 :=
  tokenizeT_concat_space 4 70 _ _ _ _ calculustokenizerelaychars_p120_tok calculustokenizerelaychars_s121_tok
def calculustokenizerelaychars_s119 : List Char := calculustokenizerelaychars_p119 ++ ' ' :: calculustokenizerelaychars_s120
def calculustokenizerelaychars_st119 : List String := calculustokenizerelaychars_t119 ++ calculustokenizerelaychars_st120
theorem calculustokenizerelaychars_s119_tok : tokenizeT 84 calculustokenizerelaychars_s119 = some calculustokenizerelaychars_st119 :=
  tokenizeT_concat_space 8 75 _ _ _ _ calculustokenizerelaychars_p119_tok calculustokenizerelaychars_s120_tok
def calculustokenizerelaychars_s118 : List Char := calculustokenizerelaychars_p118 ++ ' ' :: calculustokenizerelaychars_s119
def calculustokenizerelaychars_st118 : List String := calculustokenizerelaychars_t118 ++ calculustokenizerelaychars_st119
theorem calculustokenizerelaychars_s118_tok : tokenizeT 96 calculustokenizerelaychars_s118 = some calculustokenizerelaychars_st118 :=
  tokenizeT_concat_space 11 84 _ _ _ _ calculustokenizerelaychars_p118_tok calculustokenizerelaychars_s119_tok
def calculustokenizerelaychars_s117 : List Char := calculustokenizerelaychars_p117 ++ ' ' :: calculustokenizerelaychars_s118
def calculustokenizerelaychars_st117 : List String := calculustokenizerelaychars_t117 ++ calculustokenizerelaychars_st118
theorem calculustokenizerelaychars_s117_tok : tokenizeT 126 calculustokenizerelaychars_s117 = some calculustokenizerelaychars_st117 :=
  tokenizeT_concat_space 29 96 _ _ _ _ calculustokenizerelaychars_p117_tok calculustokenizerelaychars_s118_tok
def calculustokenizerelaychars_s116 : List Char := calculustokenizerelaychars_p116 ++ ' ' :: calculustokenizerelaychars_s117
def calculustokenizerelaychars_st116 : List String := calculustokenizerelaychars_t116 ++ calculustokenizerelaychars_st117
theorem calculustokenizerelaychars_s116_tok : tokenizeT 132 calculustokenizerelaychars_s116 = some calculustokenizerelaychars_st116 :=
  tokenizeT_concat_space 5 126 _ _ _ _ calculustokenizerelaychars_p116_tok calculustokenizerelaychars_s117_tok
def calculustokenizerelaychars_s115 : List Char := calculustokenizerelaychars_p115 ++ ' ' :: calculustokenizerelaychars_s116
def calculustokenizerelaychars_st115 : List String := calculustokenizerelaychars_t115 ++ calculustokenizerelaychars_st116
theorem calculustokenizerelaychars_s115_tok : tokenizeT 162 calculustokenizerelaychars_s115 = some calculustokenizerelaychars_st115 :=
  tokenizeT_concat_space 29 132 _ _ _ _ calculustokenizerelaychars_p115_tok calculustokenizerelaychars_s116_tok
def calculustokenizerelaychars_s114 : List Char := calculustokenizerelaychars_p114 ++ ' ' :: calculustokenizerelaychars_s115
def calculustokenizerelaychars_st114 : List String := calculustokenizerelaychars_t114 ++ calculustokenizerelaychars_st115
theorem calculustokenizerelaychars_s114_tok : tokenizeT 169 calculustokenizerelaychars_s114 = some calculustokenizerelaychars_st114 :=
  tokenizeT_concat_space 6 162 _ _ _ _ calculustokenizerelaychars_p114_tok calculustokenizerelaychars_s115_tok
def calculustokenizerelaychars_s113 : List Char := calculustokenizerelaychars_p113 ++ ' ' :: calculustokenizerelaychars_s114
def calculustokenizerelaychars_st113 : List String := calculustokenizerelaychars_t113 ++ calculustokenizerelaychars_st114
theorem calculustokenizerelaychars_s113_tok : tokenizeT 175 calculustokenizerelaychars_s113 = some calculustokenizerelaychars_st113 :=
  tokenizeT_concat_space 5 169 _ _ _ _ calculustokenizerelaychars_p113_tok calculustokenizerelaychars_s114_tok
def calculustokenizerelaychars_s112 : List Char := calculustokenizerelaychars_p112 ++ ' ' :: calculustokenizerelaychars_s113
def calculustokenizerelaychars_st112 : List String := calculustokenizerelaychars_t112 ++ calculustokenizerelaychars_st113
theorem calculustokenizerelaychars_s112_tok : tokenizeT 182 calculustokenizerelaychars_s112 = some calculustokenizerelaychars_st112 :=
  tokenizeT_concat_space 6 175 _ _ _ _ calculustokenizerelaychars_p112_tok calculustokenizerelaychars_s113_tok
def calculustokenizerelaychars_s111 : List Char := calculustokenizerelaychars_p111 ++ ' ' :: calculustokenizerelaychars_s112
def calculustokenizerelaychars_st111 : List String := calculustokenizerelaychars_t111 ++ calculustokenizerelaychars_st112
theorem calculustokenizerelaychars_s111_tok : tokenizeT 190 calculustokenizerelaychars_s111 = some calculustokenizerelaychars_st111 :=
  tokenizeT_concat_space 7 182 _ _ _ _ calculustokenizerelaychars_p111_tok calculustokenizerelaychars_s112_tok
def calculustokenizerelaychars_s110 : List Char := calculustokenizerelaychars_p110 ++ ' ' :: calculustokenizerelaychars_s111
def calculustokenizerelaychars_st110 : List String := calculustokenizerelaychars_t110 ++ calculustokenizerelaychars_st111
theorem calculustokenizerelaychars_s110_tok : tokenizeT 196 calculustokenizerelaychars_s110 = some calculustokenizerelaychars_st110 :=
  tokenizeT_concat_space 5 190 _ _ _ _ calculustokenizerelaychars_p110_tok calculustokenizerelaychars_s111_tok
def calculustokenizerelaychars_s109 : List Char := calculustokenizerelaychars_p109 ++ ' ' :: calculustokenizerelaychars_s110
def calculustokenizerelaychars_st109 : List String := calculustokenizerelaychars_t109 ++ calculustokenizerelaychars_st110
theorem calculustokenizerelaychars_s109_tok : tokenizeT 203 calculustokenizerelaychars_s109 = some calculustokenizerelaychars_st109 :=
  tokenizeT_concat_space 6 196 _ _ _ _ calculustokenizerelaychars_p109_tok calculustokenizerelaychars_s110_tok
def calculustokenizerelaychars_s108 : List Char := calculustokenizerelaychars_p108 ++ ' ' :: calculustokenizerelaychars_s109
def calculustokenizerelaychars_st108 : List String := calculustokenizerelaychars_t108 ++ calculustokenizerelaychars_st109
theorem calculustokenizerelaychars_s108_tok : tokenizeT 212 calculustokenizerelaychars_s108 = some calculustokenizerelaychars_st108 :=
  tokenizeT_concat_space 8 203 _ _ _ _ calculustokenizerelaychars_p108_tok calculustokenizerelaychars_s109_tok
def calculustokenizerelaychars_s107 : List Char := calculustokenizerelaychars_p107 ++ ' ' :: calculustokenizerelaychars_s108
def calculustokenizerelaychars_st107 : List String := calculustokenizerelaychars_t107 ++ calculustokenizerelaychars_st108
theorem calculustokenizerelaychars_s107_tok : tokenizeT 218 calculustokenizerelaychars_s107 = some calculustokenizerelaychars_st107 :=
  tokenizeT_concat_space 5 212 _ _ _ _ calculustokenizerelaychars_p107_tok calculustokenizerelaychars_s108_tok
def calculustokenizerelaychars_s106 : List Char := calculustokenizerelaychars_p106 ++ ' ' :: calculustokenizerelaychars_s107
def calculustokenizerelaychars_st106 : List String := calculustokenizerelaychars_t106 ++ calculustokenizerelaychars_st107
theorem calculustokenizerelaychars_s106_tok : tokenizeT 221 calculustokenizerelaychars_s106 = some calculustokenizerelaychars_st106 :=
  tokenizeT_concat_space 2 218 _ _ _ _ calculustokenizerelaychars_p106_tok calculustokenizerelaychars_s107_tok
def calculustokenizerelaychars_s105 : List Char := calculustokenizerelaychars_p105 ++ ' ' :: calculustokenizerelaychars_s106
def calculustokenizerelaychars_st105 : List String := calculustokenizerelaychars_t105 ++ calculustokenizerelaychars_st106
theorem calculustokenizerelaychars_s105_tok : tokenizeT 232 calculustokenizerelaychars_s105 = some calculustokenizerelaychars_st105 :=
  tokenizeT_concat_space 10 221 _ _ _ _ calculustokenizerelaychars_p105_tok calculustokenizerelaychars_s106_tok
def calculustokenizerelaychars_s104 : List Char := calculustokenizerelaychars_p104 ++ ' ' :: calculustokenizerelaychars_s105
def calculustokenizerelaychars_st104 : List String := calculustokenizerelaychars_t104 ++ calculustokenizerelaychars_st105
theorem calculustokenizerelaychars_s104_tok : tokenizeT 240 calculustokenizerelaychars_s104 = some calculustokenizerelaychars_st104 :=
  tokenizeT_concat_space 7 232 _ _ _ _ calculustokenizerelaychars_p104_tok calculustokenizerelaychars_s105_tok
def calculustokenizerelaychars_s103 : List Char := calculustokenizerelaychars_p103 ++ ' ' :: calculustokenizerelaychars_s104
def calculustokenizerelaychars_st103 : List String := calculustokenizerelaychars_t103 ++ calculustokenizerelaychars_st104
theorem calculustokenizerelaychars_s103_tok : tokenizeT 243 calculustokenizerelaychars_s103 = some calculustokenizerelaychars_st103 :=
  tokenizeT_concat_space 2 240 _ _ _ _ calculustokenizerelaychars_p103_tok calculustokenizerelaychars_s104_tok
def calculustokenizerelaychars_s102 : List Char := calculustokenizerelaychars_p102 ++ ' ' :: calculustokenizerelaychars_s103
def calculustokenizerelaychars_st102 : List String := calculustokenizerelaychars_t102 ++ calculustokenizerelaychars_st103
theorem calculustokenizerelaychars_s102_tok : tokenizeT 249 calculustokenizerelaychars_s102 = some calculustokenizerelaychars_st102 :=
  tokenizeT_concat_space 5 243 _ _ _ _ calculustokenizerelaychars_p102_tok calculustokenizerelaychars_s103_tok
def calculustokenizerelaychars_s101 : List Char := calculustokenizerelaychars_p101 ++ ' ' :: calculustokenizerelaychars_s102
def calculustokenizerelaychars_st101 : List String := calculustokenizerelaychars_t101 ++ calculustokenizerelaychars_st102
theorem calculustokenizerelaychars_s101_tok : tokenizeT 255 calculustokenizerelaychars_s101 = some calculustokenizerelaychars_st101 :=
  tokenizeT_concat_space 5 249 _ _ _ _ calculustokenizerelaychars_p101_tok calculustokenizerelaychars_s102_tok
def calculustokenizerelaychars_s100 : List Char := calculustokenizerelaychars_p100 ++ ' ' :: calculustokenizerelaychars_s101
def calculustokenizerelaychars_st100 : List String := calculustokenizerelaychars_t100 ++ calculustokenizerelaychars_st101
theorem calculustokenizerelaychars_s100_tok : tokenizeT 261 calculustokenizerelaychars_s100 = some calculustokenizerelaychars_st100 :=
  tokenizeT_concat_space 5 255 _ _ _ _ calculustokenizerelaychars_p100_tok calculustokenizerelaychars_s101_tok
def calculustokenizerelaychars_s99 : List Char := calculustokenizerelaychars_p99 ++ ' ' :: calculustokenizerelaychars_s100
def calculustokenizerelaychars_st99 : List String := calculustokenizerelaychars_t99 ++ calculustokenizerelaychars_st100
theorem calculustokenizerelaychars_s99_tok : tokenizeT 268 calculustokenizerelaychars_s99 = some calculustokenizerelaychars_st99 :=
  tokenizeT_concat_space 6 261 _ _ _ _ calculustokenizerelaychars_p99_tok calculustokenizerelaychars_s100_tok
def calculustokenizerelaychars_s98 : List Char := calculustokenizerelaychars_p98 ++ ' ' :: calculustokenizerelaychars_s99
def calculustokenizerelaychars_st98 : List String := calculustokenizerelaychars_t98 ++ calculustokenizerelaychars_st99
theorem calculustokenizerelaychars_s98_tok : tokenizeT 271 calculustokenizerelaychars_s98 = some calculustokenizerelaychars_st98 :=
  tokenizeT_concat_space 2 268 _ _ _ _ calculustokenizerelaychars_p98_tok calculustokenizerelaychars_s99_tok
def calculustokenizerelaychars_s97 : List Char := calculustokenizerelaychars_p97 ++ ' ' :: calculustokenizerelaychars_s98
def calculustokenizerelaychars_st97 : List String := calculustokenizerelaychars_t97 ++ calculustokenizerelaychars_st98
theorem calculustokenizerelaychars_s97_tok : tokenizeT 277 calculustokenizerelaychars_s97 = some calculustokenizerelaychars_st97 :=
  tokenizeT_concat_space 5 271 _ _ _ _ calculustokenizerelaychars_p97_tok calculustokenizerelaychars_s98_tok
def calculustokenizerelaychars_s96 : List Char := calculustokenizerelaychars_p96 ++ ' ' :: calculustokenizerelaychars_s97
def calculustokenizerelaychars_st96 : List String := calculustokenizerelaychars_t96 ++ calculustokenizerelaychars_st97
theorem calculustokenizerelaychars_s96_tok : tokenizeT 283 calculustokenizerelaychars_s96 = some calculustokenizerelaychars_st96 :=
  tokenizeT_concat_space 5 277 _ _ _ _ calculustokenizerelaychars_p96_tok calculustokenizerelaychars_s97_tok
def calculustokenizerelaychars_s95 : List Char := calculustokenizerelaychars_p95 ++ ' ' :: calculustokenizerelaychars_s96
def calculustokenizerelaychars_st95 : List String := calculustokenizerelaychars_t95 ++ calculustokenizerelaychars_st96
theorem calculustokenizerelaychars_s95_tok : tokenizeT 289 calculustokenizerelaychars_s95 = some calculustokenizerelaychars_st95 :=
  tokenizeT_concat_space 5 283 _ _ _ _ calculustokenizerelaychars_p95_tok calculustokenizerelaychars_s96_tok
def calculustokenizerelaychars_s94 : List Char := calculustokenizerelaychars_p94 ++ ' ' :: calculustokenizerelaychars_s95
def calculustokenizerelaychars_st94 : List String := calculustokenizerelaychars_t94 ++ calculustokenizerelaychars_st95
theorem calculustokenizerelaychars_s94_tok : tokenizeT 295 calculustokenizerelaychars_s94 = some calculustokenizerelaychars_st94 :=
  tokenizeT_concat_space 5 289 _ _ _ _ calculustokenizerelaychars_p94_tok calculustokenizerelaychars_s95_tok
def calculustokenizerelaychars_s93 : List Char := calculustokenizerelaychars_p93 ++ ' ' :: calculustokenizerelaychars_s94
def calculustokenizerelaychars_st93 : List String := calculustokenizerelaychars_t93 ++ calculustokenizerelaychars_st94
theorem calculustokenizerelaychars_s93_tok : tokenizeT 300 calculustokenizerelaychars_s93 = some calculustokenizerelaychars_st93 :=
  tokenizeT_concat_space 4 295 _ _ _ _ calculustokenizerelaychars_p93_tok calculustokenizerelaychars_s94_tok
def calculustokenizerelaychars_s92 : List Char := calculustokenizerelaychars_p92 ++ ' ' :: calculustokenizerelaychars_s93
def calculustokenizerelaychars_st92 : List String := calculustokenizerelaychars_t92 ++ calculustokenizerelaychars_st93
theorem calculustokenizerelaychars_s92_tok : tokenizeT 303 calculustokenizerelaychars_s92 = some calculustokenizerelaychars_st92 :=
  tokenizeT_concat_space 2 300 _ _ _ _ calculustokenizerelaychars_p92_tok calculustokenizerelaychars_s93_tok
def calculustokenizerelaychars_s91 : List Char := calculustokenizerelaychars_p91 ++ ' ' :: calculustokenizerelaychars_s92
def calculustokenizerelaychars_st91 : List String := calculustokenizerelaychars_t91 ++ calculustokenizerelaychars_st92
theorem calculustokenizerelaychars_s91_tok : tokenizeT 310 calculustokenizerelaychars_s91 = some calculustokenizerelaychars_st91 :=
  tokenizeT_concat_space 6 303 _ _ _ _ calculustokenizerelaychars_p91_tok calculustokenizerelaychars_s92_tok
def calculustokenizerelaychars_s90 : List Char := calculustokenizerelaychars_p90 ++ ' ' :: calculustokenizerelaychars_s91
def calculustokenizerelaychars_st90 : List String := calculustokenizerelaychars_t90 ++ calculustokenizerelaychars_st91
theorem calculustokenizerelaychars_s90_tok : tokenizeT 315 calculustokenizerelaychars_s90 = some calculustokenizerelaychars_st90 :=
  tokenizeT_concat_space 4 310 _ _ _ _ calculustokenizerelaychars_p90_tok calculustokenizerelaychars_s91_tok
def calculustokenizerelaychars_s89 : List Char := calculustokenizerelaychars_p89 ++ ' ' :: calculustokenizerelaychars_s90
def calculustokenizerelaychars_st89 : List String := calculustokenizerelaychars_t89 ++ calculustokenizerelaychars_st90
theorem calculustokenizerelaychars_s89_tok : tokenizeT 320 calculustokenizerelaychars_s89 = some calculustokenizerelaychars_st89 :=
  tokenizeT_concat_space 4 315 _ _ _ _ calculustokenizerelaychars_p89_tok calculustokenizerelaychars_s90_tok
def calculustokenizerelaychars_s88 : List Char := calculustokenizerelaychars_p88 ++ ' ' :: calculustokenizerelaychars_s89
def calculustokenizerelaychars_st88 : List String := calculustokenizerelaychars_t88 ++ calculustokenizerelaychars_st89
theorem calculustokenizerelaychars_s88_tok : tokenizeT 326 calculustokenizerelaychars_s88 = some calculustokenizerelaychars_st88 :=
  tokenizeT_concat_space 5 320 _ _ _ _ calculustokenizerelaychars_p88_tok calculustokenizerelaychars_s89_tok
def calculustokenizerelaychars_s87 : List Char := calculustokenizerelaychars_p87 ++ ' ' :: calculustokenizerelaychars_s88
def calculustokenizerelaychars_st87 : List String := calculustokenizerelaychars_t87 ++ calculustokenizerelaychars_st88
theorem calculustokenizerelaychars_s87_tok : tokenizeT 334 calculustokenizerelaychars_s87 = some calculustokenizerelaychars_st87 :=
  tokenizeT_concat_space 7 326 _ _ _ _ calculustokenizerelaychars_p87_tok calculustokenizerelaychars_s88_tok
def calculustokenizerelaychars_s86 : List Char := calculustokenizerelaychars_p86 ++ ' ' :: calculustokenizerelaychars_s87
def calculustokenizerelaychars_st86 : List String := calculustokenizerelaychars_t86 ++ calculustokenizerelaychars_st87
theorem calculustokenizerelaychars_s86_tok : tokenizeT 337 calculustokenizerelaychars_s86 = some calculustokenizerelaychars_st86 :=
  tokenizeT_concat_space 2 334 _ _ _ _ calculustokenizerelaychars_p86_tok calculustokenizerelaychars_s87_tok
def calculustokenizerelaychars_s85 : List Char := calculustokenizerelaychars_p85 ++ ' ' :: calculustokenizerelaychars_s86
def calculustokenizerelaychars_st85 : List String := calculustokenizerelaychars_t85 ++ calculustokenizerelaychars_st86
theorem calculustokenizerelaychars_s85_tok : tokenizeT 346 calculustokenizerelaychars_s85 = some calculustokenizerelaychars_st85 :=
  tokenizeT_concat_space 8 337 _ _ _ _ calculustokenizerelaychars_p85_tok calculustokenizerelaychars_s86_tok
def calculustokenizerelaychars_s84 : List Char := calculustokenizerelaychars_p84 ++ ' ' :: calculustokenizerelaychars_s85
def calculustokenizerelaychars_st84 : List String := calculustokenizerelaychars_t84 ++ calculustokenizerelaychars_st85
theorem calculustokenizerelaychars_s84_tok : tokenizeT 353 calculustokenizerelaychars_s84 = some calculustokenizerelaychars_st84 :=
  tokenizeT_concat_space 6 346 _ _ _ _ calculustokenizerelaychars_p84_tok calculustokenizerelaychars_s85_tok
def calculustokenizerelaychars_s83 : List Char := calculustokenizerelaychars_p83 ++ ' ' :: calculustokenizerelaychars_s84
def calculustokenizerelaychars_st83 : List String := calculustokenizerelaychars_t83 ++ calculustokenizerelaychars_st84
theorem calculustokenizerelaychars_s83_tok : tokenizeT 383 calculustokenizerelaychars_s83 = some calculustokenizerelaychars_st83 :=
  tokenizeT_concat_space 29 353 _ _ _ _ calculustokenizerelaychars_p83_tok calculustokenizerelaychars_s84_tok
def calculustokenizerelaychars_s82 : List Char := calculustokenizerelaychars_p82 ++ ' ' :: calculustokenizerelaychars_s83
def calculustokenizerelaychars_st82 : List String := calculustokenizerelaychars_t82 ++ calculustokenizerelaychars_st83
theorem calculustokenizerelaychars_s82_tok : tokenizeT 389 calculustokenizerelaychars_s82 = some calculustokenizerelaychars_st82 :=
  tokenizeT_concat_space 5 383 _ _ _ _ calculustokenizerelaychars_p82_tok calculustokenizerelaychars_s83_tok
def calculustokenizerelaychars_s81 : List Char := calculustokenizerelaychars_p81 ++ ' ' :: calculustokenizerelaychars_s82
def calculustokenizerelaychars_st81 : List String := calculustokenizerelaychars_t81 ++ calculustokenizerelaychars_st82
theorem calculustokenizerelaychars_s81_tok : tokenizeT 419 calculustokenizerelaychars_s81 = some calculustokenizerelaychars_st81 :=
  tokenizeT_concat_space 29 389 _ _ _ _ calculustokenizerelaychars_p81_tok calculustokenizerelaychars_s82_tok
def calculustokenizerelaychars_s80 : List Char := calculustokenizerelaychars_p80 ++ ' ' :: calculustokenizerelaychars_s81
def calculustokenizerelaychars_st80 : List String := calculustokenizerelaychars_t80 ++ calculustokenizerelaychars_st81
theorem calculustokenizerelaychars_s80_tok : tokenizeT 426 calculustokenizerelaychars_s80 = some calculustokenizerelaychars_st80 :=
  tokenizeT_concat_space 6 419 _ _ _ _ calculustokenizerelaychars_p80_tok calculustokenizerelaychars_s81_tok
def calculustokenizerelaychars_s79 : List Char := calculustokenizerelaychars_p79 ++ ' ' :: calculustokenizerelaychars_s80
def calculustokenizerelaychars_st79 : List String := calculustokenizerelaychars_t79 ++ calculustokenizerelaychars_st80
theorem calculustokenizerelaychars_s79_tok : tokenizeT 429 calculustokenizerelaychars_s79 = some calculustokenizerelaychars_st79 :=
  tokenizeT_concat_space 2 426 _ _ _ _ calculustokenizerelaychars_p79_tok calculustokenizerelaychars_s80_tok
def calculustokenizerelaychars_s78 : List Char := calculustokenizerelaychars_p78 ++ ' ' :: calculustokenizerelaychars_s79
def calculustokenizerelaychars_st78 : List String := calculustokenizerelaychars_t78 ++ calculustokenizerelaychars_st79
theorem calculustokenizerelaychars_s78_tok : tokenizeT 436 calculustokenizerelaychars_s78 = some calculustokenizerelaychars_st78 :=
  tokenizeT_concat_space 6 429 _ _ _ _ calculustokenizerelaychars_p78_tok calculustokenizerelaychars_s79_tok
def calculustokenizerelaychars_s77 : List Char := calculustokenizerelaychars_p77 ++ ' ' :: calculustokenizerelaychars_s78
def calculustokenizerelaychars_st77 : List String := calculustokenizerelaychars_t77 ++ calculustokenizerelaychars_st78
theorem calculustokenizerelaychars_s77_tok : tokenizeT 449 calculustokenizerelaychars_s77 = some calculustokenizerelaychars_st77 :=
  tokenizeT_concat_space 12 436 _ _ _ _ calculustokenizerelaychars_p77_tok calculustokenizerelaychars_s78_tok
def calculustokenizerelaychars_s76 : List Char := calculustokenizerelaychars_p76 ++ ' ' :: calculustokenizerelaychars_s77
def calculustokenizerelaychars_st76 : List String := calculustokenizerelaychars_t76 ++ calculustokenizerelaychars_st77
theorem calculustokenizerelaychars_s76_tok : tokenizeT 455 calculustokenizerelaychars_s76 = some calculustokenizerelaychars_st76 :=
  tokenizeT_concat_space 5 449 _ _ _ _ calculustokenizerelaychars_p76_tok calculustokenizerelaychars_s77_tok
def calculustokenizerelaychars_s75 : List Char := calculustokenizerelaychars_p75 ++ ' ' :: calculustokenizerelaychars_s76
def calculustokenizerelaychars_st75 : List String := calculustokenizerelaychars_t75 ++ calculustokenizerelaychars_st76
theorem calculustokenizerelaychars_s75_tok : tokenizeT 464 calculustokenizerelaychars_s75 = some calculustokenizerelaychars_st75 :=
  tokenizeT_concat_space 8 455 _ _ _ _ calculustokenizerelaychars_p75_tok calculustokenizerelaychars_s76_tok
def calculustokenizerelaychars_s74 : List Char := calculustokenizerelaychars_p74 ++ ' ' :: calculustokenizerelaychars_s75
def calculustokenizerelaychars_st74 : List String := calculustokenizerelaychars_t74 ++ calculustokenizerelaychars_st75
theorem calculustokenizerelaychars_s74_tok : tokenizeT 470 calculustokenizerelaychars_s74 = some calculustokenizerelaychars_st74 :=
  tokenizeT_concat_space 5 464 _ _ _ _ calculustokenizerelaychars_p74_tok calculustokenizerelaychars_s75_tok
def calculustokenizerelaychars_s73 : List Char := calculustokenizerelaychars_p73 ++ ' ' :: calculustokenizerelaychars_s74
def calculustokenizerelaychars_st73 : List String := calculustokenizerelaychars_t73 ++ calculustokenizerelaychars_st74
theorem calculustokenizerelaychars_s73_tok : tokenizeT 476 calculustokenizerelaychars_s73 = some calculustokenizerelaychars_st73 :=
  tokenizeT_concat_space 5 470 _ _ _ _ calculustokenizerelaychars_p73_tok calculustokenizerelaychars_s74_tok
def calculustokenizerelaychars_s72 : List Char := calculustokenizerelaychars_p72 ++ ' ' :: calculustokenizerelaychars_s73
def calculustokenizerelaychars_st72 : List String := calculustokenizerelaychars_t72 ++ calculustokenizerelaychars_st73
theorem calculustokenizerelaychars_s72_tok : tokenizeT 482 calculustokenizerelaychars_s72 = some calculustokenizerelaychars_st72 :=
  tokenizeT_concat_space 5 476 _ _ _ _ calculustokenizerelaychars_p72_tok calculustokenizerelaychars_s73_tok
def calculustokenizerelaychars_s71 : List Char := calculustokenizerelaychars_p71 ++ ' ' :: calculustokenizerelaychars_s72
def calculustokenizerelaychars_st71 : List String := calculustokenizerelaychars_t71 ++ calculustokenizerelaychars_st72
theorem calculustokenizerelaychars_s71_tok : tokenizeT 487 calculustokenizerelaychars_s71 = some calculustokenizerelaychars_st71 :=
  tokenizeT_concat_space 4 482 _ _ _ _ calculustokenizerelaychars_p71_tok calculustokenizerelaychars_s72_tok
def calculustokenizerelaychars_s70 : List Char := calculustokenizerelaychars_p70 ++ ' ' :: calculustokenizerelaychars_s71
def calculustokenizerelaychars_st70 : List String := calculustokenizerelaychars_t70 ++ calculustokenizerelaychars_st71
theorem calculustokenizerelaychars_s70_tok : tokenizeT 492 calculustokenizerelaychars_s70 = some calculustokenizerelaychars_st70 :=
  tokenizeT_concat_space 4 487 _ _ _ _ calculustokenizerelaychars_p70_tok calculustokenizerelaychars_s71_tok
def calculustokenizerelaychars_s69 : List Char := calculustokenizerelaychars_p69 ++ ' ' :: calculustokenizerelaychars_s70
def calculustokenizerelaychars_st69 : List String := calculustokenizerelaychars_t69 ++ calculustokenizerelaychars_st70
theorem calculustokenizerelaychars_s69_tok : tokenizeT 499 calculustokenizerelaychars_s69 = some calculustokenizerelaychars_st69 :=
  tokenizeT_concat_space 6 492 _ _ _ _ calculustokenizerelaychars_p69_tok calculustokenizerelaychars_s70_tok
def calculustokenizerelaychars_s68 : List Char := calculustokenizerelaychars_p68 ++ ' ' :: calculustokenizerelaychars_s69
def calculustokenizerelaychars_st68 : List String := calculustokenizerelaychars_t68 ++ calculustokenizerelaychars_st69
theorem calculustokenizerelaychars_s68_tok : tokenizeT 503 calculustokenizerelaychars_s68 = some calculustokenizerelaychars_st68 :=
  tokenizeT_concat_space 3 499 _ _ _ _ calculustokenizerelaychars_p68_tok calculustokenizerelaychars_s69_tok
def calculustokenizerelaychars_s67 : List Char := calculustokenizerelaychars_p67 ++ ' ' :: calculustokenizerelaychars_s68
def calculustokenizerelaychars_st67 : List String := calculustokenizerelaychars_t67 ++ calculustokenizerelaychars_st68
theorem calculustokenizerelaychars_s67_tok : tokenizeT 511 calculustokenizerelaychars_s67 = some calculustokenizerelaychars_st67 :=
  tokenizeT_concat_space 7 503 _ _ _ _ calculustokenizerelaychars_p67_tok calculustokenizerelaychars_s68_tok
def calculustokenizerelaychars_s66 : List Char := calculustokenizerelaychars_p66 ++ ' ' :: calculustokenizerelaychars_s67
def calculustokenizerelaychars_st66 : List String := calculustokenizerelaychars_t66 ++ calculustokenizerelaychars_st67
theorem calculustokenizerelaychars_s66_tok : tokenizeT 515 calculustokenizerelaychars_s66 = some calculustokenizerelaychars_st66 :=
  tokenizeT_concat_space 3 511 _ _ _ _ calculustokenizerelaychars_p66_tok calculustokenizerelaychars_s67_tok
def calculustokenizerelaychars_s65 : List Char := calculustokenizerelaychars_p65 ++ ' ' :: calculustokenizerelaychars_s66
def calculustokenizerelaychars_st65 : List String := calculustokenizerelaychars_t65 ++ calculustokenizerelaychars_st66
theorem calculustokenizerelaychars_s65_tok : tokenizeT 520 calculustokenizerelaychars_s65 = some calculustokenizerelaychars_st65 :=
  tokenizeT_concat_space 4 515 _ _ _ _ calculustokenizerelaychars_p65_tok calculustokenizerelaychars_s66_tok
def calculustokenizerelaychars_s64 : List Char := calculustokenizerelaychars_p64 ++ ' ' :: calculustokenizerelaychars_s65
def calculustokenizerelaychars_st64 : List String := calculustokenizerelaychars_t64 ++ calculustokenizerelaychars_st65
theorem calculustokenizerelaychars_s64_tok : tokenizeT 529 calculustokenizerelaychars_s64 = some calculustokenizerelaychars_st64 :=
  tokenizeT_concat_space 8 520 _ _ _ _ calculustokenizerelaychars_p64_tok calculustokenizerelaychars_s65_tok
def calculustokenizerelaychars_s63 : List Char := calculustokenizerelaychars_p63 ++ ' ' :: calculustokenizerelaychars_s64
def calculustokenizerelaychars_st63 : List String := calculustokenizerelaychars_t63 ++ calculustokenizerelaychars_st64
theorem calculustokenizerelaychars_s63_tok : tokenizeT 535 calculustokenizerelaychars_s63 = some calculustokenizerelaychars_st63 :=
  tokenizeT_concat_space 5 529 _ _ _ _ calculustokenizerelaychars_p63_tok calculustokenizerelaychars_s64_tok
def calculustokenizerelaychars_s62 : List Char := calculustokenizerelaychars_p62 ++ ' ' :: calculustokenizerelaychars_s63
def calculustokenizerelaychars_st62 : List String := calculustokenizerelaychars_t62 ++ calculustokenizerelaychars_st63
theorem calculustokenizerelaychars_s62_tok : tokenizeT 542 calculustokenizerelaychars_s62 = some calculustokenizerelaychars_st62 :=
  tokenizeT_concat_space 6 535 _ _ _ _ calculustokenizerelaychars_p62_tok calculustokenizerelaychars_s63_tok
def calculustokenizerelaychars_s61 : List Char := calculustokenizerelaychars_p61 ++ ' ' :: calculustokenizerelaychars_s62
def calculustokenizerelaychars_st61 : List String := calculustokenizerelaychars_t61 ++ calculustokenizerelaychars_st62
theorem calculustokenizerelaychars_s61_tok : tokenizeT 546 calculustokenizerelaychars_s61 = some calculustokenizerelaychars_st61 :=
  tokenizeT_concat_space 3 542 _ _ _ _ calculustokenizerelaychars_p61_tok calculustokenizerelaychars_s62_tok
def calculustokenizerelaychars_s60 : List Char := calculustokenizerelaychars_p60 ++ ' ' :: calculustokenizerelaychars_s61
def calculustokenizerelaychars_st60 : List String := calculustokenizerelaychars_t60 ++ calculustokenizerelaychars_st61
theorem calculustokenizerelaychars_s60_tok : tokenizeT 555 calculustokenizerelaychars_s60 = some calculustokenizerelaychars_st60 :=
  tokenizeT_concat_space 8 546 _ _ _ _ calculustokenizerelaychars_p60_tok calculustokenizerelaychars_s61_tok
def calculustokenizerelaychars_s59 : List Char := calculustokenizerelaychars_p59 ++ ' ' :: calculustokenizerelaychars_s60
def calculustokenizerelaychars_st59 : List String := calculustokenizerelaychars_t59 ++ calculustokenizerelaychars_st60
theorem calculustokenizerelaychars_s59_tok : tokenizeT 560 calculustokenizerelaychars_s59 = some calculustokenizerelaychars_st59 :=
  tokenizeT_concat_space 4 555 _ _ _ _ calculustokenizerelaychars_p59_tok calculustokenizerelaychars_s60_tok
def calculustokenizerelaychars_s58 : List Char := calculustokenizerelaychars_p58 ++ ' ' :: calculustokenizerelaychars_s59
def calculustokenizerelaychars_st58 : List String := calculustokenizerelaychars_t58 ++ calculustokenizerelaychars_st59
theorem calculustokenizerelaychars_s58_tok : tokenizeT 563 calculustokenizerelaychars_s58 = some calculustokenizerelaychars_st58 :=
  tokenizeT_concat_space 2 560 _ _ _ _ calculustokenizerelaychars_p58_tok calculustokenizerelaychars_s59_tok
def calculustokenizerelaychars_s57 : List Char := calculustokenizerelaychars_p57 ++ ' ' :: calculustokenizerelaychars_s58
def calculustokenizerelaychars_st57 : List String := calculustokenizerelaychars_t57 ++ calculustokenizerelaychars_st58
theorem calculustokenizerelaychars_s57_tok : tokenizeT 570 calculustokenizerelaychars_s57 = some calculustokenizerelaychars_st57 :=
  tokenizeT_concat_space 6 563 _ _ _ _ calculustokenizerelaychars_p57_tok calculustokenizerelaychars_s58_tok
def calculustokenizerelaychars_s56 : List Char := calculustokenizerelaychars_p56 ++ ' ' :: calculustokenizerelaychars_s57
def calculustokenizerelaychars_st56 : List String := calculustokenizerelaychars_t56 ++ calculustokenizerelaychars_st57
theorem calculustokenizerelaychars_s56_tok : tokenizeT 575 calculustokenizerelaychars_s56 = some calculustokenizerelaychars_st56 :=
  tokenizeT_concat_space 4 570 _ _ _ _ calculustokenizerelaychars_p56_tok calculustokenizerelaychars_s57_tok
def calculustokenizerelaychars_s55 : List Char := calculustokenizerelaychars_p55 ++ ' ' :: calculustokenizerelaychars_s56
def calculustokenizerelaychars_st55 : List String := calculustokenizerelaychars_t55 ++ calculustokenizerelaychars_st56
theorem calculustokenizerelaychars_s55_tok : tokenizeT 580 calculustokenizerelaychars_s55 = some calculustokenizerelaychars_st55 :=
  tokenizeT_concat_space 4 575 _ _ _ _ calculustokenizerelaychars_p55_tok calculustokenizerelaychars_s56_tok
def calculustokenizerelaychars_s54 : List Char := calculustokenizerelaychars_p54 ++ ' ' :: calculustokenizerelaychars_s55
def calculustokenizerelaychars_st54 : List String := calculustokenizerelaychars_t54 ++ calculustokenizerelaychars_st55
theorem calculustokenizerelaychars_s54_tok : tokenizeT 586 calculustokenizerelaychars_s54 = some calculustokenizerelaychars_st54 :=
  tokenizeT_concat_space 5 580 _ _ _ _ calculustokenizerelaychars_p54_tok calculustokenizerelaychars_s55_tok
def calculustokenizerelaychars_s53 : List Char := calculustokenizerelaychars_p53 ++ ' ' :: calculustokenizerelaychars_s54
def calculustokenizerelaychars_st53 : List String := calculustokenizerelaychars_t53 ++ calculustokenizerelaychars_st54
theorem calculustokenizerelaychars_s53_tok : tokenizeT 593 calculustokenizerelaychars_s53 = some calculustokenizerelaychars_st53 :=
  tokenizeT_concat_space 6 586 _ _ _ _ calculustokenizerelaychars_p53_tok calculustokenizerelaychars_s54_tok
def calculustokenizerelaychars_s52 : List Char := calculustokenizerelaychars_p52 ++ ' ' :: calculustokenizerelaychars_s53
def calculustokenizerelaychars_st52 : List String := calculustokenizerelaychars_t52 ++ calculustokenizerelaychars_st53
theorem calculustokenizerelaychars_s52_tok : tokenizeT 597 calculustokenizerelaychars_s52 = some calculustokenizerelaychars_st52 :=
  tokenizeT_concat_space 3 593 _ _ _ _ calculustokenizerelaychars_p52_tok calculustokenizerelaychars_s53_tok
def calculustokenizerelaychars_s51 : List Char := calculustokenizerelaychars_p51 ++ ' ' :: calculustokenizerelaychars_s52
def calculustokenizerelaychars_st51 : List String := calculustokenizerelaychars_t51 ++ calculustokenizerelaychars_st52
theorem calculustokenizerelaychars_s51_tok : tokenizeT 606 calculustokenizerelaychars_s51 = some calculustokenizerelaychars_st51 :=
  tokenizeT_concat_space 8 597 _ _ _ _ calculustokenizerelaychars_p51_tok calculustokenizerelaychars_s52_tok
def calculustokenizerelaychars_s50 : List Char := calculustokenizerelaychars_p50 ++ ' ' :: calculustokenizerelaychars_s51
def calculustokenizerelaychars_st50 : List String := calculustokenizerelaychars_t50 ++ calculustokenizerelaychars_st51
theorem calculustokenizerelaychars_s50_tok : tokenizeT 611 calculustokenizerelaychars_s50 = some calculustokenizerelaychars_st50 :=
  tokenizeT_concat_space 4 606 _ _ _ _ calculustokenizerelaychars_p50_tok calculustokenizerelaychars_s51_tok
def calculustokenizerelaychars_s49 : List Char := calculustokenizerelaychars_p49 ++ ' ' :: calculustokenizerelaychars_s50
def calculustokenizerelaychars_st49 : List String := calculustokenizerelaychars_t49 ++ calculustokenizerelaychars_st50
theorem calculustokenizerelaychars_s49_tok : tokenizeT 614 calculustokenizerelaychars_s49 = some calculustokenizerelaychars_st49 :=
  tokenizeT_concat_space 2 611 _ _ _ _ calculustokenizerelaychars_p49_tok calculustokenizerelaychars_s50_tok
def calculustokenizerelaychars_s48 : List Char := calculustokenizerelaychars_p48 ++ ' ' :: calculustokenizerelaychars_s49
def calculustokenizerelaychars_st48 : List String := calculustokenizerelaychars_t48 ++ calculustokenizerelaychars_st49
theorem calculustokenizerelaychars_s48_tok : tokenizeT 621 calculustokenizerelaychars_s48 = some calculustokenizerelaychars_st48 :=
  tokenizeT_concat_space 6 614 _ _ _ _ calculustokenizerelaychars_p48_tok calculustokenizerelaychars_s49_tok
def calculustokenizerelaychars_s47 : List Char := calculustokenizerelaychars_p47 ++ ' ' :: calculustokenizerelaychars_s48
def calculustokenizerelaychars_st47 : List String := calculustokenizerelaychars_t47 ++ calculustokenizerelaychars_st48
theorem calculustokenizerelaychars_s47_tok : tokenizeT 625 calculustokenizerelaychars_s47 = some calculustokenizerelaychars_st47 :=
  tokenizeT_concat_space 3 621 _ _ _ _ calculustokenizerelaychars_p47_tok calculustokenizerelaychars_s48_tok
def calculustokenizerelaychars_s46 : List Char := calculustokenizerelaychars_p46 ++ ' ' :: calculustokenizerelaychars_s47
def calculustokenizerelaychars_st46 : List String := calculustokenizerelaychars_t46 ++ calculustokenizerelaychars_st47
theorem calculustokenizerelaychars_s46_tok : tokenizeT 630 calculustokenizerelaychars_s46 = some calculustokenizerelaychars_st46 :=
  tokenizeT_concat_space 4 625 _ _ _ _ calculustokenizerelaychars_p46_tok calculustokenizerelaychars_s47_tok
def calculustokenizerelaychars_s45 : List Char := calculustokenizerelaychars_p45 ++ ' ' :: calculustokenizerelaychars_s46
def calculustokenizerelaychars_st45 : List String := calculustokenizerelaychars_t45 ++ calculustokenizerelaychars_st46
theorem calculustokenizerelaychars_s45_tok : tokenizeT 636 calculustokenizerelaychars_s45 = some calculustokenizerelaychars_st45 :=
  tokenizeT_concat_space 5 630 _ _ _ _ calculustokenizerelaychars_p45_tok calculustokenizerelaychars_s46_tok
def calculustokenizerelaychars_s44 : List Char := calculustokenizerelaychars_p44 ++ ' ' :: calculustokenizerelaychars_s45
def calculustokenizerelaychars_st44 : List String := calculustokenizerelaychars_t44 ++ calculustokenizerelaychars_st45
theorem calculustokenizerelaychars_s44_tok : tokenizeT 644 calculustokenizerelaychars_s44 = some calculustokenizerelaychars_st44 :=
  tokenizeT_concat_space 7 636 _ _ _ _ calculustokenizerelaychars_p44_tok calculustokenizerelaychars_s45_tok
def calculustokenizerelaychars_s43 : List Char := calculustokenizerelaychars_p43 ++ ' ' :: calculustokenizerelaychars_s44
def calculustokenizerelaychars_st43 : List String := calculustokenizerelaychars_t43 ++ calculustokenizerelaychars_st44
theorem calculustokenizerelaychars_s43_tok : tokenizeT 647 calculustokenizerelaychars_s43 = some calculustokenizerelaychars_st43 :=
  tokenizeT_concat_space 2 644 _ _ _ _ calculustokenizerelaychars_p43_tok calculustokenizerelaychars_s44_tok
def calculustokenizerelaychars_s42 : List Char := calculustokenizerelaychars_p42 ++ ' ' :: calculustokenizerelaychars_s43
def calculustokenizerelaychars_st42 : List String := calculustokenizerelaychars_t42 ++ calculustokenizerelaychars_st43
theorem calculustokenizerelaychars_s42_tok : tokenizeT 656 calculustokenizerelaychars_s42 = some calculustokenizerelaychars_st42 :=
  tokenizeT_concat_space 8 647 _ _ _ _ calculustokenizerelaychars_p42_tok calculustokenizerelaychars_s43_tok
def calculustokenizerelaychars_s41 : List Char := calculustokenizerelaychars_p41 ++ ' ' :: calculustokenizerelaychars_s42
def calculustokenizerelaychars_st41 : List String := calculustokenizerelaychars_t41 ++ calculustokenizerelaychars_st42
theorem calculustokenizerelaychars_s41_tok : tokenizeT 660 calculustokenizerelaychars_s41 = some calculustokenizerelaychars_st41 :=
  tokenizeT_concat_space 3 656 _ _ _ _ calculustokenizerelaychars_p41_tok calculustokenizerelaychars_s42_tok
def calculustokenizerelaychars_s40 : List Char := calculustokenizerelaychars_p40 ++ ' ' :: calculustokenizerelaychars_s41
def calculustokenizerelaychars_st40 : List String := calculustokenizerelaychars_t40 ++ calculustokenizerelaychars_st41
theorem calculustokenizerelaychars_s40_tok : tokenizeT 672 calculustokenizerelaychars_s40 = some calculustokenizerelaychars_st40 :=
  tokenizeT_concat_space 11 660 _ _ _ _ calculustokenizerelaychars_p40_tok calculustokenizerelaychars_s41_tok
def calculustokenizerelaychars_s39 : List Char := calculustokenizerelaychars_p39 ++ ' ' :: calculustokenizerelaychars_s40
def calculustokenizerelaychars_st39 : List String := calculustokenizerelaychars_t39 ++ calculustokenizerelaychars_st40
theorem calculustokenizerelaychars_s39_tok : tokenizeT 678 calculustokenizerelaychars_s39 = some calculustokenizerelaychars_st39 :=
  tokenizeT_concat_space 5 672 _ _ _ _ calculustokenizerelaychars_p39_tok calculustokenizerelaychars_s40_tok
def calculustokenizerelaychars_s38 : List Char := calculustokenizerelaychars_p38 ++ ' ' :: calculustokenizerelaychars_s39
def calculustokenizerelaychars_st38 : List String := calculustokenizerelaychars_t38 ++ calculustokenizerelaychars_st39
theorem calculustokenizerelaychars_s38_tok : tokenizeT 687 calculustokenizerelaychars_s38 = some calculustokenizerelaychars_st38 :=
  tokenizeT_concat_space 8 678 _ _ _ _ calculustokenizerelaychars_p38_tok calculustokenizerelaychars_s39_tok
def calculustokenizerelaychars_s37 : List Char := calculustokenizerelaychars_p37 ++ ' ' :: calculustokenizerelaychars_s38
def calculustokenizerelaychars_st37 : List String := calculustokenizerelaychars_t37 ++ calculustokenizerelaychars_st38
theorem calculustokenizerelaychars_s37_tok : tokenizeT 693 calculustokenizerelaychars_s37 = some calculustokenizerelaychars_st37 :=
  tokenizeT_concat_space 5 687 _ _ _ _ calculustokenizerelaychars_p37_tok calculustokenizerelaychars_s38_tok
def calculustokenizerelaychars_s36 : List Char := calculustokenizerelaychars_p36 ++ ' ' :: calculustokenizerelaychars_s37
def calculustokenizerelaychars_st36 : List String := calculustokenizerelaychars_t36 ++ calculustokenizerelaychars_st37
theorem calculustokenizerelaychars_s36_tok : tokenizeT 699 calculustokenizerelaychars_s36 = some calculustokenizerelaychars_st36 :=
  tokenizeT_concat_space 5 693 _ _ _ _ calculustokenizerelaychars_p36_tok calculustokenizerelaychars_s37_tok
def calculustokenizerelaychars_s35 : List Char := calculustokenizerelaychars_p35 ++ ' ' :: calculustokenizerelaychars_s36
def calculustokenizerelaychars_st35 : List String := calculustokenizerelaychars_t35 ++ calculustokenizerelaychars_st36
theorem calculustokenizerelaychars_s35_tok : tokenizeT 705 calculustokenizerelaychars_s35 = some calculustokenizerelaychars_st35 :=
  tokenizeT_concat_space 5 699 _ _ _ _ calculustokenizerelaychars_p35_tok calculustokenizerelaychars_s36_tok
def calculustokenizerelaychars_s34 : List Char := calculustokenizerelaychars_p34 ++ ' ' :: calculustokenizerelaychars_s35
def calculustokenizerelaychars_st34 : List String := calculustokenizerelaychars_t34 ++ calculustokenizerelaychars_st35
theorem calculustokenizerelaychars_s34_tok : tokenizeT 711 calculustokenizerelaychars_s34 = some calculustokenizerelaychars_st34 :=
  tokenizeT_concat_space 5 705 _ _ _ _ calculustokenizerelaychars_p34_tok calculustokenizerelaychars_s35_tok
def calculustokenizerelaychars_s33 : List Char := calculustokenizerelaychars_p33 ++ ' ' :: calculustokenizerelaychars_s34
def calculustokenizerelaychars_st33 : List String := calculustokenizerelaychars_t33 ++ calculustokenizerelaychars_st34
theorem calculustokenizerelaychars_s33_tok : tokenizeT 719 calculustokenizerelaychars_s33 = some calculustokenizerelaychars_st33 :=
  tokenizeT_concat_space 7 711 _ _ _ _ calculustokenizerelaychars_p33_tok calculustokenizerelaychars_s34_tok
def calculustokenizerelaychars_s32 : List Char := calculustokenizerelaychars_p32 ++ ' ' :: calculustokenizerelaychars_s33
def calculustokenizerelaychars_st32 : List String := calculustokenizerelaychars_t32 ++ calculustokenizerelaychars_st33
theorem calculustokenizerelaychars_s32_tok : tokenizeT 725 calculustokenizerelaychars_s32 = some calculustokenizerelaychars_st32 :=
  tokenizeT_concat_space 5 719 _ _ _ _ calculustokenizerelaychars_p32_tok calculustokenizerelaychars_s33_tok
def calculustokenizerelaychars_s31 : List Char := calculustokenizerelaychars_p31 ++ ' ' :: calculustokenizerelaychars_s32
def calculustokenizerelaychars_st31 : List String := calculustokenizerelaychars_t31 ++ calculustokenizerelaychars_st32
theorem calculustokenizerelaychars_s31_tok : tokenizeT 733 calculustokenizerelaychars_s31 = some calculustokenizerelaychars_st31 :=
  tokenizeT_concat_space 7 725 _ _ _ _ calculustokenizerelaychars_p31_tok calculustokenizerelaychars_s32_tok
def calculustokenizerelaychars_s30 : List Char := calculustokenizerelaychars_p30 ++ ' ' :: calculustokenizerelaychars_s31
def calculustokenizerelaychars_st30 : List String := calculustokenizerelaychars_t30 ++ calculustokenizerelaychars_st31
theorem calculustokenizerelaychars_s30_tok : tokenizeT 740 calculustokenizerelaychars_s30 = some calculustokenizerelaychars_st30 :=
  tokenizeT_concat_space 6 733 _ _ _ _ calculustokenizerelaychars_p30_tok calculustokenizerelaychars_s31_tok
def calculustokenizerelaychars_s29 : List Char := calculustokenizerelaychars_p29 ++ ' ' :: calculustokenizerelaychars_s30
def calculustokenizerelaychars_st29 : List String := calculustokenizerelaychars_t29 ++ calculustokenizerelaychars_st30
theorem calculustokenizerelaychars_s29_tok : tokenizeT 743 calculustokenizerelaychars_s29 = some calculustokenizerelaychars_st29 :=
  tokenizeT_concat_space 2 740 _ _ _ _ calculustokenizerelaychars_p29_tok calculustokenizerelaychars_s30_tok
def calculustokenizerelaychars_s28 : List Char := calculustokenizerelaychars_p28 ++ ' ' :: calculustokenizerelaychars_s29
def calculustokenizerelaychars_st28 : List String := calculustokenizerelaychars_t28 ++ calculustokenizerelaychars_st29
theorem calculustokenizerelaychars_s28_tok : tokenizeT 754 calculustokenizerelaychars_s28 = some calculustokenizerelaychars_st28 :=
  tokenizeT_concat_space 10 743 _ _ _ _ calculustokenizerelaychars_p28_tok calculustokenizerelaychars_s29_tok
def calculustokenizerelaychars_s27 : List Char := calculustokenizerelaychars_p27 ++ ' ' :: calculustokenizerelaychars_s28
def calculustokenizerelaychars_st27 : List String := calculustokenizerelaychars_t27 ++ calculustokenizerelaychars_st28
theorem calculustokenizerelaychars_s27_tok : tokenizeT 760 calculustokenizerelaychars_s27 = some calculustokenizerelaychars_st27 :=
  tokenizeT_concat_space 5 754 _ _ _ _ calculustokenizerelaychars_p27_tok calculustokenizerelaychars_s28_tok
def calculustokenizerelaychars_s26 : List Char := calculustokenizerelaychars_p26 ++ ' ' :: calculustokenizerelaychars_s27
def calculustokenizerelaychars_st26 : List String := calculustokenizerelaychars_t26 ++ calculustokenizerelaychars_st27
theorem calculustokenizerelaychars_s26_tok : tokenizeT 764 calculustokenizerelaychars_s26 = some calculustokenizerelaychars_st26 :=
  tokenizeT_concat_space 3 760 _ _ _ _ calculustokenizerelaychars_p26_tok calculustokenizerelaychars_s27_tok
def calculustokenizerelaychars_s25 : List Char := calculustokenizerelaychars_p25 ++ ' ' :: calculustokenizerelaychars_s26
def calculustokenizerelaychars_st25 : List String := calculustokenizerelaychars_t25 ++ calculustokenizerelaychars_st26
theorem calculustokenizerelaychars_s25_tok : tokenizeT 769 calculustokenizerelaychars_s25 = some calculustokenizerelaychars_st25 :=
  tokenizeT_concat_space 4 764 _ _ _ _ calculustokenizerelaychars_p25_tok calculustokenizerelaychars_s26_tok
def calculustokenizerelaychars_s24 : List Char := calculustokenizerelaychars_p24 ++ ' ' :: calculustokenizerelaychars_s25
def calculustokenizerelaychars_st24 : List String := calculustokenizerelaychars_t24 ++ calculustokenizerelaychars_st25
theorem calculustokenizerelaychars_s24_tok : tokenizeT 772 calculustokenizerelaychars_s24 = some calculustokenizerelaychars_st24 :=
  tokenizeT_concat_space 2 769 _ _ _ _ calculustokenizerelaychars_p24_tok calculustokenizerelaychars_s25_tok
def calculustokenizerelaychars_s23 : List Char := calculustokenizerelaychars_p23 ++ ' ' :: calculustokenizerelaychars_s24
def calculustokenizerelaychars_st23 : List String := calculustokenizerelaychars_t23 ++ calculustokenizerelaychars_st24
theorem calculustokenizerelaychars_s23_tok : tokenizeT 783 calculustokenizerelaychars_s23 = some calculustokenizerelaychars_st23 :=
  tokenizeT_concat_space 10 772 _ _ _ _ calculustokenizerelaychars_p23_tok calculustokenizerelaychars_s24_tok
def calculustokenizerelaychars_s22 : List Char := calculustokenizerelaychars_p22 ++ ' ' :: calculustokenizerelaychars_s23
def calculustokenizerelaychars_st22 : List String := calculustokenizerelaychars_t22 ++ calculustokenizerelaychars_st23
theorem calculustokenizerelaychars_s22_tok : tokenizeT 789 calculustokenizerelaychars_s22 = some calculustokenizerelaychars_st22 :=
  tokenizeT_concat_space 5 783 _ _ _ _ calculustokenizerelaychars_p22_tok calculustokenizerelaychars_s23_tok
def calculustokenizerelaychars_s21 : List Char := calculustokenizerelaychars_p21 ++ ' ' :: calculustokenizerelaychars_s22
def calculustokenizerelaychars_st21 : List String := calculustokenizerelaychars_t21 ++ calculustokenizerelaychars_st22
theorem calculustokenizerelaychars_s21_tok : tokenizeT 794 calculustokenizerelaychars_s21 = some calculustokenizerelaychars_st21 :=
  tokenizeT_concat_space 4 789 _ _ _ _ calculustokenizerelaychars_p21_tok calculustokenizerelaychars_s22_tok
def calculustokenizerelaychars_s20 : List Char := calculustokenizerelaychars_p20 ++ ' ' :: calculustokenizerelaychars_s21
def calculustokenizerelaychars_st20 : List String := calculustokenizerelaychars_t20 ++ calculustokenizerelaychars_st21
theorem calculustokenizerelaychars_s20_tok : tokenizeT 799 calculustokenizerelaychars_s20 = some calculustokenizerelaychars_st20 :=
  tokenizeT_concat_space 4 794 _ _ _ _ calculustokenizerelaychars_p20_tok calculustokenizerelaychars_s21_tok
def calculustokenizerelaychars_s19 : List Char := calculustokenizerelaychars_p19 ++ ' ' :: calculustokenizerelaychars_s20
def calculustokenizerelaychars_st19 : List String := calculustokenizerelaychars_t19 ++ calculustokenizerelaychars_st20
theorem calculustokenizerelaychars_s19_tok : tokenizeT 802 calculustokenizerelaychars_s19 = some calculustokenizerelaychars_st19 :=
  tokenizeT_concat_space 2 799 _ _ _ _ calculustokenizerelaychars_p19_tok calculustokenizerelaychars_s20_tok
def calculustokenizerelaychars_s18 : List Char := calculustokenizerelaychars_p18 ++ ' ' :: calculustokenizerelaychars_s19
def calculustokenizerelaychars_st18 : List String := calculustokenizerelaychars_t18 ++ calculustokenizerelaychars_st19
theorem calculustokenizerelaychars_s18_tok : tokenizeT 813 calculustokenizerelaychars_s18 = some calculustokenizerelaychars_st18 :=
  tokenizeT_concat_space 10 802 _ _ _ _ calculustokenizerelaychars_p18_tok calculustokenizerelaychars_s19_tok
def calculustokenizerelaychars_s17 : List Char := calculustokenizerelaychars_p17 ++ ' ' :: calculustokenizerelaychars_s18
def calculustokenizerelaychars_st17 : List String := calculustokenizerelaychars_t17 ++ calculustokenizerelaychars_st18
theorem calculustokenizerelaychars_s17_tok : tokenizeT 819 calculustokenizerelaychars_s17 = some calculustokenizerelaychars_st17 :=
  tokenizeT_concat_space 5 813 _ _ _ _ calculustokenizerelaychars_p17_tok calculustokenizerelaychars_s18_tok
def calculustokenizerelaychars_s16 : List Char := calculustokenizerelaychars_p16 ++ ' ' :: calculustokenizerelaychars_s17
def calculustokenizerelaychars_st16 : List String := calculustokenizerelaychars_t16 ++ calculustokenizerelaychars_st17
theorem calculustokenizerelaychars_s16_tok : tokenizeT 824 calculustokenizerelaychars_s16 = some calculustokenizerelaychars_st16 :=
  tokenizeT_concat_space 4 819 _ _ _ _ calculustokenizerelaychars_p16_tok calculustokenizerelaychars_s17_tok
def calculustokenizerelaychars_s15 : List Char := calculustokenizerelaychars_p15 ++ ' ' :: calculustokenizerelaychars_s16
def calculustokenizerelaychars_st15 : List String := calculustokenizerelaychars_t15 ++ calculustokenizerelaychars_st16
theorem calculustokenizerelaychars_s15_tok : tokenizeT 831 calculustokenizerelaychars_s15 = some calculustokenizerelaychars_st15 :=
  tokenizeT_concat_space 6 824 _ _ _ _ calculustokenizerelaychars_p15_tok calculustokenizerelaychars_s16_tok
def calculustokenizerelaychars_s14 : List Char := calculustokenizerelaychars_p14 ++ ' ' :: calculustokenizerelaychars_s15
def calculustokenizerelaychars_st14 : List String := calculustokenizerelaychars_t14 ++ calculustokenizerelaychars_st15
theorem calculustokenizerelaychars_s14_tok : tokenizeT 834 calculustokenizerelaychars_s14 = some calculustokenizerelaychars_st14 :=
  tokenizeT_concat_space 2 831 _ _ _ _ calculustokenizerelaychars_p14_tok calculustokenizerelaychars_s15_tok
def calculustokenizerelaychars_s13 : List Char := calculustokenizerelaychars_p13 ++ ' ' :: calculustokenizerelaychars_s14
def calculustokenizerelaychars_st13 : List String := calculustokenizerelaychars_t13 ++ calculustokenizerelaychars_st14
theorem calculustokenizerelaychars_s13_tok : tokenizeT 841 calculustokenizerelaychars_s13 = some calculustokenizerelaychars_st13 :=
  tokenizeT_concat_space 6 834 _ _ _ _ calculustokenizerelaychars_p13_tok calculustokenizerelaychars_s14_tok
def calculustokenizerelaychars_s12 : List Char := calculustokenizerelaychars_p12 ++ ' ' :: calculustokenizerelaychars_s13
def calculustokenizerelaychars_st12 : List String := calculustokenizerelaychars_t12 ++ calculustokenizerelaychars_st13
theorem calculustokenizerelaychars_s12_tok : tokenizeT 844 calculustokenizerelaychars_s12 = some calculustokenizerelaychars_st12 :=
  tokenizeT_concat_space 2 841 _ _ _ _ calculustokenizerelaychars_p12_tok calculustokenizerelaychars_s13_tok
def calculustokenizerelaychars_s11 : List Char := calculustokenizerelaychars_p11 ++ ' ' :: calculustokenizerelaychars_s12
def calculustokenizerelaychars_st11 : List String := calculustokenizerelaychars_t11 ++ calculustokenizerelaychars_st12
theorem calculustokenizerelaychars_s11_tok : tokenizeT 853 calculustokenizerelaychars_s11 = some calculustokenizerelaychars_st11 :=
  tokenizeT_concat_space 8 844 _ _ _ _ calculustokenizerelaychars_p11_tok calculustokenizerelaychars_s12_tok
def calculustokenizerelaychars_s10 : List Char := calculustokenizerelaychars_p10 ++ ' ' :: calculustokenizerelaychars_s11
def calculustokenizerelaychars_st10 : List String := calculustokenizerelaychars_t10 ++ calculustokenizerelaychars_st11
theorem calculustokenizerelaychars_s10_tok : tokenizeT 859 calculustokenizerelaychars_s10 = some calculustokenizerelaychars_st10 :=
  tokenizeT_concat_space 5 853 _ _ _ _ calculustokenizerelaychars_p10_tok calculustokenizerelaychars_s11_tok
def calculustokenizerelaychars_s9 : List Char := calculustokenizerelaychars_p9 ++ ' ' :: calculustokenizerelaychars_s10
def calculustokenizerelaychars_st9 : List String := calculustokenizerelaychars_t9 ++ calculustokenizerelaychars_st10
theorem calculustokenizerelaychars_s9_tok : tokenizeT 863 calculustokenizerelaychars_s9 = some calculustokenizerelaychars_st9 :=
  tokenizeT_concat_space 3 859 _ _ _ _ calculustokenizerelaychars_p9_tok calculustokenizerelaychars_s10_tok
def calculustokenizerelaychars_s8 : List Char := calculustokenizerelaychars_p8 ++ ' ' :: calculustokenizerelaychars_s9
def calculustokenizerelaychars_st8 : List String := calculustokenizerelaychars_t8 ++ calculustokenizerelaychars_st9
theorem calculustokenizerelaychars_s8_tok : tokenizeT 870 calculustokenizerelaychars_s8 = some calculustokenizerelaychars_st8 :=
  tokenizeT_concat_space 6 863 _ _ _ _ calculustokenizerelaychars_p8_tok calculustokenizerelaychars_s9_tok
def calculustokenizerelaychars_s7 : List Char := calculustokenizerelaychars_p7 ++ ' ' :: calculustokenizerelaychars_s8
def calculustokenizerelaychars_st7 : List String := calculustokenizerelaychars_t7 ++ calculustokenizerelaychars_st8
theorem calculustokenizerelaychars_s7_tok : tokenizeT 873 calculustokenizerelaychars_s7 = some calculustokenizerelaychars_st7 :=
  tokenizeT_concat_space 2 870 _ _ _ _ calculustokenizerelaychars_p7_tok calculustokenizerelaychars_s8_tok
def calculustokenizerelaychars_s6 : List Char := calculustokenizerelaychars_p6 ++ ' ' :: calculustokenizerelaychars_s7
def calculustokenizerelaychars_st6 : List String := calculustokenizerelaychars_t6 ++ calculustokenizerelaychars_st7
theorem calculustokenizerelaychars_s6_tok : tokenizeT 884 calculustokenizerelaychars_s6 = some calculustokenizerelaychars_st6 :=
  tokenizeT_concat_space 10 873 _ _ _ _ calculustokenizerelaychars_p6_tok calculustokenizerelaychars_s7_tok
def calculustokenizerelaychars_s5 : List Char := calculustokenizerelaychars_p5 ++ ' ' :: calculustokenizerelaychars_s6
def calculustokenizerelaychars_st5 : List String := calculustokenizerelaychars_t5 ++ calculustokenizerelaychars_st6
theorem calculustokenizerelaychars_s5_tok : tokenizeT 890 calculustokenizerelaychars_s5 = some calculustokenizerelaychars_st5 :=
  tokenizeT_concat_space 5 884 _ _ _ _ calculustokenizerelaychars_p5_tok calculustokenizerelaychars_s6_tok
def calculustokenizerelaychars_s4 : List Char := calculustokenizerelaychars_p4 ++ ' ' :: calculustokenizerelaychars_s5
def calculustokenizerelaychars_st4 : List String := calculustokenizerelaychars_t4 ++ calculustokenizerelaychars_st5
theorem calculustokenizerelaychars_s4_tok : tokenizeT 894 calculustokenizerelaychars_s4 = some calculustokenizerelaychars_st4 :=
  tokenizeT_concat_space 3 890 _ _ _ _ calculustokenizerelaychars_p4_tok calculustokenizerelaychars_s5_tok
def calculustokenizerelaychars_s3 : List Char := calculustokenizerelaychars_p3 ++ ' ' :: calculustokenizerelaychars_s4
def calculustokenizerelaychars_st3 : List String := calculustokenizerelaychars_t3 ++ calculustokenizerelaychars_st4
theorem calculustokenizerelaychars_s3_tok : tokenizeT 901 calculustokenizerelaychars_s3 = some calculustokenizerelaychars_st3 :=
  tokenizeT_concat_space 6 894 _ _ _ _ calculustokenizerelaychars_p3_tok calculustokenizerelaychars_s4_tok
def calculustokenizerelaychars_s2 : List Char := calculustokenizerelaychars_p2 ++ ' ' :: calculustokenizerelaychars_s3
def calculustokenizerelaychars_st2 : List String := calculustokenizerelaychars_t2 ++ calculustokenizerelaychars_st3
theorem calculustokenizerelaychars_s2_tok : tokenizeT 904 calculustokenizerelaychars_s2 = some calculustokenizerelaychars_st2 :=
  tokenizeT_concat_space 2 901 _ _ _ _ calculustokenizerelaychars_p2_tok calculustokenizerelaychars_s3_tok
def calculustokenizerelaychars_s1 : List Char := calculustokenizerelaychars_p1 ++ ' ' :: calculustokenizerelaychars_s2
def calculustokenizerelaychars_st1 : List String := calculustokenizerelaychars_t1 ++ calculustokenizerelaychars_st2
theorem calculustokenizerelaychars_s1_tok : tokenizeT 918 calculustokenizerelaychars_s1 = some calculustokenizerelaychars_st1 :=
  tokenizeT_concat_space 13 904 _ _ _ _ calculustokenizerelaychars_p1_tok calculustokenizerelaychars_s2_tok
def calculustokenizerelaychars_s0 : List Char := calculustokenizerelaychars_p0 ++ ' ' :: calculustokenizerelaychars_s1
def calculustokenizerelaychars_st0 : List String := calculustokenizerelaychars_t0 ++ calculustokenizerelaychars_st1
theorem calculustokenizerelaychars_s0_tok : tokenizeT 924 calculustokenizerelaychars_s0 = some calculustokenizerelaychars_st0 :=
  tokenizeT_concat_space 5 918 _ _ _ _ calculustokenizerelaychars_p0_tok calculustokenizerelaychars_s1_tok
end CalculusTokenizeRelayChars

/-
CalculusTokenizeChars.lean (tokenizer-chars-100) module A: leaves + right-spine concat.
-/
import CalculusTokenizeFull
open CalculusNested CalculusExport CalculusBody CalculusRelayOuter CalculusTokenize CalculusTokenizeFull

namespace CalculusTokenizeChars
set_option maxRecDepth 100000
def wb_p0 : List Char := ['(', 's', 'e', 'q']
def wb_t0 : List String := ["(", "seq"]
theorem wb_p0_tok : tokenizeT 5 wb_p0 = some wb_t0 := by
  decide +kernel
def wb_p1 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t1 : List String := ["(", "assign"]
theorem wb_p1_tok : tokenizeT 8 wb_p1 = some wb_t1 := by
  decide +kernel
def wb_p2 : List Char := ['b']
def wb_t2 : List String := ["b"]
theorem wb_p2_tok : tokenizeT 2 wb_p2 = some wb_t2 := by
  decide +kernel
def wb_p3 : List Char := ['(', 'f', 's', 't']
def wb_t3 : List String := ["(", "fst"]
theorem wb_p3_tok : tokenizeT 5 wb_p3 = some wb_t3 := by
  decide +kernel
def wb_p4 : List Char := [Char.ofNat 953, ')', ')']
def wb_t4 : List String := ["ι", ")", ")"]
theorem wb_p4_tok : tokenizeT 4 wb_p4 = some wb_t4 := by
  decide +kernel
def wb_p5 : List Char := ['(', 's', 'e', 'q']
def wb_t5 : List String := ["(", "seq"]
theorem wb_p5_tok : tokenizeT 5 wb_p5 = some wb_t5 := by
  decide +kernel
def wb_p6 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t6 : List String := ["(", "assign"]
theorem wb_p6_tok : tokenizeT 8 wb_p6 = some wb_t6 := by
  decide +kernel
def wb_p7 : List Char := ['o', 'f', 'f']
def wb_t7 : List String := ["off"]
theorem wb_p7_tok : tokenizeT 4 wb_p7 = some wb_t7 := by
  decide +kernel
def wb_p8 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def wb_t8 : List String := ["(", "range:0:4611686018427387903"]
theorem wb_p8_tok : tokenizeT 29 wb_p8 = some wb_t8 := by
  decide +kernel
def wb_p9 : List Char := ['(', 'f', 's', 't']
def wb_t9 : List String := ["(", "fst"]
theorem wb_p9_tok : tokenizeT 5 wb_p9 = some wb_t9 := by
  decide +kernel
def wb_p10 : List Char := ['(', 's', 'n', 'd']
def wb_t10 : List String := ["(", "snd"]
theorem wb_p10_tok : tokenizeT 5 wb_p10 = some wb_t10 := by
  decide +kernel
def wb_p11 : List Char := [Char.ofNat 953, ')', ')', ')', ')']
def wb_t11 : List String := ["ι", ")", ")", ")", ")"]
theorem wb_p11_tok : tokenizeT 6 wb_p11 = some wb_t11 := by
  decide +kernel
def wb_p12 : List Char := ['(', 's', 'e', 'q']
def wb_t12 : List String := ["(", "seq"]
theorem wb_p12_tok : tokenizeT 5 wb_p12 = some wb_t12 := by
  decide +kernel
def wb_p13 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t13 : List String := ["(", "assign"]
theorem wb_p13_tok : tokenizeT 8 wb_p13 = some wb_t13 := by
  decide +kernel
def wb_p14 : List Char := ['n']
def wb_t14 : List String := ["n"]
theorem wb_p14_tok : tokenizeT 2 wb_p14 = some wb_t14 := by
  decide +kernel
def wb_p15 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def wb_t15 : List String := ["(", "range:0:4611686018427387903"]
theorem wb_p15_tok : tokenizeT 29 wb_p15 = some wb_t15 := by
  decide +kernel
def wb_p16 : List Char := ['(', 's', 'n', 'd']
def wb_t16 : List String := ["(", "snd"]
theorem wb_p16_tok : tokenizeT 5 wb_p16 = some wb_t16 := by
  decide +kernel
def wb_p17 : List Char := ['(', 's', 'n', 'd']
def wb_t17 : List String := ["(", "snd"]
theorem wb_p17_tok : tokenizeT 5 wb_p17 = some wb_t17 := by
  decide +kernel
def wb_p18 : List Char := [Char.ofNat 953, ')', ')', ')', ')']
def wb_t18 : List String := ["ι", ")", ")", ")", ")"]
theorem wb_p18_tok : tokenizeT 6 wb_p18 = some wb_t18 := by
  decide +kernel
def wb_p19 : List Char := ['(', 's', 'e', 'q']
def wb_t19 : List String := ["(", "seq"]
theorem wb_p19_tok : tokenizeT 5 wb_p19 = some wb_t19 := by
  decide +kernel
def wb_p20 : List Char := ['(', 'i', 'f']
def wb_t20 : List String := ["(", "if"]
theorem wb_p20_tok : tokenizeT 4 wb_p20 = some wb_t20 := by
  decide +kernel
def wb_p21 : List Char := ['(', '<', '=']
def wb_t21 : List String := ["(", "<="]
theorem wb_p21_tok : tokenizeT 4 wb_p21 = some wb_t21 := by
  decide +kernel
def wb_p22 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t22 : List String := ["(", "pair"]
theorem wb_p22_tok : tokenizeT 6 wb_p22 = some wb_t22 := by
  decide +kernel
def wb_p23 : List Char := ['o', 'f', 'f']
def wb_t23 : List String := ["off"]
theorem wb_p23_tok : tokenizeT 4 wb_p23 = some wb_t23 := by
  decide +kernel
def wb_p24 : List Char := ['n', ')', ')']
def wb_t24 : List String := ["n", ")", ")"]
theorem wb_p24_tok : tokenizeT 4 wb_p24 = some wb_t24 := by
  decide +kernel
def wb_p25 : List Char := ['p', 'a', 's', 's']
def wb_t25 : List String := ["pass"]
theorem wb_p25_tok : tokenizeT 5 wb_p25 = some wb_t25 := by
  decide +kernel
def wb_p26 : List Char := ['(', 'r', 'a', 'i', 's', 'e']
def wb_t26 : List String := ["(", "raise"]
theorem wb_p26_tok : tokenizeT 7 wb_p26 = some wb_t26 := by
  decide +kernel
def wb_p27 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t27 : List String := ["(", "pair"]
theorem wb_p27_tok : tokenizeT 6 wb_p27 = some wb_t27 := by
  decide +kernel
def wb_p28 : List Char := ['"', 'A', 's', 's', 'e', 'r', 't', 'i', 'o', 'n', 'F', 'a', 'i', 'l', 'u', 'r', 'e', '"']
def wb_t28 : List String := ["\"AssertionFailure\""]
theorem wb_p28_tok : tokenizeT 19 wb_p28 = some wb_t28 := by
  decide +kernel
def wb_p29 : List Char := ['(', ')', ')', ')', ')']
def wb_t29 : List String := ["(", ")", ")", ")", ")"]
theorem wb_p29_tok : tokenizeT 6 wb_p29 = some wb_t29 := by
  decide +kernel
def wb_p30 : List Char := ['(', 's', 'e', 'q']
def wb_t30 : List String := ["(", "seq"]
theorem wb_p30_tok : tokenizeT 5 wb_p30 = some wb_t30 := by
  decide +kernel
def wb_p31 : List Char := ['(', 's', 'e', 'q']
def wb_t31 : List String := ["(", "seq"]
theorem wb_p31_tok : tokenizeT 5 wb_p31 = some wb_t31 := by
  decide +kernel
def wb_p32 : List Char := ['(', 'g', 'e', 't']
def wb_t32 : List String := ["(", "get"]
theorem wb_p32_tok : tokenizeT 5 wb_p32 = some wb_t32 := by
  decide +kernel
def wb_p33 : List Char := ['$', 't', '9']
def wb_t33 : List String := ["$t9"]
theorem wb_p33_tok : tokenizeT 4 wb_p33 = some wb_t33 := by
  decide +kernel
def wb_p34 : List Char := ['b']
def wb_t34 : List String := ["b"]
theorem wb_p34_tok : tokenizeT 2 wb_p34 = some wb_t34 := by
  decide +kernel
def wb_p35 : List Char := ['l', 'e', 'n', ')']
def wb_t35 : List String := ["len", ")"]
theorem wb_p35_tok : tokenizeT 5 wb_p35 = some wb_t35 := by
  decide +kernel
def wb_p36 : List Char := ['(', 'i', 'f']
def wb_t36 : List String := ["(", "if"]
theorem wb_p36_tok : tokenizeT 4 wb_p36 = some wb_t36 := by
  decide +kernel
def wb_p37 : List Char := ['(', '<', '=']
def wb_t37 : List String := ["(", "<="]
theorem wb_p37_tok : tokenizeT 4 wb_p37 = some wb_t37 := by
  decide +kernel
def wb_p38 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t38 : List String := ["(", "pair"]
theorem wb_p38_tok : tokenizeT 6 wb_p38 = some wb_t38 := by
  decide +kernel
def wb_p39 : List Char := ['n']
def wb_t39 : List String := ["n"]
theorem wb_p39_tok : tokenizeT 2 wb_p39 = some wb_t39 := by
  decide +kernel
def wb_p40 : List Char := ['$', 't', '9', ')', ')']
def wb_t40 : List String := ["$t9", ")", ")"]
theorem wb_p40_tok : tokenizeT 6 wb_p40 = some wb_t40 := by
  decide +kernel
def wb_p41 : List Char := ['p', 'a', 's', 's']
def wb_t41 : List String := ["pass"]
theorem wb_p41_tok : tokenizeT 5 wb_p41 = some wb_t41 := by
  decide +kernel
def wb_p42 : List Char := ['(', 'r', 'a', 'i', 's', 'e']
def wb_t42 : List String := ["(", "raise"]
theorem wb_p42_tok : tokenizeT 7 wb_p42 = some wb_t42 := by
  decide +kernel
def wb_p43 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t43 : List String := ["(", "pair"]
theorem wb_p43_tok : tokenizeT 6 wb_p43 = some wb_t43 := by
  decide +kernel
def wb_p44 : List Char := ['"', 'A', 's', 's', 'e', 'r', 't', 'i', 'o', 'n', 'F', 'a', 'i', 'l', 'u', 'r', 'e', '"']
def wb_t44 : List String := ["\"AssertionFailure\""]
theorem wb_p44_tok : tokenizeT 19 wb_p44 = some wb_t44 := by
  decide +kernel
def wb_p45 : List Char := ['(', ')', ')', ')', ')', ')']
def wb_t45 : List String := ["(", ")", ")", ")", ")", ")"]
theorem wb_p45_tok : tokenizeT 7 wb_p45 = some wb_t45 := by
  decide +kernel
def wb_p46 : List Char := ['(', 's', 'e', 'q']
def wb_t46 : List String := ["(", "seq"]
theorem wb_p46_tok : tokenizeT 5 wb_p46 = some wb_t46 := by
  decide +kernel
def wb_p47 : List Char := ['(', 's', 'e', 'q']
def wb_t47 : List String := ["(", "seq"]
theorem wb_p47_tok : tokenizeT 5 wb_p47 = some wb_t47 := by
  decide +kernel
def wb_p48 : List Char := ['(', 'g', 'e', 't']
def wb_t48 : List String := ["(", "get"]
theorem wb_p48_tok : tokenizeT 5 wb_p48 = some wb_t48 := by
  decide +kernel
def wb_p49 : List Char := ['$', 't', '1', '0']
def wb_t49 : List String := ["$t10"]
theorem wb_p49_tok : tokenizeT 5 wb_p49 = some wb_t49 := by
  decide +kernel
def wb_p50 : List Char := ['b']
def wb_t50 : List String := ["b"]
theorem wb_p50_tok : tokenizeT 2 wb_p50 = some wb_t50 := by
  decide +kernel
def wb_p51 : List Char := ['l', 'e', 'n', ')']
def wb_t51 : List String := ["len", ")"]
theorem wb_p51_tok : tokenizeT 5 wb_p51 = some wb_t51 := by
  decide +kernel
def wb_p52 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t52 : List String := ["(", "assign"]
theorem wb_p52_tok : tokenizeT 8 wb_p52 = some wb_t52 := by
  decide +kernel
def wb_p53 : List Char := ['l']
def wb_t53 : List String := ["l"]
theorem wb_p53_tok : tokenizeT 2 wb_p53 = some wb_t53 := by
  decide +kernel
def wb_p54 : List Char := ['$', 't', '1', '0', ')', ')']
def wb_t54 : List String := ["$t10", ")", ")"]
theorem wb_p54_tok : tokenizeT 7 wb_p54 = some wb_t54 := by
  decide +kernel
def wb_p55 : List Char := ['(', 's', 'e', 'q']
def wb_t55 : List String := ["(", "seq"]
theorem wb_p55_tok : tokenizeT 5 wb_p55 = some wb_t55 := by
  decide +kernel
def wb_p56 : List Char := ['(', 's', 'e', 'q']
def wb_t56 : List String := ["(", "seq"]
theorem wb_p56_tok : tokenizeT 5 wb_p56 = some wb_t56 := by
  decide +kernel
def wb_p57 : List Char := ['(', 'g', 'e', 't']
def wb_t57 : List String := ["(", "get"]
theorem wb_p57_tok : tokenizeT 5 wb_p57 = some wb_t57 := by
  decide +kernel
def wb_p58 : List Char := ['$', 't', '1', '1']
def wb_t58 : List String := ["$t11"]
theorem wb_p58_tok : tokenizeT 5 wb_p58 = some wb_t58 := by
  decide +kernel
def wb_p59 : List Char := ['b']
def wb_t59 : List String := ["b"]
theorem wb_p59_tok : tokenizeT 2 wb_p59 = some wb_t59 := by
  decide +kernel
def wb_p60 : List Char := ['c', 'a', 'p', ')']
def wb_t60 : List String := ["cap", ")"]
theorem wb_p60_tok : tokenizeT 5 wb_p60 = some wb_t60 := by
  decide +kernel
def wb_p61 : List Char := ['(', 'i', 'f']
def wb_t61 : List String := ["(", "if"]
theorem wb_p61_tok : tokenizeT 4 wb_p61 = some wb_t61 := by
  decide +kernel
def wb_p62 : List Char := ['(', '<', '=']
def wb_t62 : List String := ["(", "<="]
theorem wb_p62_tok : tokenizeT 4 wb_p62 = some wb_t62 := by
  decide +kernel
def wb_p63 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t63 : List String := ["(", "pair"]
theorem wb_p63_tok : tokenizeT 6 wb_p63 = some wb_t63 := by
  decide +kernel
def wb_p64 : List Char := ['l']
def wb_t64 : List String := ["l"]
theorem wb_p64_tok : tokenizeT 2 wb_p64 = some wb_t64 := by
  decide +kernel
def wb_p65 : List Char := ['$', 't', '1', '1', ')', ')']
def wb_t65 : List String := ["$t11", ")", ")"]
theorem wb_p65_tok : tokenizeT 7 wb_p65 = some wb_t65 := by
  decide +kernel
def wb_p66 : List Char := ['p', 'a', 's', 's']
def wb_t66 : List String := ["pass"]
theorem wb_p66_tok : tokenizeT 5 wb_p66 = some wb_t66 := by
  decide +kernel
def wb_p67 : List Char := ['(', 'r', 'a', 'i', 's', 'e']
def wb_t67 : List String := ["(", "raise"]
theorem wb_p67_tok : tokenizeT 7 wb_p67 = some wb_t67 := by
  decide +kernel
def wb_p68 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t68 : List String := ["(", "pair"]
theorem wb_p68_tok : tokenizeT 6 wb_p68 = some wb_t68 := by
  decide +kernel
def wb_p69 : List Char := ['"', 'A', 's', 's', 'e', 'r', 't', 'i', 'o', 'n', 'F', 'a', 'i', 'l', 'u', 'r', 'e', '"']
def wb_t69 : List String := ["\"AssertionFailure\""]
theorem wb_p69_tok : tokenizeT 19 wb_p69 = some wb_t69 := by
  decide +kernel
def wb_p70 : List Char := ['(', ')', ')', ')', ')', ')']
def wb_t70 : List String := ["(", ")", ")", ")", ")", ")"]
theorem wb_p70_tok : tokenizeT 7 wb_p70 = some wb_t70 := by
  decide +kernel
def wb_p71 : List Char := ['(', 's', 'e', 'q']
def wb_t71 : List String := ["(", "seq"]
theorem wb_p71_tok : tokenizeT 5 wb_p71 = some wb_t71 := by
  decide +kernel
def wb_p72 : List Char := ['(', 's', 'e', 'q']
def wb_t72 : List String := ["(", "seq"]
theorem wb_p72_tok : tokenizeT 5 wb_p72 = some wb_t72 := by
  decide +kernel
def wb_p73 : List Char := ['(', 'g', 'e', 't']
def wb_t73 : List String := ["(", "get"]
theorem wb_p73_tok : tokenizeT 5 wb_p73 = some wb_t73 := by
  decide +kernel
def wb_p74 : List Char := ['$', 't', '1', '2']
def wb_t74 : List String := ["$t12"]
theorem wb_p74_tok : tokenizeT 5 wb_p74 = some wb_t74 := by
  decide +kernel
def wb_p75 : List Char := ['b']
def wb_t75 : List String := ["b"]
theorem wb_p75_tok : tokenizeT 2 wb_p75 = some wb_t75 := by
  decide +kernel
def wb_p76 : List Char := ['b', 'y', 't', 'e', 's', ')']
def wb_t76 : List String := ["bytes", ")"]
theorem wb_p76_tok : tokenizeT 7 wb_p76 = some wb_t76 := by
  decide +kernel
def wb_p77 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t77 : List String := ["(", "assign"]
theorem wb_p77_tok : tokenizeT 8 wb_p77 = some wb_t77 := by
  decide +kernel
def wb_p78 : List Char := ['r', 'e', 'q']
def wb_t78 : List String := ["req"]
theorem wb_p78_tok : tokenizeT 4 wb_p78 = some wb_t78 := by
  decide +kernel
def wb_p79 : List Char := ['(', 's', 'l', 'i', 'c', 'e']
def wb_t79 : List String := ["(", "slice"]
theorem wb_p79_tok : tokenizeT 7 wb_p79 = some wb_t79 := by
  decide +kernel
def wb_p80 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t80 : List String := ["(", "pair"]
theorem wb_p80_tok : tokenizeT 6 wb_p80 = some wb_t80 := by
  decide +kernel
def wb_p81 : List Char := ['$', 't', '1', '2']
def wb_t81 : List String := ["$t12"]
theorem wb_p81_tok : tokenizeT 5 wb_p81 = some wb_t81 := by
  decide +kernel
def wb_p82 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t82 : List String := ["(", "pair"]
theorem wb_p82_tok : tokenizeT 6 wb_p82 = some wb_t82 := by
  decide +kernel
def wb_p83 : List Char := ['o', 'f', 'f']
def wb_t83 : List String := ["off"]
theorem wb_p83_tok : tokenizeT 4 wb_p83 = some wb_t83 := by
  decide +kernel
def wb_p84 : List Char := ['n', ')', ')', ')', ')', ')']
def wb_t84 : List String := ["n", ")", ")", ")", ")", ")"]
theorem wb_p84_tok : tokenizeT 7 wb_p84 = some wb_t84 := by
  decide +kernel
def wb_p85 : List Char := ['(', 's', 'e', 'q']
def wb_t85 : List String := ["(", "seq"]
theorem wb_p85_tok : tokenizeT 5 wb_p85 = some wb_t85 := by
  decide +kernel
def wb_p86 : List Char := ['(', 's', 'e', 'q']
def wb_t86 : List String := ["(", "seq"]
theorem wb_p86_tok : tokenizeT 5 wb_p86 = some wb_t86 := by
  decide +kernel
def wb_p87 : List Char := ['(', 'g', 'e', 't']
def wb_t87 : List String := ["(", "get"]
theorem wb_p87_tok : tokenizeT 5 wb_p87 = some wb_t87 := by
  decide +kernel
def wb_p88 : List Char := ['$', 't', '1', '3']
def wb_t88 : List String := ["$t13"]
theorem wb_p88_tok : tokenizeT 5 wb_p88 = some wb_t88 := by
  decide +kernel
def wb_p89 : List Char := [Char.ofNat 963]
def wb_t89 : List String := ["σ"]
theorem wb_p89_tok : tokenizeT 2 wb_p89 = some wb_t89 := by
  decide +kernel
def wb_p90 : List Char := ['w', 'r', 'i', 't', 'e', 's', ')']
def wb_t90 : List String := ["writes", ")"]
theorem wb_p90_tok : tokenizeT 8 wb_p90 = some wb_t90 := by
  decide +kernel
def wb_p91 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t91 : List String := ["(", "assign"]
theorem wb_p91_tok : tokenizeT 8 wb_p91 = some wb_t91 := by
  decide +kernel
def wb_p92 : List Char := ['q']
def wb_t92 : List String := ["q"]
theorem wb_p92_tok : tokenizeT 2 wb_p92 = some wb_t92 := by
  decide +kernel
def wb_p93 : List Char := ['(', 'h', 'e', 'a', 'd', '_', 'o', 'r']
def wb_t93 : List String := ["(", "head_or"]
theorem wb_p93_tok : tokenizeT 9 wb_p93 = some wb_t93 := by
  decide +kernel
def wb_p94 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t94 : List String := ["(", "pair"]
theorem wb_p94_tok : tokenizeT 6 wb_p94 = some wb_t94 := by
  decide +kernel
def wb_p95 : List Char := ['$', 't', '1', '3']
def wb_t95 : List String := ["$t13"]
theorem wb_p95_tok : tokenizeT 5 wb_p95 = some wb_t95 := by
  decide +kernel
def wb_p96 : List Char := ['(', 'l', 'e', 'n', 'g', 't', 'h']
def wb_t96 : List String := ["(", "length"]
theorem wb_p96_tok : tokenizeT 8 wb_p96 = some wb_t96 := by
  decide +kernel
def wb_p97 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', '-', 'l', 'i', 's', 't', ':', '0', ':', '2', '5', '5']
def wb_t97 : List String := ["(", "range-list:0:255"]
theorem wb_p97_tok : tokenizeT 18 wb_p97 = some wb_t97 := by
  decide +kernel
def wb_p98 : List Char := ['r', 'e', 'q', ')', ')', ')', ')', ')', ')']
def wb_t98 : List String := ["req", ")", ")", ")", ")", ")", ")"]
theorem wb_p98_tok : tokenizeT 10 wb_p98 = some wb_t98 := by
  decide +kernel
def wb_p99 : List Char := ['(', 's', 'e', 'q']
def wb_t99 : List String := ["(", "seq"]
theorem wb_p99_tok : tokenizeT 5 wb_p99 = some wb_t99 := by
  decide +kernel
def wb_p100 : List Char := ['(', 's', 'e', 'q']
def wb_t100 : List String := ["(", "seq"]
theorem wb_p100_tok : tokenizeT 5 wb_p100 = some wb_t100 := by
  decide +kernel
def wb_p101 : List Char := ['(', 'g', 'e', 't']
def wb_t101 : List String := ["(", "get"]
theorem wb_p101_tok : tokenizeT 5 wb_p101 = some wb_t101 := by
  decide +kernel
def wb_p102 : List Char := ['$', 't', '1', '4']
def wb_t102 : List String := ["$t14"]
theorem wb_p102_tok : tokenizeT 5 wb_p102 = some wb_t102 := by
  decide +kernel
def wb_p103 : List Char := [Char.ofNat 963]
def wb_t103 : List String := ["σ"]
theorem wb_p103_tok : tokenizeT 2 wb_p103 = some wb_t103 := by
  decide +kernel
def wb_p104 : List Char := ['w', 'r', 'i', 't', 'e', 's', ')']
def wb_t104 : List String := ["writes", ")"]
theorem wb_p104_tok : tokenizeT 8 wb_p104 = some wb_t104 := by
  decide +kernel
def wb_p105 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def wb_t105 : List String := ["(", "set-attr"]
theorem wb_p105_tok : tokenizeT 10 wb_p105 = some wb_t105 := by
  decide +kernel
def wb_p106 : List Char := [Char.ofNat 963]
def wb_t106 : List String := ["σ"]
theorem wb_p106_tok : tokenizeT 2 wb_p106 = some wb_t106 := by
  decide +kernel
def wb_p107 : List Char := ['w', 'r', 'i', 't', 'e', 's']
def wb_t107 : List String := ["writes"]
theorem wb_p107_tok : tokenizeT 7 wb_p107 = some wb_t107 := by
  decide +kernel
def wb_p108 : List Char := ['(', 't', 'a', 'i', 'l']
def wb_t108 : List String := ["(", "tail"]
theorem wb_p108_tok : tokenizeT 6 wb_p108 = some wb_t108 := by
  decide +kernel
def wb_p109 : List Char := ['$', 't', '1', '4', ')', ')', ')']
def wb_t109 : List String := ["$t14", ")", ")", ")"]
theorem wb_p109_tok : tokenizeT 8 wb_p109 = some wb_t109 := by
  decide +kernel
def wb_p110 : List Char := ['(', 's', 'e', 'q']
def wb_t110 : List String := ["(", "seq"]
theorem wb_p110_tok : tokenizeT 5 wb_p110 = some wb_t110 := by
  decide +kernel
def wb_p111 : List Char := ['(', 's', 'e', 'q']
def wb_t111 : List String := ["(", "seq"]
theorem wb_p111_tok : tokenizeT 5 wb_p111 = some wb_t111 := by
  decide +kernel
def wb_p112 : List Char := ['(', 'g', 'e', 't']
def wb_t112 : List String := ["(", "get"]
theorem wb_p112_tok : tokenizeT 5 wb_p112 = some wb_t112 := by
  decide +kernel
def wb_p113 : List Char := ['$', 't', '1', '5']
def wb_t113 : List String := ["$t15"]
theorem wb_p113_tok : tokenizeT 5 wb_p113 = some wb_t113 := by
  decide +kernel
def wb_p114 : List Char := [Char.ofNat 963]
def wb_t114 : List String := ["σ"]
theorem wb_p114_tok : tokenizeT 2 wb_p114 = some wb_t114 := by
  decide +kernel
def wb_p115 : List Char := ['w', 'r', 'i', 't', 'e', '_', 'c', 'a', 'l', 'l', 's', ')']
def wb_t115 : List String := ["write_calls", ")"]
theorem wb_p115_tok : tokenizeT 13 wb_p115 = some wb_t115 := by
  decide +kernel
def wb_p116 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def wb_t116 : List String := ["(", "set-attr"]
theorem wb_p116_tok : tokenizeT 10 wb_p116 = some wb_t116 := by
  decide +kernel
def wb_p117 : List Char := [Char.ofNat 963]
def wb_t117 : List String := ["σ"]
theorem wb_p117_tok : tokenizeT 2 wb_p117 = some wb_t117 := by
  decide +kernel
def wb_p118 : List Char := ['w', 'r', 'i', 't', 'e', '_', 'c', 'a', 'l', 'l', 's']
def wb_t118 : List String := ["write_calls"]
theorem wb_p118_tok : tokenizeT 12 wb_p118 = some wb_t118 := by
  decide +kernel
def wb_p119 : List Char := ['(', '+']
def wb_t119 : List String := ["(", "+"]
theorem wb_p119_tok : tokenizeT 3 wb_p119 = some wb_t119 := by
  decide +kernel
def wb_p120 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t120 : List String := ["(", "pair"]
theorem wb_p120_tok : tokenizeT 6 wb_p120 = some wb_t120 := by
  decide +kernel
def wb_p121 : List Char := ['$', 't', '1', '5']
def wb_t121 : List String := ["$t15"]
theorem wb_p121_tok : tokenizeT 5 wb_p121 = some wb_t121 := by
  decide +kernel
def wb_p122 : List Char := ['1', ')', ')', ')', ')']
def wb_t122 : List String := ["1", ")", ")", ")", ")"]
theorem wb_p122_tok : tokenizeT 6 wb_p122 = some wb_t122 := by
  decide +kernel
def wb_p123 : List Char := ['(', 's', 'e', 'q']
def wb_t123 : List String := ["(", "seq"]
theorem wb_p123_tok : tokenizeT 5 wb_p123 = some wb_t123 := by
  decide +kernel
def wb_p124 : List Char := ['(', 'i', 'f']
def wb_t124 : List String := ["(", "if"]
theorem wb_p124_tok : tokenizeT 4 wb_p124 = some wb_t124 := by
  decide +kernel
def wb_p125 : List Char := ['(', '<']
def wb_t125 : List String := ["(", "<"]
theorem wb_p125_tok : tokenizeT 3 wb_p125 = some wb_t125 := by
  decide +kernel
def wb_p126 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t126 : List String := ["(", "pair"]
theorem wb_p126_tok : tokenizeT 6 wb_p126 = some wb_t126 := by
  decide +kernel
def wb_p127 : List Char := ['q']
def wb_t127 : List String := ["q"]
theorem wb_p127_tok : tokenizeT 2 wb_p127 = some wb_t127 := by
  decide +kernel
def wb_p128 : List Char := ['0', ')', ')']
def wb_t128 : List String := ["0", ")", ")"]
theorem wb_p128_tok : tokenizeT 4 wb_p128 = some wb_t128 := by
  decide +kernel
def wb_p129 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def wb_t129 : List String := ["(", "return"]
theorem wb_p129_tok : tokenizeT 8 wb_p129 = some wb_t129 := by
  decide +kernel
def wb_p130 : List Char := ['-', '1', ')']
def wb_t130 : List String := ["-1", ")"]
theorem wb_p130_tok : tokenizeT 4 wb_p130 = some wb_t130 := by
  decide +kernel
def wb_p131 : List Char := ['p', 'a', 's', 's', ')']
def wb_t131 : List String := ["pass", ")"]
theorem wb_p131_tok : tokenizeT 6 wb_p131 = some wb_t131 := by
  decide +kernel
def wb_p132 : List Char := ['(', 's', 'e', 'q']
def wb_t132 : List String := ["(", "seq"]
theorem wb_p132_tok : tokenizeT 5 wb_p132 = some wb_t132 := by
  decide +kernel
def wb_p133 : List Char := ['(', 'a', 's', 's', 'i', 'g', 'n']
def wb_t133 : List String := ["(", "assign"]
theorem wb_p133_tok : tokenizeT 8 wb_p133 = some wb_t133 := by
  decide +kernel
def wb_p134 : List Char := ['k']
def wb_t134 : List String := ["k"]
theorem wb_p134_tok : tokenizeT 2 wb_p134 = some wb_t134 := by
  decide +kernel
def wb_p135 : List Char := ['(', 'm', 'i', 'n']
def wb_t135 : List String := ["(", "min"]
theorem wb_p135_tok : tokenizeT 5 wb_p135 = some wb_t135 := by
  decide +kernel
def wb_p136 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t136 : List String := ["(", "pair"]
theorem wb_p136_tok : tokenizeT 6 wb_p136 = some wb_t136 := by
  decide +kernel
def wb_p137 : List Char := ['q']
def wb_t137 : List String := ["q"]
theorem wb_p137_tok : tokenizeT 2 wb_p137 = some wb_t137 := by
  decide +kernel
def wb_p138 : List Char := ['(', 'l', 'e', 'n', 'g', 't', 'h']
def wb_t138 : List String := ["(", "length"]
theorem wb_p138_tok : tokenizeT 8 wb_p138 = some wb_t138 := by
  decide +kernel
def wb_p139 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', '-', 'l', 'i', 's', 't', ':', '0', ':', '2', '5', '5']
def wb_t139 : List String := ["(", "range-list:0:255"]
theorem wb_p139_tok : tokenizeT 18 wb_p139 = some wb_t139 := by
  decide +kernel
def wb_p140 : List Char := ['r', 'e', 'q', ')', ')', ')', ')', ')']
def wb_t140 : List String := ["req", ")", ")", ")", ")", ")"]
theorem wb_p140_tok : tokenizeT 9 wb_p140 = some wb_t140 := by
  decide +kernel
def wb_p141 : List Char := ['(', 's', 'e', 'q']
def wb_t141 : List String := ["(", "seq"]
theorem wb_p141_tok : tokenizeT 5 wb_p141 = some wb_t141 := by
  decide +kernel
def wb_p142 : List Char := ['(', 's', 'e', 'q']
def wb_t142 : List String := ["(", "seq"]
theorem wb_p142_tok : tokenizeT 5 wb_p142 = some wb_t142 := by
  decide +kernel
def wb_p143 : List Char := ['(', 'g', 'e', 't']
def wb_t143 : List String := ["(", "get"]
theorem wb_p143_tok : tokenizeT 5 wb_p143 = some wb_t143 := by
  decide +kernel
def wb_p144 : List Char := ['$', 't', '1', '6']
def wb_t144 : List String := ["$t16"]
theorem wb_p144_tok : tokenizeT 5 wb_p144 = some wb_t144 := by
  decide +kernel
def wb_p145 : List Char := [Char.ofNat 963]
def wb_t145 : List String := ["σ"]
theorem wb_p145_tok : tokenizeT 2 wb_p145 = some wb_t145 := by
  decide +kernel
def wb_p146 : List Char := ['d', 'e', 'l', 'i', 'v', 'e', 'r', 'e', 'd', ')']
def wb_t146 : List String := ["delivered", ")"]
theorem wb_p146_tok : tokenizeT 11 wb_p146 = some wb_t146 := by
  decide +kernel
def wb_p147 : List Char := ['(', 's', 'e', 't', '-', 'a', 't', 't', 'r']
def wb_t147 : List String := ["(", "set-attr"]
theorem wb_p147_tok : tokenizeT 10 wb_p147 = some wb_t147 := by
  decide +kernel
def wb_p148 : List Char := [Char.ofNat 963]
def wb_t148 : List String := ["σ"]
theorem wb_p148_tok : tokenizeT 2 wb_p148 = some wb_t148 := by
  decide +kernel
def wb_p149 : List Char := ['d', 'e', 'l', 'i', 'v', 'e', 'r', 'e', 'd']
def wb_t149 : List String := ["delivered"]
theorem wb_p149_tok : tokenizeT 10 wb_p149 = some wb_t149 := by
  decide +kernel
def wb_p150 : List Char := ['(', 'a', 'p', 'p', 'e', 'n', 'd']
def wb_t150 : List String := ["(", "append"]
theorem wb_p150_tok : tokenizeT 8 wb_p150 = some wb_t150 := by
  decide +kernel
def wb_p151 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t151 : List String := ["(", "pair"]
theorem wb_p151_tok : tokenizeT 6 wb_p151 = some wb_t151 := by
  decide +kernel
def wb_p152 : List Char := ['$', 't', '1', '6']
def wb_t152 : List String := ["$t16"]
theorem wb_p152_tok : tokenizeT 5 wb_p152 = some wb_t152 := by
  decide +kernel
def wb_p153 : List Char := ['(', 't', 'a', 'k', 'e']
def wb_t153 : List String := ["(", "take"]
theorem wb_p153_tok : tokenizeT 6 wb_p153 = some wb_t153 := by
  decide +kernel
def wb_p154 : List Char := ['(', 'p', 'a', 'i', 'r']
def wb_t154 : List String := ["(", "pair"]
theorem wb_p154_tok : tokenizeT 6 wb_p154 = some wb_t154 := by
  decide +kernel
def wb_p155 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', '-', 'l', 'i', 's', 't', ':', '0', ':', '2', '5', '5']
def wb_t155 : List String := ["(", "range-list:0:255"]
theorem wb_p155_tok : tokenizeT 18 wb_p155 = some wb_t155 := by
  decide +kernel
def wb_p156 : List Char := ['r', 'e', 'q', ')']
def wb_t156 : List String := ["req", ")"]
theorem wb_p156_tok : tokenizeT 5 wb_p156 = some wb_t156 := by
  decide +kernel
def wb_p157 : List Char := ['(', 'r', 'a', 'n', 'g', 'e', ':', '0', ':', '4', '6', '1', '1', '6', '8', '6', '0', '1', '8', '4', '2', '7', '3', '8', '7', '9', '0', '3']
def wb_t157 : List String := ["(", "range:0:4611686018427387903"]
theorem wb_p157_tok : tokenizeT 29 wb_p157 = some wb_t157 := by
  decide +kernel
def wb_p158 : List Char := ['k', ')', ')', ')', ')', ')', ')', ')']
def wb_t158 : List String := ["k", ")", ")", ")", ")", ")", ")", ")"]
theorem wb_p158_tok : tokenizeT 9 wb_p158 = some wb_t158 := by
  decide +kernel
def wb_p159 : List Char := ['(', 'r', 'e', 't', 'u', 'r', 'n']
def wb_t159 : List String := ["(", "return"]
theorem wb_p159_tok : tokenizeT 8 wb_p159 = some wb_t159 := by
  decide +kernel
def wb_p160 : List Char := ['k', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')', ')']
def wb_t160 : List String := ["k", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")", ")"]
theorem wb_p160_tok : tokenizeT 17 wb_p160 = some wb_t160 := by
  decide +kernel
def wb_s160 : List Char := wb_p160
def wb_st160 : List String := wb_t160
theorem wb_s160_tok : tokenizeT 17 wb_s160 = some wb_st160 := wb_p160_tok
def wb_s159 : List Char := wb_p159 ++ ' ' :: wb_s160
def wb_st159 : List String := wb_t159 ++ wb_st160
theorem wb_s159_tok : tokenizeT 26 wb_s159 = some wb_st159 :=
  tokenizeT_concat_space 8 17 _ _ _ _ wb_p159_tok wb_s160_tok
def wb_s158 : List Char := wb_p158 ++ ' ' :: wb_s159
def wb_st158 : List String := wb_t158 ++ wb_st159
theorem wb_s158_tok : tokenizeT 36 wb_s158 = some wb_st158 :=
  tokenizeT_concat_space 9 26 _ _ _ _ wb_p158_tok wb_s159_tok
def wb_s157 : List Char := wb_p157 ++ ' ' :: wb_s158
def wb_st157 : List String := wb_t157 ++ wb_st158
theorem wb_s157_tok : tokenizeT 66 wb_s157 = some wb_st157 :=
  tokenizeT_concat_space 29 36 _ _ _ _ wb_p157_tok wb_s158_tok
def wb_s156 : List Char := wb_p156 ++ ' ' :: wb_s157
def wb_st156 : List String := wb_t156 ++ wb_st157
theorem wb_s156_tok : tokenizeT 72 wb_s156 = some wb_st156 :=
  tokenizeT_concat_space 5 66 _ _ _ _ wb_p156_tok wb_s157_tok
def wb_s155 : List Char := wb_p155 ++ ' ' :: wb_s156
def wb_st155 : List String := wb_t155 ++ wb_st156
theorem wb_s155_tok : tokenizeT 91 wb_s155 = some wb_st155 :=
  tokenizeT_concat_space 18 72 _ _ _ _ wb_p155_tok wb_s156_tok
def wb_s154 : List Char := wb_p154 ++ ' ' :: wb_s155
def wb_st154 : List String := wb_t154 ++ wb_st155
theorem wb_s154_tok : tokenizeT 98 wb_s154 = some wb_st154 :=
  tokenizeT_concat_space 6 91 _ _ _ _ wb_p154_tok wb_s155_tok
def wb_s153 : List Char := wb_p153 ++ ' ' :: wb_s154
def wb_st153 : List String := wb_t153 ++ wb_st154
theorem wb_s153_tok : tokenizeT 105 wb_s153 = some wb_st153 :=
  tokenizeT_concat_space 6 98 _ _ _ _ wb_p153_tok wb_s154_tok
def wb_s152 : List Char := wb_p152 ++ ' ' :: wb_s153
def wb_st152 : List String := wb_t152 ++ wb_st153
theorem wb_s152_tok : tokenizeT 111 wb_s152 = some wb_st152 :=
  tokenizeT_concat_space 5 105 _ _ _ _ wb_p152_tok wb_s153_tok
def wb_s151 : List Char := wb_p151 ++ ' ' :: wb_s152
def wb_st151 : List String := wb_t151 ++ wb_st152
theorem wb_s151_tok : tokenizeT 118 wb_s151 = some wb_st151 :=
  tokenizeT_concat_space 6 111 _ _ _ _ wb_p151_tok wb_s152_tok
def wb_s150 : List Char := wb_p150 ++ ' ' :: wb_s151
def wb_st150 : List String := wb_t150 ++ wb_st151
theorem wb_s150_tok : tokenizeT 127 wb_s150 = some wb_st150 :=
  tokenizeT_concat_space 8 118 _ _ _ _ wb_p150_tok wb_s151_tok
def wb_s149 : List Char := wb_p149 ++ ' ' :: wb_s150
def wb_st149 : List String := wb_t149 ++ wb_st150
theorem wb_s149_tok : tokenizeT 138 wb_s149 = some wb_st149 :=
  tokenizeT_concat_space 10 127 _ _ _ _ wb_p149_tok wb_s150_tok
def wb_s148 : List Char := wb_p148 ++ ' ' :: wb_s149
def wb_st148 : List String := wb_t148 ++ wb_st149
theorem wb_s148_tok : tokenizeT 141 wb_s148 = some wb_st148 :=
  tokenizeT_concat_space 2 138 _ _ _ _ wb_p148_tok wb_s149_tok
def wb_s147 : List Char := wb_p147 ++ ' ' :: wb_s148
def wb_st147 : List String := wb_t147 ++ wb_st148
theorem wb_s147_tok : tokenizeT 152 wb_s147 = some wb_st147 :=
  tokenizeT_concat_space 10 141 _ _ _ _ wb_p147_tok wb_s148_tok
def wb_s146 : List Char := wb_p146 ++ ' ' :: wb_s147
def wb_st146 : List String := wb_t146 ++ wb_st147
theorem wb_s146_tok : tokenizeT 164 wb_s146 = some wb_st146 :=
  tokenizeT_concat_space 11 152 _ _ _ _ wb_p146_tok wb_s147_tok
def wb_s145 : List Char := wb_p145 ++ ' ' :: wb_s146
def wb_st145 : List String := wb_t145 ++ wb_st146
theorem wb_s145_tok : tokenizeT 167 wb_s145 = some wb_st145 :=
  tokenizeT_concat_space 2 164 _ _ _ _ wb_p145_tok wb_s146_tok
def wb_s144 : List Char := wb_p144 ++ ' ' :: wb_s145
def wb_st144 : List String := wb_t144 ++ wb_st145
theorem wb_s144_tok : tokenizeT 173 wb_s144 = some wb_st144 :=
  tokenizeT_concat_space 5 167 _ _ _ _ wb_p144_tok wb_s145_tok
def wb_s143 : List Char := wb_p143 ++ ' ' :: wb_s144
def wb_st143 : List String := wb_t143 ++ wb_st144
theorem wb_s143_tok : tokenizeT 179 wb_s143 = some wb_st143 :=
  tokenizeT_concat_space 5 173 _ _ _ _ wb_p143_tok wb_s144_tok
def wb_s142 : List Char := wb_p142 ++ ' ' :: wb_s143
def wb_st142 : List String := wb_t142 ++ wb_st143
theorem wb_s142_tok : tokenizeT 185 wb_s142 = some wb_st142 :=
  tokenizeT_concat_space 5 179 _ _ _ _ wb_p142_tok wb_s143_tok
def wb_s141 : List Char := wb_p141 ++ ' ' :: wb_s142
def wb_st141 : List String := wb_t141 ++ wb_st142
theorem wb_s141_tok : tokenizeT 191 wb_s141 = some wb_st141 :=
  tokenizeT_concat_space 5 185 _ _ _ _ wb_p141_tok wb_s142_tok
def wb_s140 : List Char := wb_p140 ++ ' ' :: wb_s141
def wb_st140 : List String := wb_t140 ++ wb_st141
theorem wb_s140_tok : tokenizeT 201 wb_s140 = some wb_st140 :=
  tokenizeT_concat_space 9 191 _ _ _ _ wb_p140_tok wb_s141_tok
def wb_s139 : List Char := wb_p139 ++ ' ' :: wb_s140
def wb_st139 : List String := wb_t139 ++ wb_st140
theorem wb_s139_tok : tokenizeT 220 wb_s139 = some wb_st139 :=
  tokenizeT_concat_space 18 201 _ _ _ _ wb_p139_tok wb_s140_tok
def wb_s138 : List Char := wb_p138 ++ ' ' :: wb_s139
def wb_st138 : List String := wb_t138 ++ wb_st139
theorem wb_s138_tok : tokenizeT 229 wb_s138 = some wb_st138 :=
  tokenizeT_concat_space 8 220 _ _ _ _ wb_p138_tok wb_s139_tok
def wb_s137 : List Char := wb_p137 ++ ' ' :: wb_s138
def wb_st137 : List String := wb_t137 ++ wb_st138
theorem wb_s137_tok : tokenizeT 232 wb_s137 = some wb_st137 :=
  tokenizeT_concat_space 2 229 _ _ _ _ wb_p137_tok wb_s138_tok
def wb_s136 : List Char := wb_p136 ++ ' ' :: wb_s137
def wb_st136 : List String := wb_t136 ++ wb_st137
theorem wb_s136_tok : tokenizeT 239 wb_s136 = some wb_st136 :=
  tokenizeT_concat_space 6 232 _ _ _ _ wb_p136_tok wb_s137_tok
def wb_s135 : List Char := wb_p135 ++ ' ' :: wb_s136
def wb_st135 : List String := wb_t135 ++ wb_st136
theorem wb_s135_tok : tokenizeT 245 wb_s135 = some wb_st135 :=
  tokenizeT_concat_space 5 239 _ _ _ _ wb_p135_tok wb_s136_tok
def wb_s134 : List Char := wb_p134 ++ ' ' :: wb_s135
def wb_st134 : List String := wb_t134 ++ wb_st135
theorem wb_s134_tok : tokenizeT 248 wb_s134 = some wb_st134 :=
  tokenizeT_concat_space 2 245 _ _ _ _ wb_p134_tok wb_s135_tok
def wb_s133 : List Char := wb_p133 ++ ' ' :: wb_s134
def wb_st133 : List String := wb_t133 ++ wb_st134
theorem wb_s133_tok : tokenizeT 257 wb_s133 = some wb_st133 :=
  tokenizeT_concat_space 8 248 _ _ _ _ wb_p133_tok wb_s134_tok
def wb_s132 : List Char := wb_p132 ++ ' ' :: wb_s133
def wb_st132 : List String := wb_t132 ++ wb_st133
theorem wb_s132_tok : tokenizeT 263 wb_s132 = some wb_st132 :=
  tokenizeT_concat_space 5 257 _ _ _ _ wb_p132_tok wb_s133_tok
def wb_s131 : List Char := wb_p131 ++ ' ' :: wb_s132
def wb_st131 : List String := wb_t131 ++ wb_st132
theorem wb_s131_tok : tokenizeT 270 wb_s131 = some wb_st131 :=
  tokenizeT_concat_space 6 263 _ _ _ _ wb_p131_tok wb_s132_tok
def wb_s130 : List Char := wb_p130 ++ ' ' :: wb_s131
def wb_st130 : List String := wb_t130 ++ wb_st131
theorem wb_s130_tok : tokenizeT 275 wb_s130 = some wb_st130 :=
  tokenizeT_concat_space 4 270 _ _ _ _ wb_p130_tok wb_s131_tok
def wb_s129 : List Char := wb_p129 ++ ' ' :: wb_s130
def wb_st129 : List String := wb_t129 ++ wb_st130
theorem wb_s129_tok : tokenizeT 284 wb_s129 = some wb_st129 :=
  tokenizeT_concat_space 8 275 _ _ _ _ wb_p129_tok wb_s130_tok
def wb_s128 : List Char := wb_p128 ++ ' ' :: wb_s129
def wb_st128 : List String := wb_t128 ++ wb_st129
theorem wb_s128_tok : tokenizeT 289 wb_s128 = some wb_st128 :=
  tokenizeT_concat_space 4 284 _ _ _ _ wb_p128_tok wb_s129_tok
def wb_s127 : List Char := wb_p127 ++ ' ' :: wb_s128
def wb_st127 : List String := wb_t127 ++ wb_st128
theorem wb_s127_tok : tokenizeT 292 wb_s127 = some wb_st127 :=
  tokenizeT_concat_space 2 289 _ _ _ _ wb_p127_tok wb_s128_tok
def wb_s126 : List Char := wb_p126 ++ ' ' :: wb_s127
def wb_st126 : List String := wb_t126 ++ wb_st127
theorem wb_s126_tok : tokenizeT 299 wb_s126 = some wb_st126 :=
  tokenizeT_concat_space 6 292 _ _ _ _ wb_p126_tok wb_s127_tok
def wb_s125 : List Char := wb_p125 ++ ' ' :: wb_s126
def wb_st125 : List String := wb_t125 ++ wb_st126
theorem wb_s125_tok : tokenizeT 303 wb_s125 = some wb_st125 :=
  tokenizeT_concat_space 3 299 _ _ _ _ wb_p125_tok wb_s126_tok
def wb_s124 : List Char := wb_p124 ++ ' ' :: wb_s125
def wb_st124 : List String := wb_t124 ++ wb_st125
theorem wb_s124_tok : tokenizeT 308 wb_s124 = some wb_st124 :=
  tokenizeT_concat_space 4 303 _ _ _ _ wb_p124_tok wb_s125_tok
def wb_s123 : List Char := wb_p123 ++ ' ' :: wb_s124
def wb_st123 : List String := wb_t123 ++ wb_st124
theorem wb_s123_tok : tokenizeT 314 wb_s123 = some wb_st123 :=
  tokenizeT_concat_space 5 308 _ _ _ _ wb_p123_tok wb_s124_tok
def wb_s122 : List Char := wb_p122 ++ ' ' :: wb_s123
def wb_st122 : List String := wb_t122 ++ wb_st123
theorem wb_s122_tok : tokenizeT 321 wb_s122 = some wb_st122 :=
  tokenizeT_concat_space 6 314 _ _ _ _ wb_p122_tok wb_s123_tok
def wb_s121 : List Char := wb_p121 ++ ' ' :: wb_s122
def wb_st121 : List String := wb_t121 ++ wb_st122
theorem wb_s121_tok : tokenizeT 327 wb_s121 = some wb_st121 :=
  tokenizeT_concat_space 5 321 _ _ _ _ wb_p121_tok wb_s122_tok
def wb_s120 : List Char := wb_p120 ++ ' ' :: wb_s121
def wb_st120 : List String := wb_t120 ++ wb_st121
theorem wb_s120_tok : tokenizeT 334 wb_s120 = some wb_st120 :=
  tokenizeT_concat_space 6 327 _ _ _ _ wb_p120_tok wb_s121_tok
def wb_s119 : List Char := wb_p119 ++ ' ' :: wb_s120
def wb_st119 : List String := wb_t119 ++ wb_st120
theorem wb_s119_tok : tokenizeT 338 wb_s119 = some wb_st119 :=
  tokenizeT_concat_space 3 334 _ _ _ _ wb_p119_tok wb_s120_tok
def wb_s118 : List Char := wb_p118 ++ ' ' :: wb_s119
def wb_st118 : List String := wb_t118 ++ wb_st119
theorem wb_s118_tok : tokenizeT 351 wb_s118 = some wb_st118 :=
  tokenizeT_concat_space 12 338 _ _ _ _ wb_p118_tok wb_s119_tok
def wb_s117 : List Char := wb_p117 ++ ' ' :: wb_s118
def wb_st117 : List String := wb_t117 ++ wb_st118
theorem wb_s117_tok : tokenizeT 354 wb_s117 = some wb_st117 :=
  tokenizeT_concat_space 2 351 _ _ _ _ wb_p117_tok wb_s118_tok
def wb_s116 : List Char := wb_p116 ++ ' ' :: wb_s117
def wb_st116 : List String := wb_t116 ++ wb_st117
theorem wb_s116_tok : tokenizeT 365 wb_s116 = some wb_st116 :=
  tokenizeT_concat_space 10 354 _ _ _ _ wb_p116_tok wb_s117_tok
def wb_s115 : List Char := wb_p115 ++ ' ' :: wb_s116
def wb_st115 : List String := wb_t115 ++ wb_st116
theorem wb_s115_tok : tokenizeT 379 wb_s115 = some wb_st115 :=
  tokenizeT_concat_space 13 365 _ _ _ _ wb_p115_tok wb_s116_tok
def wb_s114 : List Char := wb_p114 ++ ' ' :: wb_s115
def wb_st114 : List String := wb_t114 ++ wb_st115
theorem wb_s114_tok : tokenizeT 382 wb_s114 = some wb_st114 :=
  tokenizeT_concat_space 2 379 _ _ _ _ wb_p114_tok wb_s115_tok
def wb_s113 : List Char := wb_p113 ++ ' ' :: wb_s114
def wb_st113 : List String := wb_t113 ++ wb_st114
theorem wb_s113_tok : tokenizeT 388 wb_s113 = some wb_st113 :=
  tokenizeT_concat_space 5 382 _ _ _ _ wb_p113_tok wb_s114_tok
def wb_s112 : List Char := wb_p112 ++ ' ' :: wb_s113
def wb_st112 : List String := wb_t112 ++ wb_st113
theorem wb_s112_tok : tokenizeT 394 wb_s112 = some wb_st112 :=
  tokenizeT_concat_space 5 388 _ _ _ _ wb_p112_tok wb_s113_tok
def wb_s111 : List Char := wb_p111 ++ ' ' :: wb_s112
def wb_st111 : List String := wb_t111 ++ wb_st112
theorem wb_s111_tok : tokenizeT 400 wb_s111 = some wb_st111 :=
  tokenizeT_concat_space 5 394 _ _ _ _ wb_p111_tok wb_s112_tok
def wb_s110 : List Char := wb_p110 ++ ' ' :: wb_s111
def wb_st110 : List String := wb_t110 ++ wb_st111
theorem wb_s110_tok : tokenizeT 406 wb_s110 = some wb_st110 :=
  tokenizeT_concat_space 5 400 _ _ _ _ wb_p110_tok wb_s111_tok
def wb_s109 : List Char := wb_p109 ++ ' ' :: wb_s110
def wb_st109 : List String := wb_t109 ++ wb_st110
theorem wb_s109_tok : tokenizeT 415 wb_s109 = some wb_st109 :=
  tokenizeT_concat_space 8 406 _ _ _ _ wb_p109_tok wb_s110_tok
def wb_s108 : List Char := wb_p108 ++ ' ' :: wb_s109
def wb_st108 : List String := wb_t108 ++ wb_st109
theorem wb_s108_tok : tokenizeT 422 wb_s108 = some wb_st108 :=
  tokenizeT_concat_space 6 415 _ _ _ _ wb_p108_tok wb_s109_tok
def wb_s107 : List Char := wb_p107 ++ ' ' :: wb_s108
def wb_st107 : List String := wb_t107 ++ wb_st108
theorem wb_s107_tok : tokenizeT 430 wb_s107 = some wb_st107 :=
  tokenizeT_concat_space 7 422 _ _ _ _ wb_p107_tok wb_s108_tok
def wb_s106 : List Char := wb_p106 ++ ' ' :: wb_s107
def wb_st106 : List String := wb_t106 ++ wb_st107
theorem wb_s106_tok : tokenizeT 433 wb_s106 = some wb_st106 :=
  tokenizeT_concat_space 2 430 _ _ _ _ wb_p106_tok wb_s107_tok
def wb_s105 : List Char := wb_p105 ++ ' ' :: wb_s106
def wb_st105 : List String := wb_t105 ++ wb_st106
theorem wb_s105_tok : tokenizeT 444 wb_s105 = some wb_st105 :=
  tokenizeT_concat_space 10 433 _ _ _ _ wb_p105_tok wb_s106_tok
def wb_s104 : List Char := wb_p104 ++ ' ' :: wb_s105
def wb_st104 : List String := wb_t104 ++ wb_st105
theorem wb_s104_tok : tokenizeT 453 wb_s104 = some wb_st104 :=
  tokenizeT_concat_space 8 444 _ _ _ _ wb_p104_tok wb_s105_tok
def wb_s103 : List Char := wb_p103 ++ ' ' :: wb_s104
def wb_st103 : List String := wb_t103 ++ wb_st104
theorem wb_s103_tok : tokenizeT 456 wb_s103 = some wb_st103 :=
  tokenizeT_concat_space 2 453 _ _ _ _ wb_p103_tok wb_s104_tok
def wb_s102 : List Char := wb_p102 ++ ' ' :: wb_s103
def wb_st102 : List String := wb_t102 ++ wb_st103
theorem wb_s102_tok : tokenizeT 462 wb_s102 = some wb_st102 :=
  tokenizeT_concat_space 5 456 _ _ _ _ wb_p102_tok wb_s103_tok
def wb_s101 : List Char := wb_p101 ++ ' ' :: wb_s102
def wb_st101 : List String := wb_t101 ++ wb_st102
theorem wb_s101_tok : tokenizeT 468 wb_s101 = some wb_st101 :=
  tokenizeT_concat_space 5 462 _ _ _ _ wb_p101_tok wb_s102_tok
def wb_s100 : List Char := wb_p100 ++ ' ' :: wb_s101
def wb_st100 : List String := wb_t100 ++ wb_st101
theorem wb_s100_tok : tokenizeT 474 wb_s100 = some wb_st100 :=
  tokenizeT_concat_space 5 468 _ _ _ _ wb_p100_tok wb_s101_tok
def wb_s99 : List Char := wb_p99 ++ ' ' :: wb_s100
def wb_st99 : List String := wb_t99 ++ wb_st100
theorem wb_s99_tok : tokenizeT 480 wb_s99 = some wb_st99 :=
  tokenizeT_concat_space 5 474 _ _ _ _ wb_p99_tok wb_s100_tok
def wb_s98 : List Char := wb_p98 ++ ' ' :: wb_s99
def wb_st98 : List String := wb_t98 ++ wb_st99
theorem wb_s98_tok : tokenizeT 491 wb_s98 = some wb_st98 :=
  tokenizeT_concat_space 10 480 _ _ _ _ wb_p98_tok wb_s99_tok
def wb_s97 : List Char := wb_p97 ++ ' ' :: wb_s98
def wb_st97 : List String := wb_t97 ++ wb_st98
theorem wb_s97_tok : tokenizeT 510 wb_s97 = some wb_st97 :=
  tokenizeT_concat_space 18 491 _ _ _ _ wb_p97_tok wb_s98_tok
def wb_s96 : List Char := wb_p96 ++ ' ' :: wb_s97
def wb_st96 : List String := wb_t96 ++ wb_st97
theorem wb_s96_tok : tokenizeT 519 wb_s96 = some wb_st96 :=
  tokenizeT_concat_space 8 510 _ _ _ _ wb_p96_tok wb_s97_tok
def wb_s95 : List Char := wb_p95 ++ ' ' :: wb_s96
def wb_st95 : List String := wb_t95 ++ wb_st96
theorem wb_s95_tok : tokenizeT 525 wb_s95 = some wb_st95 :=
  tokenizeT_concat_space 5 519 _ _ _ _ wb_p95_tok wb_s96_tok
def wb_s94 : List Char := wb_p94 ++ ' ' :: wb_s95
def wb_st94 : List String := wb_t94 ++ wb_st95
theorem wb_s94_tok : tokenizeT 532 wb_s94 = some wb_st94 :=
  tokenizeT_concat_space 6 525 _ _ _ _ wb_p94_tok wb_s95_tok
def wb_s93 : List Char := wb_p93 ++ ' ' :: wb_s94
def wb_st93 : List String := wb_t93 ++ wb_st94
theorem wb_s93_tok : tokenizeT 542 wb_s93 = some wb_st93 :=
  tokenizeT_concat_space 9 532 _ _ _ _ wb_p93_tok wb_s94_tok
def wb_s92 : List Char := wb_p92 ++ ' ' :: wb_s93
def wb_st92 : List String := wb_t92 ++ wb_st93
theorem wb_s92_tok : tokenizeT 545 wb_s92 = some wb_st92 :=
  tokenizeT_concat_space 2 542 _ _ _ _ wb_p92_tok wb_s93_tok
def wb_s91 : List Char := wb_p91 ++ ' ' :: wb_s92
def wb_st91 : List String := wb_t91 ++ wb_st92
theorem wb_s91_tok : tokenizeT 554 wb_s91 = some wb_st91 :=
  tokenizeT_concat_space 8 545 _ _ _ _ wb_p91_tok wb_s92_tok
def wb_s90 : List Char := wb_p90 ++ ' ' :: wb_s91
def wb_st90 : List String := wb_t90 ++ wb_st91
theorem wb_s90_tok : tokenizeT 563 wb_s90 = some wb_st90 :=
  tokenizeT_concat_space 8 554 _ _ _ _ wb_p90_tok wb_s91_tok
def wb_s89 : List Char := wb_p89 ++ ' ' :: wb_s90
def wb_st89 : List String := wb_t89 ++ wb_st90
theorem wb_s89_tok : tokenizeT 566 wb_s89 = some wb_st89 :=
  tokenizeT_concat_space 2 563 _ _ _ _ wb_p89_tok wb_s90_tok
def wb_s88 : List Char := wb_p88 ++ ' ' :: wb_s89
def wb_st88 : List String := wb_t88 ++ wb_st89
theorem wb_s88_tok : tokenizeT 572 wb_s88 = some wb_st88 :=
  tokenizeT_concat_space 5 566 _ _ _ _ wb_p88_tok wb_s89_tok
def wb_s87 : List Char := wb_p87 ++ ' ' :: wb_s88
def wb_st87 : List String := wb_t87 ++ wb_st88
theorem wb_s87_tok : tokenizeT 578 wb_s87 = some wb_st87 :=
  tokenizeT_concat_space 5 572 _ _ _ _ wb_p87_tok wb_s88_tok
def wb_s86 : List Char := wb_p86 ++ ' ' :: wb_s87
def wb_st86 : List String := wb_t86 ++ wb_st87
theorem wb_s86_tok : tokenizeT 584 wb_s86 = some wb_st86 :=
  tokenizeT_concat_space 5 578 _ _ _ _ wb_p86_tok wb_s87_tok
def wb_s85 : List Char := wb_p85 ++ ' ' :: wb_s86
def wb_st85 : List String := wb_t85 ++ wb_st86
theorem wb_s85_tok : tokenizeT 590 wb_s85 = some wb_st85 :=
  tokenizeT_concat_space 5 584 _ _ _ _ wb_p85_tok wb_s86_tok
def wb_s84 : List Char := wb_p84 ++ ' ' :: wb_s85
def wb_st84 : List String := wb_t84 ++ wb_st85
theorem wb_s84_tok : tokenizeT 598 wb_s84 = some wb_st84 :=
  tokenizeT_concat_space 7 590 _ _ _ _ wb_p84_tok wb_s85_tok
def wb_s83 : List Char := wb_p83 ++ ' ' :: wb_s84
def wb_st83 : List String := wb_t83 ++ wb_st84
theorem wb_s83_tok : tokenizeT 603 wb_s83 = some wb_st83 :=
  tokenizeT_concat_space 4 598 _ _ _ _ wb_p83_tok wb_s84_tok
def wb_s82 : List Char := wb_p82 ++ ' ' :: wb_s83
def wb_st82 : List String := wb_t82 ++ wb_st83
theorem wb_s82_tok : tokenizeT 610 wb_s82 = some wb_st82 :=
  tokenizeT_concat_space 6 603 _ _ _ _ wb_p82_tok wb_s83_tok
def wb_s81 : List Char := wb_p81 ++ ' ' :: wb_s82
def wb_st81 : List String := wb_t81 ++ wb_st82
theorem wb_s81_tok : tokenizeT 616 wb_s81 = some wb_st81 :=
  tokenizeT_concat_space 5 610 _ _ _ _ wb_p81_tok wb_s82_tok
def wb_s80 : List Char := wb_p80 ++ ' ' :: wb_s81
def wb_st80 : List String := wb_t80 ++ wb_st81
theorem wb_s80_tok : tokenizeT 623 wb_s80 = some wb_st80 :=
  tokenizeT_concat_space 6 616 _ _ _ _ wb_p80_tok wb_s81_tok
def wb_s79 : List Char := wb_p79 ++ ' ' :: wb_s80
def wb_st79 : List String := wb_t79 ++ wb_st80
theorem wb_s79_tok : tokenizeT 631 wb_s79 = some wb_st79 :=
  tokenizeT_concat_space 7 623 _ _ _ _ wb_p79_tok wb_s80_tok
def wb_s78 : List Char := wb_p78 ++ ' ' :: wb_s79
def wb_st78 : List String := wb_t78 ++ wb_st79
theorem wb_s78_tok : tokenizeT 636 wb_s78 = some wb_st78 :=
  tokenizeT_concat_space 4 631 _ _ _ _ wb_p78_tok wb_s79_tok
def wb_s77 : List Char := wb_p77 ++ ' ' :: wb_s78
def wb_st77 : List String := wb_t77 ++ wb_st78
theorem wb_s77_tok : tokenizeT 645 wb_s77 = some wb_st77 :=
  tokenizeT_concat_space 8 636 _ _ _ _ wb_p77_tok wb_s78_tok
def wb_s76 : List Char := wb_p76 ++ ' ' :: wb_s77
def wb_st76 : List String := wb_t76 ++ wb_st77
theorem wb_s76_tok : tokenizeT 653 wb_s76 = some wb_st76 :=
  tokenizeT_concat_space 7 645 _ _ _ _ wb_p76_tok wb_s77_tok
def wb_s75 : List Char := wb_p75 ++ ' ' :: wb_s76
def wb_st75 : List String := wb_t75 ++ wb_st76
theorem wb_s75_tok : tokenizeT 656 wb_s75 = some wb_st75 :=
  tokenizeT_concat_space 2 653 _ _ _ _ wb_p75_tok wb_s76_tok
def wb_s74 : List Char := wb_p74 ++ ' ' :: wb_s75
def wb_st74 : List String := wb_t74 ++ wb_st75
theorem wb_s74_tok : tokenizeT 662 wb_s74 = some wb_st74 :=
  tokenizeT_concat_space 5 656 _ _ _ _ wb_p74_tok wb_s75_tok
def wb_s73 : List Char := wb_p73 ++ ' ' :: wb_s74
def wb_st73 : List String := wb_t73 ++ wb_st74
theorem wb_s73_tok : tokenizeT 668 wb_s73 = some wb_st73 :=
  tokenizeT_concat_space 5 662 _ _ _ _ wb_p73_tok wb_s74_tok
def wb_s72 : List Char := wb_p72 ++ ' ' :: wb_s73
def wb_st72 : List String := wb_t72 ++ wb_st73
theorem wb_s72_tok : tokenizeT 674 wb_s72 = some wb_st72 :=
  tokenizeT_concat_space 5 668 _ _ _ _ wb_p72_tok wb_s73_tok
def wb_s71 : List Char := wb_p71 ++ ' ' :: wb_s72
def wb_st71 : List String := wb_t71 ++ wb_st72
theorem wb_s71_tok : tokenizeT 680 wb_s71 = some wb_st71 :=
  tokenizeT_concat_space 5 674 _ _ _ _ wb_p71_tok wb_s72_tok
def wb_s70 : List Char := wb_p70 ++ ' ' :: wb_s71
def wb_st70 : List String := wb_t70 ++ wb_st71
theorem wb_s70_tok : tokenizeT 688 wb_s70 = some wb_st70 :=
  tokenizeT_concat_space 7 680 _ _ _ _ wb_p70_tok wb_s71_tok
def wb_s69 : List Char := wb_p69 ++ ' ' :: wb_s70
def wb_st69 : List String := wb_t69 ++ wb_st70
theorem wb_s69_tok : tokenizeT 708 wb_s69 = some wb_st69 :=
  tokenizeT_concat_space 19 688 _ _ _ _ wb_p69_tok wb_s70_tok
def wb_s68 : List Char := wb_p68 ++ ' ' :: wb_s69
def wb_st68 : List String := wb_t68 ++ wb_st69
theorem wb_s68_tok : tokenizeT 715 wb_s68 = some wb_st68 :=
  tokenizeT_concat_space 6 708 _ _ _ _ wb_p68_tok wb_s69_tok
def wb_s67 : List Char := wb_p67 ++ ' ' :: wb_s68
def wb_st67 : List String := wb_t67 ++ wb_st68
theorem wb_s67_tok : tokenizeT 723 wb_s67 = some wb_st67 :=
  tokenizeT_concat_space 7 715 _ _ _ _ wb_p67_tok wb_s68_tok
def wb_s66 : List Char := wb_p66 ++ ' ' :: wb_s67
def wb_st66 : List String := wb_t66 ++ wb_st67
theorem wb_s66_tok : tokenizeT 729 wb_s66 = some wb_st66 :=
  tokenizeT_concat_space 5 723 _ _ _ _ wb_p66_tok wb_s67_tok
def wb_s65 : List Char := wb_p65 ++ ' ' :: wb_s66
def wb_st65 : List String := wb_t65 ++ wb_st66
theorem wb_s65_tok : tokenizeT 737 wb_s65 = some wb_st65 :=
  tokenizeT_concat_space 7 729 _ _ _ _ wb_p65_tok wb_s66_tok
def wb_s64 : List Char := wb_p64 ++ ' ' :: wb_s65
def wb_st64 : List String := wb_t64 ++ wb_st65
theorem wb_s64_tok : tokenizeT 740 wb_s64 = some wb_st64 :=
  tokenizeT_concat_space 2 737 _ _ _ _ wb_p64_tok wb_s65_tok
def wb_s63 : List Char := wb_p63 ++ ' ' :: wb_s64
def wb_st63 : List String := wb_t63 ++ wb_st64
theorem wb_s63_tok : tokenizeT 747 wb_s63 = some wb_st63 :=
  tokenizeT_concat_space 6 740 _ _ _ _ wb_p63_tok wb_s64_tok
def wb_s62 : List Char := wb_p62 ++ ' ' :: wb_s63
def wb_st62 : List String := wb_t62 ++ wb_st63
theorem wb_s62_tok : tokenizeT 752 wb_s62 = some wb_st62 :=
  tokenizeT_concat_space 4 747 _ _ _ _ wb_p62_tok wb_s63_tok
def wb_s61 : List Char := wb_p61 ++ ' ' :: wb_s62
def wb_st61 : List String := wb_t61 ++ wb_st62
theorem wb_s61_tok : tokenizeT 757 wb_s61 = some wb_st61 :=
  tokenizeT_concat_space 4 752 _ _ _ _ wb_p61_tok wb_s62_tok
def wb_s60 : List Char := wb_p60 ++ ' ' :: wb_s61
def wb_st60 : List String := wb_t60 ++ wb_st61
theorem wb_s60_tok : tokenizeT 763 wb_s60 = some wb_st60 :=
  tokenizeT_concat_space 5 757 _ _ _ _ wb_p60_tok wb_s61_tok
def wb_s59 : List Char := wb_p59 ++ ' ' :: wb_s60
def wb_st59 : List String := wb_t59 ++ wb_st60
theorem wb_s59_tok : tokenizeT 766 wb_s59 = some wb_st59 :=
  tokenizeT_concat_space 2 763 _ _ _ _ wb_p59_tok wb_s60_tok
def wb_s58 : List Char := wb_p58 ++ ' ' :: wb_s59
def wb_st58 : List String := wb_t58 ++ wb_st59
theorem wb_s58_tok : tokenizeT 772 wb_s58 = some wb_st58 :=
  tokenizeT_concat_space 5 766 _ _ _ _ wb_p58_tok wb_s59_tok
def wb_s57 : List Char := wb_p57 ++ ' ' :: wb_s58
def wb_st57 : List String := wb_t57 ++ wb_st58
theorem wb_s57_tok : tokenizeT 778 wb_s57 = some wb_st57 :=
  tokenizeT_concat_space 5 772 _ _ _ _ wb_p57_tok wb_s58_tok
def wb_s56 : List Char := wb_p56 ++ ' ' :: wb_s57
def wb_st56 : List String := wb_t56 ++ wb_st57
theorem wb_s56_tok : tokenizeT 784 wb_s56 = some wb_st56 :=
  tokenizeT_concat_space 5 778 _ _ _ _ wb_p56_tok wb_s57_tok
def wb_s55 : List Char := wb_p55 ++ ' ' :: wb_s56
def wb_st55 : List String := wb_t55 ++ wb_st56
theorem wb_s55_tok : tokenizeT 790 wb_s55 = some wb_st55 :=
  tokenizeT_concat_space 5 784 _ _ _ _ wb_p55_tok wb_s56_tok
def wb_s54 : List Char := wb_p54 ++ ' ' :: wb_s55
def wb_st54 : List String := wb_t54 ++ wb_st55
theorem wb_s54_tok : tokenizeT 798 wb_s54 = some wb_st54 :=
  tokenizeT_concat_space 7 790 _ _ _ _ wb_p54_tok wb_s55_tok
def wb_s53 : List Char := wb_p53 ++ ' ' :: wb_s54
def wb_st53 : List String := wb_t53 ++ wb_st54
theorem wb_s53_tok : tokenizeT 801 wb_s53 = some wb_st53 :=
  tokenizeT_concat_space 2 798 _ _ _ _ wb_p53_tok wb_s54_tok
def wb_s52 : List Char := wb_p52 ++ ' ' :: wb_s53
def wb_st52 : List String := wb_t52 ++ wb_st53
theorem wb_s52_tok : tokenizeT 810 wb_s52 = some wb_st52 :=
  tokenizeT_concat_space 8 801 _ _ _ _ wb_p52_tok wb_s53_tok
def wb_s51 : List Char := wb_p51 ++ ' ' :: wb_s52
def wb_st51 : List String := wb_t51 ++ wb_st52
theorem wb_s51_tok : tokenizeT 816 wb_s51 = some wb_st51 :=
  tokenizeT_concat_space 5 810 _ _ _ _ wb_p51_tok wb_s52_tok
def wb_s50 : List Char := wb_p50 ++ ' ' :: wb_s51
def wb_st50 : List String := wb_t50 ++ wb_st51
theorem wb_s50_tok : tokenizeT 819 wb_s50 = some wb_st50 :=
  tokenizeT_concat_space 2 816 _ _ _ _ wb_p50_tok wb_s51_tok
def wb_s49 : List Char := wb_p49 ++ ' ' :: wb_s50
def wb_st49 : List String := wb_t49 ++ wb_st50
theorem wb_s49_tok : tokenizeT 825 wb_s49 = some wb_st49 :=
  tokenizeT_concat_space 5 819 _ _ _ _ wb_p49_tok wb_s50_tok
def wb_s48 : List Char := wb_p48 ++ ' ' :: wb_s49
def wb_st48 : List String := wb_t48 ++ wb_st49
theorem wb_s48_tok : tokenizeT 831 wb_s48 = some wb_st48 :=
  tokenizeT_concat_space 5 825 _ _ _ _ wb_p48_tok wb_s49_tok
def wb_s47 : List Char := wb_p47 ++ ' ' :: wb_s48
def wb_st47 : List String := wb_t47 ++ wb_st48
theorem wb_s47_tok : tokenizeT 837 wb_s47 = some wb_st47 :=
  tokenizeT_concat_space 5 831 _ _ _ _ wb_p47_tok wb_s48_tok
def wb_s46 : List Char := wb_p46 ++ ' ' :: wb_s47
def wb_st46 : List String := wb_t46 ++ wb_st47
theorem wb_s46_tok : tokenizeT 843 wb_s46 = some wb_st46 :=
  tokenizeT_concat_space 5 837 _ _ _ _ wb_p46_tok wb_s47_tok
def wb_s45 : List Char := wb_p45 ++ ' ' :: wb_s46
def wb_st45 : List String := wb_t45 ++ wb_st46
theorem wb_s45_tok : tokenizeT 851 wb_s45 = some wb_st45 :=
  tokenizeT_concat_space 7 843 _ _ _ _ wb_p45_tok wb_s46_tok
def wb_s44 : List Char := wb_p44 ++ ' ' :: wb_s45
def wb_st44 : List String := wb_t44 ++ wb_st45
theorem wb_s44_tok : tokenizeT 871 wb_s44 = some wb_st44 :=
  tokenizeT_concat_space 19 851 _ _ _ _ wb_p44_tok wb_s45_tok
def wb_s43 : List Char := wb_p43 ++ ' ' :: wb_s44
def wb_st43 : List String := wb_t43 ++ wb_st44
theorem wb_s43_tok : tokenizeT 878 wb_s43 = some wb_st43 :=
  tokenizeT_concat_space 6 871 _ _ _ _ wb_p43_tok wb_s44_tok
def wb_s42 : List Char := wb_p42 ++ ' ' :: wb_s43
def wb_st42 : List String := wb_t42 ++ wb_st43
theorem wb_s42_tok : tokenizeT 886 wb_s42 = some wb_st42 :=
  tokenizeT_concat_space 7 878 _ _ _ _ wb_p42_tok wb_s43_tok
def wb_s41 : List Char := wb_p41 ++ ' ' :: wb_s42
def wb_st41 : List String := wb_t41 ++ wb_st42
theorem wb_s41_tok : tokenizeT 892 wb_s41 = some wb_st41 :=
  tokenizeT_concat_space 5 886 _ _ _ _ wb_p41_tok wb_s42_tok
def wb_s40 : List Char := wb_p40 ++ ' ' :: wb_s41
def wb_st40 : List String := wb_t40 ++ wb_st41
theorem wb_s40_tok : tokenizeT 899 wb_s40 = some wb_st40 :=
  tokenizeT_concat_space 6 892 _ _ _ _ wb_p40_tok wb_s41_tok
def wb_s39 : List Char := wb_p39 ++ ' ' :: wb_s40
def wb_st39 : List String := wb_t39 ++ wb_st40
theorem wb_s39_tok : tokenizeT 902 wb_s39 = some wb_st39 :=
  tokenizeT_concat_space 2 899 _ _ _ _ wb_p39_tok wb_s40_tok
def wb_s38 : List Char := wb_p38 ++ ' ' :: wb_s39
def wb_st38 : List String := wb_t38 ++ wb_st39
theorem wb_s38_tok : tokenizeT 909 wb_s38 = some wb_st38 :=
  tokenizeT_concat_space 6 902 _ _ _ _ wb_p38_tok wb_s39_tok
def wb_s37 : List Char := wb_p37 ++ ' ' :: wb_s38
def wb_st37 : List String := wb_t37 ++ wb_st38
theorem wb_s37_tok : tokenizeT 914 wb_s37 = some wb_st37 :=
  tokenizeT_concat_space 4 909 _ _ _ _ wb_p37_tok wb_s38_tok
def wb_s36 : List Char := wb_p36 ++ ' ' :: wb_s37
def wb_st36 : List String := wb_t36 ++ wb_st37
theorem wb_s36_tok : tokenizeT 919 wb_s36 = some wb_st36 :=
  tokenizeT_concat_space 4 914 _ _ _ _ wb_p36_tok wb_s37_tok
def wb_s35 : List Char := wb_p35 ++ ' ' :: wb_s36
def wb_st35 : List String := wb_t35 ++ wb_st36
theorem wb_s35_tok : tokenizeT 925 wb_s35 = some wb_st35 :=
  tokenizeT_concat_space 5 919 _ _ _ _ wb_p35_tok wb_s36_tok
def wb_s34 : List Char := wb_p34 ++ ' ' :: wb_s35
def wb_st34 : List String := wb_t34 ++ wb_st35
theorem wb_s34_tok : tokenizeT 928 wb_s34 = some wb_st34 :=
  tokenizeT_concat_space 2 925 _ _ _ _ wb_p34_tok wb_s35_tok
def wb_s33 : List Char := wb_p33 ++ ' ' :: wb_s34
def wb_st33 : List String := wb_t33 ++ wb_st34
theorem wb_s33_tok : tokenizeT 933 wb_s33 = some wb_st33 :=
  tokenizeT_concat_space 4 928 _ _ _ _ wb_p33_tok wb_s34_tok
def wb_s32 : List Char := wb_p32 ++ ' ' :: wb_s33
def wb_st32 : List String := wb_t32 ++ wb_st33
theorem wb_s32_tok : tokenizeT 939 wb_s32 = some wb_st32 :=
  tokenizeT_concat_space 5 933 _ _ _ _ wb_p32_tok wb_s33_tok
def wb_s31 : List Char := wb_p31 ++ ' ' :: wb_s32
def wb_st31 : List String := wb_t31 ++ wb_st32
theorem wb_s31_tok : tokenizeT 945 wb_s31 = some wb_st31 :=
  tokenizeT_concat_space 5 939 _ _ _ _ wb_p31_tok wb_s32_tok
def wb_s30 : List Char := wb_p30 ++ ' ' :: wb_s31
def wb_st30 : List String := wb_t30 ++ wb_st31
theorem wb_s30_tok : tokenizeT 951 wb_s30 = some wb_st30 :=
  tokenizeT_concat_space 5 945 _ _ _ _ wb_p30_tok wb_s31_tok
def wb_s29 : List Char := wb_p29 ++ ' ' :: wb_s30
def wb_st29 : List String := wb_t29 ++ wb_st30
theorem wb_s29_tok : tokenizeT 958 wb_s29 = some wb_st29 :=
  tokenizeT_concat_space 6 951 _ _ _ _ wb_p29_tok wb_s30_tok
def wb_s28 : List Char := wb_p28 ++ ' ' :: wb_s29
def wb_st28 : List String := wb_t28 ++ wb_st29
theorem wb_s28_tok : tokenizeT 978 wb_s28 = some wb_st28 :=
  tokenizeT_concat_space 19 958 _ _ _ _ wb_p28_tok wb_s29_tok
def wb_s27 : List Char := wb_p27 ++ ' ' :: wb_s28
def wb_st27 : List String := wb_t27 ++ wb_st28
theorem wb_s27_tok : tokenizeT 985 wb_s27 = some wb_st27 :=
  tokenizeT_concat_space 6 978 _ _ _ _ wb_p27_tok wb_s28_tok
def wb_s26 : List Char := wb_p26 ++ ' ' :: wb_s27
def wb_st26 : List String := wb_t26 ++ wb_st27
theorem wb_s26_tok : tokenizeT 993 wb_s26 = some wb_st26 :=
  tokenizeT_concat_space 7 985 _ _ _ _ wb_p26_tok wb_s27_tok
def wb_s25 : List Char := wb_p25 ++ ' ' :: wb_s26
def wb_st25 : List String := wb_t25 ++ wb_st26
theorem wb_s25_tok : tokenizeT 999 wb_s25 = some wb_st25 :=
  tokenizeT_concat_space 5 993 _ _ _ _ wb_p25_tok wb_s26_tok
def wb_s24 : List Char := wb_p24 ++ ' ' :: wb_s25
def wb_st24 : List String := wb_t24 ++ wb_st25
theorem wb_s24_tok : tokenizeT 1004 wb_s24 = some wb_st24 :=
  tokenizeT_concat_space 4 999 _ _ _ _ wb_p24_tok wb_s25_tok
def wb_s23 : List Char := wb_p23 ++ ' ' :: wb_s24
def wb_st23 : List String := wb_t23 ++ wb_st24
theorem wb_s23_tok : tokenizeT 1009 wb_s23 = some wb_st23 :=
  tokenizeT_concat_space 4 1004 _ _ _ _ wb_p23_tok wb_s24_tok
def wb_s22 : List Char := wb_p22 ++ ' ' :: wb_s23
def wb_st22 : List String := wb_t22 ++ wb_st23
theorem wb_s22_tok : tokenizeT 1016 wb_s22 = some wb_st22 :=
  tokenizeT_concat_space 6 1009 _ _ _ _ wb_p22_tok wb_s23_tok
def wb_s21 : List Char := wb_p21 ++ ' ' :: wb_s22
def wb_st21 : List String := wb_t21 ++ wb_st22
theorem wb_s21_tok : tokenizeT 1021 wb_s21 = some wb_st21 :=
  tokenizeT_concat_space 4 1016 _ _ _ _ wb_p21_tok wb_s22_tok
def wb_s20 : List Char := wb_p20 ++ ' ' :: wb_s21
def wb_st20 : List String := wb_t20 ++ wb_st21
theorem wb_s20_tok : tokenizeT 1026 wb_s20 = some wb_st20 :=
  tokenizeT_concat_space 4 1021 _ _ _ _ wb_p20_tok wb_s21_tok
def wb_s19 : List Char := wb_p19 ++ ' ' :: wb_s20
def wb_st19 : List String := wb_t19 ++ wb_st20
theorem wb_s19_tok : tokenizeT 1032 wb_s19 = some wb_st19 :=
  tokenizeT_concat_space 5 1026 _ _ _ _ wb_p19_tok wb_s20_tok
def wb_s18 : List Char := wb_p18 ++ ' ' :: wb_s19
def wb_st18 : List String := wb_t18 ++ wb_st19
theorem wb_s18_tok : tokenizeT 1039 wb_s18 = some wb_st18 :=
  tokenizeT_concat_space 6 1032 _ _ _ _ wb_p18_tok wb_s19_tok
def wb_s17 : List Char := wb_p17 ++ ' ' :: wb_s18
def wb_st17 : List String := wb_t17 ++ wb_st18
theorem wb_s17_tok : tokenizeT 1045 wb_s17 = some wb_st17 :=
  tokenizeT_concat_space 5 1039 _ _ _ _ wb_p17_tok wb_s18_tok
def wb_s16 : List Char := wb_p16 ++ ' ' :: wb_s17
def wb_st16 : List String := wb_t16 ++ wb_st17
theorem wb_s16_tok : tokenizeT 1051 wb_s16 = some wb_st16 :=
  tokenizeT_concat_space 5 1045 _ _ _ _ wb_p16_tok wb_s17_tok
def wb_s15 : List Char := wb_p15 ++ ' ' :: wb_s16
def wb_st15 : List String := wb_t15 ++ wb_st16
theorem wb_s15_tok : tokenizeT 1081 wb_s15 = some wb_st15 :=
  tokenizeT_concat_space 29 1051 _ _ _ _ wb_p15_tok wb_s16_tok
def wb_s14 : List Char := wb_p14 ++ ' ' :: wb_s15
def wb_st14 : List String := wb_t14 ++ wb_st15
theorem wb_s14_tok : tokenizeT 1084 wb_s14 = some wb_st14 :=
  tokenizeT_concat_space 2 1081 _ _ _ _ wb_p14_tok wb_s15_tok
def wb_s13 : List Char := wb_p13 ++ ' ' :: wb_s14
def wb_st13 : List String := wb_t13 ++ wb_st14
theorem wb_s13_tok : tokenizeT 1093 wb_s13 = some wb_st13 :=
  tokenizeT_concat_space 8 1084 _ _ _ _ wb_p13_tok wb_s14_tok
def wb_s12 : List Char := wb_p12 ++ ' ' :: wb_s13
def wb_st12 : List String := wb_t12 ++ wb_st13
theorem wb_s12_tok : tokenizeT 1099 wb_s12 = some wb_st12 :=
  tokenizeT_concat_space 5 1093 _ _ _ _ wb_p12_tok wb_s13_tok
def wb_s11 : List Char := wb_p11 ++ ' ' :: wb_s12
def wb_st11 : List String := wb_t11 ++ wb_st12
theorem wb_s11_tok : tokenizeT 1106 wb_s11 = some wb_st11 :=
  tokenizeT_concat_space 6 1099 _ _ _ _ wb_p11_tok wb_s12_tok
def wb_s10 : List Char := wb_p10 ++ ' ' :: wb_s11
def wb_st10 : List String := wb_t10 ++ wb_st11
theorem wb_s10_tok : tokenizeT 1112 wb_s10 = some wb_st10 :=
  tokenizeT_concat_space 5 1106 _ _ _ _ wb_p10_tok wb_s11_tok
def wb_s9 : List Char := wb_p9 ++ ' ' :: wb_s10
def wb_st9 : List String := wb_t9 ++ wb_st10
theorem wb_s9_tok : tokenizeT 1118 wb_s9 = some wb_st9 :=
  tokenizeT_concat_space 5 1112 _ _ _ _ wb_p9_tok wb_s10_tok
def wb_s8 : List Char := wb_p8 ++ ' ' :: wb_s9
def wb_st8 : List String := wb_t8 ++ wb_st9
theorem wb_s8_tok : tokenizeT 1148 wb_s8 = some wb_st8 :=
  tokenizeT_concat_space 29 1118 _ _ _ _ wb_p8_tok wb_s9_tok
def wb_s7 : List Char := wb_p7 ++ ' ' :: wb_s8
def wb_st7 : List String := wb_t7 ++ wb_st8
theorem wb_s7_tok : tokenizeT 1153 wb_s7 = some wb_st7 :=
  tokenizeT_concat_space 4 1148 _ _ _ _ wb_p7_tok wb_s8_tok
def wb_s6 : List Char := wb_p6 ++ ' ' :: wb_s7
def wb_st6 : List String := wb_t6 ++ wb_st7
theorem wb_s6_tok : tokenizeT 1162 wb_s6 = some wb_st6 :=
  tokenizeT_concat_space 8 1153 _ _ _ _ wb_p6_tok wb_s7_tok
def wb_s5 : List Char := wb_p5 ++ ' ' :: wb_s6
def wb_st5 : List String := wb_t5 ++ wb_st6
theorem wb_s5_tok : tokenizeT 1168 wb_s5 = some wb_st5 :=
  tokenizeT_concat_space 5 1162 _ _ _ _ wb_p5_tok wb_s6_tok
def wb_s4 : List Char := wb_p4 ++ ' ' :: wb_s5
def wb_st4 : List String := wb_t4 ++ wb_st5
theorem wb_s4_tok : tokenizeT 1173 wb_s4 = some wb_st4 :=
  tokenizeT_concat_space 4 1168 _ _ _ _ wb_p4_tok wb_s5_tok
def wb_s3 : List Char := wb_p3 ++ ' ' :: wb_s4
def wb_st3 : List String := wb_t3 ++ wb_st4
theorem wb_s3_tok : tokenizeT 1179 wb_s3 = some wb_st3 :=
  tokenizeT_concat_space 5 1173 _ _ _ _ wb_p3_tok wb_s4_tok
def wb_s2 : List Char := wb_p2 ++ ' ' :: wb_s3
def wb_st2 : List String := wb_t2 ++ wb_st3
theorem wb_s2_tok : tokenizeT 1182 wb_s2 = some wb_st2 :=
  tokenizeT_concat_space 2 1179 _ _ _ _ wb_p2_tok wb_s3_tok
def wb_s1 : List Char := wb_p1 ++ ' ' :: wb_s2
def wb_st1 : List String := wb_t1 ++ wb_st2
theorem wb_s1_tok : tokenizeT 1191 wb_s1 = some wb_st1 :=
  tokenizeT_concat_space 8 1182 _ _ _ _ wb_p1_tok wb_s2_tok
def wb_s0 : List Char := wb_p0 ++ ' ' :: wb_s1
def wb_st0 : List String := wb_t0 ++ wb_st1
theorem wb_s0_tok : tokenizeT 1197 wb_s0 = some wb_st0 :=
  tokenizeT_concat_space 5 1191 _ _ _ _ wb_p0_tok wb_s1_tok
end CalculusTokenizeChars

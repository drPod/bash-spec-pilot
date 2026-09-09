// Lean compiler output
// Module: BufferRelay
// Imports: public import Init public meta import Init public import MemoryTransfer
#include <lean/lean.h>
#if defined(__clang__)
#pragma clang diagnostic ignored "-Wunused-parameter"
#pragma clang diagnostic ignored "-Wunused-label"
#elif defined(__GNUC__) && !defined(__CLANG__)
#pragma GCC diagnostic ignored "-Wunused-parameter"
#pragma GCC diagnostic ignored "-Wunused-label"
#pragma GCC diagnostic ignored "-Wunused-but-set-variable"
#endif
#ifdef __cplusplus
extern "C" {
#endif
lean_object* l_instDecidableEqUInt8___boxed(lean_object*, lean_object*);
uint8_t l_instDecidableEqList___redArg(lean_object*, lean_object*, lean_object*);
lean_object* l_Int_instDecidableEq___boxed(lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* lean_nat_to_int(lean_object*);
lean_object* lean_mk_empty_array_with_capacity(lean_object*);
lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(lean_object*);
lean_object* l_Nat_reprFast(lean_object*);
lean_object* lean_string_length(lean_object*);
uint8_t lean_int_dec_lt(lean_object*, lean_object*);
uint8_t l_List_instDecidableEqNil___redArg(lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
lean_object* l_List_lengthTR___redArg(lean_object*);
lean_object* l_Int_toNat(lean_object*);
lean_object* l___private_Init_Data_List_Impl_0__List_takeTR_go___redArg(lean_object*, lean_object*, lean_object*, lean_object*);
uint8_t lp_shell__lean__final_MemoryTransfer_store___redArg(lean_object*, lean_object*, lean_object*, lean_object*);
lean_object* lp_shell__lean__final_MemoryTransfer_load___redArg(lean_object*, lean_object*, lean_object*);
lean_object* l_List_drop___redArg(lean_object*, lean_object*);
lean_object* l_List_appendTR___redArg(lean_object*, lean_object*);
lean_object* lean_nat_add(lean_object*, lean_object*);
uint8_t lean_int_dec_le(lean_object*, lean_object*);
lean_object* l_Std_Format_joinSep___at___00Array_repr___at___00Std_Time_TimeZone_TZif_instReprTZifV1_repr_spec__0_spec__0(lean_object*, lean_object*);
lean_object* l_Std_Format_fill(lean_object*);
lean_object* l_Bool_repr___redArg(uint8_t);
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = "{ "};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__0_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = "output"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__1 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__1_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__1_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__2 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__2_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__3 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__3_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 5, .m_capacity = 5, .m_length = 4, .m_data = " := "};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__4 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__4_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__4_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__3_value),((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = ","};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__8 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__8_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__8_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__10_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 10, .m_capacity = 10, .m_length = 9, .m_data = "remaining"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__10 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__10_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__11_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__10_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__11 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__11_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__13_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = "status"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__13 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__13_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__14_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__13_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__14 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__14_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__15_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 10, .m_capacity = 10, .m_length = 9, .m_data = "readCalls"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__15 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__15_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__16_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__15_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__16 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__16_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__17_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 11, .m_capacity = 11, .m_length = 10, .m_data = "writeCalls"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__17 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__17_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__18_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__17_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__18 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__18_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__20_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = " }"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__20 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__20_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__0_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__20_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_BufferRelay_instReprOutcome___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_BufferRelay_instReprOutcome_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome___closed__0_value;
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqOutcome(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqOutcome___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_action(lean_object*, lean_object*);
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = "[]"};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__0 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__0_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__1 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__1_value;
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = "["};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__2 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__3 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__3_value;
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = "]"};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__4 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__4_value;
static lean_once_cell_t lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5;
static lean_once_cell_t lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__2_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__7 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__7_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__4_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__8 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__8_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg(lean_object*);
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 8, .m_capacity = 8, .m_length = 7, .m_data = "pending"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__0_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__1 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__1_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = "writes"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__3 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__3_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__3_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__4 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__4_value;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 6, .m_capacity = 6, .m_length = 5, .m_data = "calls"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__5 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__5_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__5_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__6 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__6_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7;
static const lean_string_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = "failed"};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__8 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__8_value;
static const lean_ctor_object lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__9_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__8_value)}};
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__9 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__9_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_BufferRelay_instReprDrainResult___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDrainResult___closed__0_value;
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult___boxed(lean_object*, lean_object*);
static const lean_array_object lp_shell__lean__final_BufferRelay_drain___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_array_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 246}, .m_size = 0, .m_capacity = 0, .m_data = {}};
static const lean_object* lp_shell__lean__final_BufferRelay_drain___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_drain___closed__0_value;
static lean_once_cell_t lp_shell__lean__final_BufferRelay_drain___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_BufferRelay_drain___closed__1;
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_drain(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_drain_match__1_splitter___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_drain_match__1_splitter(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_readAmount(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_readAmount___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_BufferRelay_instReprDetailed___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_BufferRelay_instReprDetailed_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDetailed___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed = (const lean_object*)&lp_shell__lean__final_BufferRelay_instReprDetailed___closed__0_value;
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDetailed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDetailed___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_fill(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_fill___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_loaded(lean_object*, lean_object*, lean_object*);
static const lean_ctor_object lp_shell__lean__final_BufferRelay_execute___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*6 + 0, .m_other = 6, .m_tag = 0}, .m_objs = {((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)(((size_t)(1) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_BufferRelay_execute___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_execute___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_execute(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_runDetailed___lam__0(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_runDetailed___lam__0___boxed(lean_object*);
static const lean_closure_object lp_shell__lean__final_BufferRelay_runDetailed___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_BufferRelay_runDetailed___lam__0___boxed, .m_arity = 1, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_BufferRelay_runDetailed___closed__0 = (const lean_object*)&lp_shell__lean__final_BufferRelay_runDetailed___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_runDetailed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_run(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_action_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_action_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*);
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7(void){
_start:
{
lean_object* v___x_14_; lean_object* v___x_15_; 
v___x_14_ = lean_unsigned_to_nat(10u);
v___x_15_ = lean_nat_to_int(v___x_14_);
return v___x_15_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12(void){
_start:
{
lean_object* v___x_22_; lean_object* v___x_23_; 
v___x_22_ = lean_unsigned_to_nat(13u);
v___x_23_ = lean_nat_to_int(v___x_22_);
return v___x_23_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19(void){
_start:
{
lean_object* v___x_33_; lean_object* v___x_34_; 
v___x_33_ = lean_unsigned_to_nat(14u);
v___x_34_ = lean_nat_to_int(v___x_33_);
return v___x_34_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21(void){
_start:
{
lean_object* v___x_36_; lean_object* v___x_37_; 
v___x_36_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__0));
v___x_37_ = lean_string_length(v___x_36_);
return v___x_37_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22(void){
_start:
{
lean_object* v___x_38_; lean_object* v___x_39_; 
v___x_38_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__21);
v___x_39_ = lean_nat_to_int(v___x_38_);
return v___x_39_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg(lean_object* v_x_44_){
_start:
{
lean_object* v_output_45_; lean_object* v_remaining_46_; lean_object* v_status_47_; lean_object* v_readCalls_48_; lean_object* v_writeCalls_49_; lean_object* v___x_50_; lean_object* v___x_51_; lean_object* v___x_52_; lean_object* v___x_53_; lean_object* v___x_54_; uint8_t v___x_55_; lean_object* v___x_56_; lean_object* v___x_57_; lean_object* v___x_58_; lean_object* v___x_59_; lean_object* v___x_60_; lean_object* v___x_61_; lean_object* v___x_62_; lean_object* v___x_63_; lean_object* v___x_64_; lean_object* v___x_65_; lean_object* v___x_66_; lean_object* v___x_67_; lean_object* v___x_68_; lean_object* v___x_69_; lean_object* v___x_70_; lean_object* v___x_71_; lean_object* v___x_72_; lean_object* v___x_73_; lean_object* v___x_74_; lean_object* v___x_75_; lean_object* v___x_76_; lean_object* v___x_77_; lean_object* v___x_78_; lean_object* v___x_79_; lean_object* v___x_80_; lean_object* v___x_81_; lean_object* v___x_82_; lean_object* v___x_83_; lean_object* v___x_84_; lean_object* v___x_85_; lean_object* v___x_86_; lean_object* v___x_87_; lean_object* v___x_88_; lean_object* v___x_89_; lean_object* v___x_90_; lean_object* v___x_91_; lean_object* v___x_92_; lean_object* v___x_93_; lean_object* v___x_94_; lean_object* v___x_95_; lean_object* v___x_96_; lean_object* v___x_97_; lean_object* v___x_98_; lean_object* v___x_99_; lean_object* v___x_100_; lean_object* v___x_101_; lean_object* v___x_102_; lean_object* v___x_103_; lean_object* v___x_104_; lean_object* v___x_105_; lean_object* v___x_106_; lean_object* v___x_107_; 
v_output_45_ = lean_ctor_get(v_x_44_, 0);
lean_inc(v_output_45_);
v_remaining_46_ = lean_ctor_get(v_x_44_, 1);
lean_inc(v_remaining_46_);
v_status_47_ = lean_ctor_get(v_x_44_, 2);
lean_inc(v_status_47_);
v_readCalls_48_ = lean_ctor_get(v_x_44_, 3);
lean_inc(v_readCalls_48_);
v_writeCalls_49_ = lean_ctor_get(v_x_44_, 4);
lean_inc(v_writeCalls_49_);
lean_dec_ref(v_x_44_);
v___x_50_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5));
v___x_51_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6));
v___x_52_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7);
v___x_53_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_output_45_);
v___x_54_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_54_, 0, v___x_52_);
lean_ctor_set(v___x_54_, 1, v___x_53_);
v___x_55_ = 0;
v___x_56_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_56_, 0, v___x_54_);
lean_ctor_set_uint8(v___x_56_, sizeof(void*)*1, v___x_55_);
v___x_57_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_57_, 0, v___x_51_);
lean_ctor_set(v___x_57_, 1, v___x_56_);
v___x_58_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9));
v___x_59_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_59_, 0, v___x_57_);
lean_ctor_set(v___x_59_, 1, v___x_58_);
v___x_60_ = lean_box(1);
v___x_61_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_61_, 0, v___x_59_);
lean_ctor_set(v___x_61_, 1, v___x_60_);
v___x_62_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__11));
v___x_63_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_63_, 0, v___x_61_);
lean_ctor_set(v___x_63_, 1, v___x_62_);
v___x_64_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_64_, 0, v___x_63_);
lean_ctor_set(v___x_64_, 1, v___x_50_);
v___x_65_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12);
v___x_66_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_remaining_46_);
v___x_67_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_67_, 0, v___x_65_);
lean_ctor_set(v___x_67_, 1, v___x_66_);
v___x_68_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_68_, 0, v___x_67_);
lean_ctor_set_uint8(v___x_68_, sizeof(void*)*1, v___x_55_);
v___x_69_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_69_, 0, v___x_64_);
lean_ctor_set(v___x_69_, 1, v___x_68_);
v___x_70_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_70_, 0, v___x_69_);
lean_ctor_set(v___x_70_, 1, v___x_58_);
v___x_71_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_71_, 0, v___x_70_);
lean_ctor_set(v___x_71_, 1, v___x_60_);
v___x_72_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__14));
v___x_73_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_73_, 0, v___x_71_);
lean_ctor_set(v___x_73_, 1, v___x_72_);
v___x_74_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_74_, 0, v___x_73_);
lean_ctor_set(v___x_74_, 1, v___x_50_);
v___x_75_ = l_Nat_reprFast(v_status_47_);
v___x_76_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_76_, 0, v___x_75_);
v___x_77_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_77_, 0, v___x_52_);
lean_ctor_set(v___x_77_, 1, v___x_76_);
v___x_78_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_78_, 0, v___x_77_);
lean_ctor_set_uint8(v___x_78_, sizeof(void*)*1, v___x_55_);
v___x_79_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_79_, 0, v___x_74_);
lean_ctor_set(v___x_79_, 1, v___x_78_);
v___x_80_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_80_, 0, v___x_79_);
lean_ctor_set(v___x_80_, 1, v___x_58_);
v___x_81_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_81_, 0, v___x_80_);
lean_ctor_set(v___x_81_, 1, v___x_60_);
v___x_82_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__16));
v___x_83_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_83_, 0, v___x_81_);
lean_ctor_set(v___x_83_, 1, v___x_82_);
v___x_84_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_84_, 0, v___x_83_);
lean_ctor_set(v___x_84_, 1, v___x_50_);
v___x_85_ = l_Nat_reprFast(v_readCalls_48_);
v___x_86_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_86_, 0, v___x_85_);
v___x_87_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_87_, 0, v___x_65_);
lean_ctor_set(v___x_87_, 1, v___x_86_);
v___x_88_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_88_, 0, v___x_87_);
lean_ctor_set_uint8(v___x_88_, sizeof(void*)*1, v___x_55_);
v___x_89_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_89_, 0, v___x_84_);
lean_ctor_set(v___x_89_, 1, v___x_88_);
v___x_90_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_90_, 0, v___x_89_);
lean_ctor_set(v___x_90_, 1, v___x_58_);
v___x_91_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_91_, 0, v___x_90_);
lean_ctor_set(v___x_91_, 1, v___x_60_);
v___x_92_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__18));
v___x_93_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_93_, 0, v___x_91_);
lean_ctor_set(v___x_93_, 1, v___x_92_);
v___x_94_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_94_, 0, v___x_93_);
lean_ctor_set(v___x_94_, 1, v___x_50_);
v___x_95_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19);
v___x_96_ = l_Nat_reprFast(v_writeCalls_49_);
v___x_97_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_97_, 0, v___x_96_);
v___x_98_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_98_, 0, v___x_95_);
lean_ctor_set(v___x_98_, 1, v___x_97_);
v___x_99_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_99_, 0, v___x_98_);
lean_ctor_set_uint8(v___x_99_, sizeof(void*)*1, v___x_55_);
v___x_100_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_100_, 0, v___x_94_);
lean_ctor_set(v___x_100_, 1, v___x_99_);
v___x_101_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22);
v___x_102_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23));
v___x_103_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_103_, 0, v___x_102_);
lean_ctor_set(v___x_103_, 1, v___x_100_);
v___x_104_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24));
v___x_105_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_105_, 0, v___x_103_);
lean_ctor_set(v___x_105_, 1, v___x_104_);
v___x_106_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_106_, 0, v___x_101_);
lean_ctor_set(v___x_106_, 1, v___x_105_);
v___x_107_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_107_, 0, v___x_106_);
lean_ctor_set_uint8(v___x_107_, sizeof(void*)*1, v___x_55_);
return v___x_107_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr(lean_object* v_x_108_, lean_object* v_prec_109_){
_start:
{
lean_object* v___x_110_; 
v___x_110_ = lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg(v_x_108_);
return v___x_110_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprOutcome_repr___boxed(lean_object* v_x_111_, lean_object* v_prec_112_){
_start:
{
lean_object* v_res_113_; 
v_res_113_ = lp_shell__lean__final_BufferRelay_instReprOutcome_repr(v_x_111_, v_prec_112_);
lean_dec(v_prec_112_);
return v_res_113_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq(lean_object* v_x_116_, lean_object* v_x_117_){
_start:
{
lean_object* v_output_118_; lean_object* v_remaining_119_; lean_object* v_status_120_; lean_object* v_readCalls_121_; lean_object* v_writeCalls_122_; lean_object* v_output_123_; lean_object* v_remaining_124_; lean_object* v_status_125_; lean_object* v_readCalls_126_; lean_object* v_writeCalls_127_; lean_object* v___x_128_; uint8_t v___x_129_; 
v_output_118_ = lean_ctor_get(v_x_116_, 0);
lean_inc(v_output_118_);
v_remaining_119_ = lean_ctor_get(v_x_116_, 1);
lean_inc(v_remaining_119_);
v_status_120_ = lean_ctor_get(v_x_116_, 2);
lean_inc(v_status_120_);
v_readCalls_121_ = lean_ctor_get(v_x_116_, 3);
lean_inc(v_readCalls_121_);
v_writeCalls_122_ = lean_ctor_get(v_x_116_, 4);
lean_inc(v_writeCalls_122_);
lean_dec_ref(v_x_116_);
v_output_123_ = lean_ctor_get(v_x_117_, 0);
lean_inc(v_output_123_);
v_remaining_124_ = lean_ctor_get(v_x_117_, 1);
lean_inc(v_remaining_124_);
v_status_125_ = lean_ctor_get(v_x_117_, 2);
lean_inc(v_status_125_);
v_readCalls_126_ = lean_ctor_get(v_x_117_, 3);
lean_inc(v_readCalls_126_);
v_writeCalls_127_ = lean_ctor_get(v_x_117_, 4);
lean_inc(v_writeCalls_127_);
lean_dec_ref(v_x_117_);
v___x_128_ = lean_alloc_closure((void*)(l_instDecidableEqUInt8___boxed), 2, 0);
lean_inc_ref(v___x_128_);
v___x_129_ = l_instDecidableEqList___redArg(v___x_128_, v_output_118_, v_output_123_);
if (v___x_129_ == 0)
{
lean_dec_ref(v___x_128_);
lean_dec(v_writeCalls_127_);
lean_dec(v_readCalls_126_);
lean_dec(v_status_125_);
lean_dec(v_remaining_124_);
lean_dec(v_writeCalls_122_);
lean_dec(v_readCalls_121_);
lean_dec(v_status_120_);
lean_dec(v_remaining_119_);
return v___x_129_;
}
else
{
uint8_t v___x_130_; 
v___x_130_ = l_instDecidableEqList___redArg(v___x_128_, v_remaining_119_, v_remaining_124_);
if (v___x_130_ == 0)
{
lean_dec(v_writeCalls_127_);
lean_dec(v_readCalls_126_);
lean_dec(v_status_125_);
lean_dec(v_writeCalls_122_);
lean_dec(v_readCalls_121_);
lean_dec(v_status_120_);
return v___x_130_;
}
else
{
uint8_t v___x_131_; 
v___x_131_ = lean_nat_dec_eq(v_status_120_, v_status_125_);
lean_dec(v_status_125_);
lean_dec(v_status_120_);
if (v___x_131_ == 0)
{
lean_dec(v_writeCalls_127_);
lean_dec(v_readCalls_126_);
lean_dec(v_writeCalls_122_);
lean_dec(v_readCalls_121_);
return v___x_131_;
}
else
{
uint8_t v___x_132_; 
v___x_132_ = lean_nat_dec_eq(v_readCalls_121_, v_readCalls_126_);
lean_dec(v_readCalls_126_);
lean_dec(v_readCalls_121_);
if (v___x_132_ == 0)
{
lean_dec(v_writeCalls_127_);
lean_dec(v_writeCalls_122_);
return v___x_132_;
}
else
{
uint8_t v___x_133_; 
v___x_133_ = lean_nat_dec_eq(v_writeCalls_122_, v_writeCalls_127_);
lean_dec(v_writeCalls_127_);
lean_dec(v_writeCalls_122_);
return v___x_133_;
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq___boxed(lean_object* v_x_134_, lean_object* v_x_135_){
_start:
{
uint8_t v_res_136_; lean_object* v_r_137_; 
v_res_136_ = lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq(v_x_134_, v_x_135_);
v_r_137_ = lean_box(v_res_136_);
return v_r_137_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqOutcome(lean_object* v_x_138_, lean_object* v_x_139_){
_start:
{
uint8_t v___x_140_; 
v___x_140_ = lp_shell__lean__final_BufferRelay_instDecidableEqOutcome_decEq(v_x_138_, v_x_139_);
return v___x_140_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqOutcome___boxed(lean_object* v_x_141_, lean_object* v_x_142_){
_start:
{
uint8_t v_res_143_; lean_object* v_r_144_; 
v_res_143_ = lp_shell__lean__final_BufferRelay_instDecidableEqOutcome(v_x_141_, v_x_142_);
v_r_144_ = lean_box(v_res_143_);
return v_r_144_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_action(lean_object* v_request_145_, lean_object* v_x_146_){
_start:
{
if (lean_obj_tag(v_x_146_) == 0)
{
lean_object* v___x_147_; lean_object* v___x_148_; 
v___x_147_ = lean_nat_to_int(v_request_145_);
v___x_148_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_148_, 0, v___x_147_);
lean_ctor_set(v___x_148_, 1, v_x_146_);
return v___x_148_;
}
else
{
lean_object* v_head_149_; lean_object* v_tail_150_; lean_object* v___x_152_; uint8_t v_isShared_153_; uint8_t v_isSharedCheck_157_; 
lean_dec(v_request_145_);
v_head_149_ = lean_ctor_get(v_x_146_, 0);
v_tail_150_ = lean_ctor_get(v_x_146_, 1);
v_isSharedCheck_157_ = !lean_is_exclusive(v_x_146_);
if (v_isSharedCheck_157_ == 0)
{
v___x_152_ = v_x_146_;
v_isShared_153_ = v_isSharedCheck_157_;
goto v_resetjp_151_;
}
else
{
lean_inc(v_tail_150_);
lean_inc(v_head_149_);
lean_dec(v_x_146_);
v___x_152_ = lean_box(0);
v_isShared_153_ = v_isSharedCheck_157_;
goto v_resetjp_151_;
}
v_resetjp_151_:
{
lean_object* v___x_155_; 
if (v_isShared_153_ == 0)
{
lean_ctor_set_tag(v___x_152_, 0);
v___x_155_ = v___x_152_;
goto v_reusejp_154_;
}
else
{
lean_object* v_reuseFailAlloc_156_; 
v_reuseFailAlloc_156_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v_reuseFailAlloc_156_, 0, v_head_149_);
lean_ctor_set(v_reuseFailAlloc_156_, 1, v_tail_150_);
v___x_155_ = v_reuseFailAlloc_156_;
goto v_reusejp_154_;
}
v_reusejp_154_:
{
return v___x_155_;
}
}
}
}
}
static lean_object* _init_lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5(void){
_start:
{
lean_object* v___x_166_; lean_object* v___x_167_; 
v___x_166_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__2));
v___x_167_ = lean_string_length(v___x_166_);
return v___x_167_;
}
}
static lean_object* _init_lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6(void){
_start:
{
lean_object* v___x_168_; lean_object* v___x_169_; 
v___x_168_ = lean_obj_once(&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5, &lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5_once, _init_lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__5);
v___x_169_ = lean_nat_to_int(v___x_168_);
return v___x_169_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg(lean_object* v_a_174_){
_start:
{
if (lean_obj_tag(v_a_174_) == 0)
{
lean_object* v___x_175_; 
v___x_175_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__1));
return v___x_175_;
}
else
{
lean_object* v___x_176_; lean_object* v___x_177_; lean_object* v___x_178_; lean_object* v___x_179_; lean_object* v___x_180_; lean_object* v___x_181_; lean_object* v___x_182_; lean_object* v___x_183_; lean_object* v___x_184_; 
v___x_176_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__3));
v___x_177_ = l_Std_Format_joinSep___at___00Array_repr___at___00Std_Time_TimeZone_TZif_instReprTZifV1_repr_spec__0_spec__0(v_a_174_, v___x_176_);
v___x_178_ = lean_obj_once(&lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6, &lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6_once, _init_lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__6);
v___x_179_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__7));
v___x_180_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_180_, 0, v___x_179_);
lean_ctor_set(v___x_180_, 1, v___x_177_);
v___x_181_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg___closed__8));
v___x_182_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_182_, 0, v___x_180_);
lean_ctor_set(v___x_182_, 1, v___x_181_);
v___x_183_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_183_, 0, v___x_178_);
lean_ctor_set(v___x_183_, 1, v___x_182_);
v___x_184_ = l_Std_Format_fill(v___x_183_);
return v___x_184_;
}
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2(void){
_start:
{
lean_object* v___x_188_; lean_object* v___x_189_; 
v___x_188_ = lean_unsigned_to_nat(11u);
v___x_189_ = lean_nat_to_int(v___x_188_);
return v___x_189_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7(void){
_start:
{
lean_object* v___x_196_; lean_object* v___x_197_; 
v___x_196_ = lean_unsigned_to_nat(9u);
v___x_197_ = lean_nat_to_int(v___x_196_);
return v___x_197_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg(lean_object* v_x_201_){
_start:
{
lean_object* v_output_202_; lean_object* v_pending_203_; lean_object* v_writes_204_; lean_object* v_calls_205_; uint8_t v_failed_206_; lean_object* v___x_207_; lean_object* v___x_208_; lean_object* v___x_209_; lean_object* v___x_210_; lean_object* v___x_211_; uint8_t v___x_212_; lean_object* v___x_213_; lean_object* v___x_214_; lean_object* v___x_215_; lean_object* v___x_216_; lean_object* v___x_217_; lean_object* v___x_218_; lean_object* v___x_219_; lean_object* v___x_220_; lean_object* v___x_221_; lean_object* v___x_222_; lean_object* v___x_223_; lean_object* v___x_224_; lean_object* v___x_225_; lean_object* v___x_226_; lean_object* v___x_227_; lean_object* v___x_228_; lean_object* v___x_229_; lean_object* v___x_230_; lean_object* v___x_231_; lean_object* v___x_232_; lean_object* v___x_233_; lean_object* v___x_234_; lean_object* v___x_235_; lean_object* v___x_236_; lean_object* v___x_237_; lean_object* v___x_238_; lean_object* v___x_239_; lean_object* v___x_240_; lean_object* v___x_241_; lean_object* v___x_242_; lean_object* v___x_243_; lean_object* v___x_244_; lean_object* v___x_245_; lean_object* v___x_246_; lean_object* v___x_247_; lean_object* v___x_248_; lean_object* v___x_249_; lean_object* v___x_250_; lean_object* v___x_251_; lean_object* v___x_252_; lean_object* v___x_253_; lean_object* v___x_254_; lean_object* v___x_255_; lean_object* v___x_256_; lean_object* v___x_257_; lean_object* v___x_258_; lean_object* v___x_259_; lean_object* v___x_260_; lean_object* v___x_261_; lean_object* v___x_262_; 
v_output_202_ = lean_ctor_get(v_x_201_, 0);
lean_inc(v_output_202_);
v_pending_203_ = lean_ctor_get(v_x_201_, 1);
lean_inc(v_pending_203_);
v_writes_204_ = lean_ctor_get(v_x_201_, 2);
lean_inc(v_writes_204_);
v_calls_205_ = lean_ctor_get(v_x_201_, 3);
lean_inc(v_calls_205_);
v_failed_206_ = lean_ctor_get_uint8(v_x_201_, sizeof(void*)*4);
lean_dec_ref(v_x_201_);
v___x_207_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5));
v___x_208_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6));
v___x_209_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7);
v___x_210_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_output_202_);
v___x_211_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_211_, 0, v___x_209_);
lean_ctor_set(v___x_211_, 1, v___x_210_);
v___x_212_ = 0;
v___x_213_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_213_, 0, v___x_211_);
lean_ctor_set_uint8(v___x_213_, sizeof(void*)*1, v___x_212_);
v___x_214_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_214_, 0, v___x_208_);
lean_ctor_set(v___x_214_, 1, v___x_213_);
v___x_215_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9));
v___x_216_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_216_, 0, v___x_214_);
lean_ctor_set(v___x_216_, 1, v___x_215_);
v___x_217_ = lean_box(1);
v___x_218_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_218_, 0, v___x_216_);
lean_ctor_set(v___x_218_, 1, v___x_217_);
v___x_219_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__1));
v___x_220_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_220_, 0, v___x_218_);
lean_ctor_set(v___x_220_, 1, v___x_219_);
v___x_221_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_221_, 0, v___x_220_);
lean_ctor_set(v___x_221_, 1, v___x_207_);
v___x_222_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2, &lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2_once, _init_lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2);
v___x_223_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_pending_203_);
v___x_224_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_224_, 0, v___x_222_);
lean_ctor_set(v___x_224_, 1, v___x_223_);
v___x_225_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_225_, 0, v___x_224_);
lean_ctor_set_uint8(v___x_225_, sizeof(void*)*1, v___x_212_);
v___x_226_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_226_, 0, v___x_221_);
lean_ctor_set(v___x_226_, 1, v___x_225_);
v___x_227_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_227_, 0, v___x_226_);
lean_ctor_set(v___x_227_, 1, v___x_215_);
v___x_228_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_228_, 0, v___x_227_);
lean_ctor_set(v___x_228_, 1, v___x_217_);
v___x_229_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__4));
v___x_230_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_230_, 0, v___x_228_);
lean_ctor_set(v___x_230_, 1, v___x_229_);
v___x_231_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_231_, 0, v___x_230_);
lean_ctor_set(v___x_231_, 1, v___x_207_);
v___x_232_ = lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg(v_writes_204_);
v___x_233_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_233_, 0, v___x_209_);
lean_ctor_set(v___x_233_, 1, v___x_232_);
v___x_234_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_234_, 0, v___x_233_);
lean_ctor_set_uint8(v___x_234_, sizeof(void*)*1, v___x_212_);
v___x_235_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_235_, 0, v___x_231_);
lean_ctor_set(v___x_235_, 1, v___x_234_);
v___x_236_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_236_, 0, v___x_235_);
lean_ctor_set(v___x_236_, 1, v___x_215_);
v___x_237_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_237_, 0, v___x_236_);
lean_ctor_set(v___x_237_, 1, v___x_217_);
v___x_238_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__6));
v___x_239_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_239_, 0, v___x_237_);
lean_ctor_set(v___x_239_, 1, v___x_238_);
v___x_240_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_240_, 0, v___x_239_);
lean_ctor_set(v___x_240_, 1, v___x_207_);
v___x_241_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7, &lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7_once, _init_lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__7);
v___x_242_ = l_Nat_reprFast(v_calls_205_);
v___x_243_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_243_, 0, v___x_242_);
v___x_244_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_244_, 0, v___x_241_);
lean_ctor_set(v___x_244_, 1, v___x_243_);
v___x_245_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_245_, 0, v___x_244_);
lean_ctor_set_uint8(v___x_245_, sizeof(void*)*1, v___x_212_);
v___x_246_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_246_, 0, v___x_240_);
lean_ctor_set(v___x_246_, 1, v___x_245_);
v___x_247_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_247_, 0, v___x_246_);
lean_ctor_set(v___x_247_, 1, v___x_215_);
v___x_248_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_248_, 0, v___x_247_);
lean_ctor_set(v___x_248_, 1, v___x_217_);
v___x_249_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__9));
v___x_250_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_250_, 0, v___x_248_);
lean_ctor_set(v___x_250_, 1, v___x_249_);
v___x_251_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_251_, 0, v___x_250_);
lean_ctor_set(v___x_251_, 1, v___x_207_);
v___x_252_ = l_Bool_repr___redArg(v_failed_206_);
v___x_253_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_253_, 0, v___x_209_);
lean_ctor_set(v___x_253_, 1, v___x_252_);
v___x_254_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_254_, 0, v___x_253_);
lean_ctor_set_uint8(v___x_254_, sizeof(void*)*1, v___x_212_);
v___x_255_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_255_, 0, v___x_251_);
lean_ctor_set(v___x_255_, 1, v___x_254_);
v___x_256_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22);
v___x_257_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23));
v___x_258_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_258_, 0, v___x_257_);
lean_ctor_set(v___x_258_, 1, v___x_255_);
v___x_259_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24));
v___x_260_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_260_, 0, v___x_258_);
lean_ctor_set(v___x_260_, 1, v___x_259_);
v___x_261_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_261_, 0, v___x_256_);
lean_ctor_set(v___x_261_, 1, v___x_260_);
v___x_262_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_262_, 0, v___x_261_);
lean_ctor_set_uint8(v___x_262_, sizeof(void*)*1, v___x_212_);
return v___x_262_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr(lean_object* v_x_263_, lean_object* v_prec_264_){
_start:
{
lean_object* v___x_265_; 
v___x_265_ = lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg(v_x_263_);
return v___x_265_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___boxed(lean_object* v_x_266_, lean_object* v_prec_267_){
_start:
{
lean_object* v_res_268_; 
v_res_268_ = lp_shell__lean__final_BufferRelay_instReprDrainResult_repr(v_x_266_, v_prec_267_);
lean_dec(v_prec_267_);
return v_res_268_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0(lean_object* v_a_269_, lean_object* v_n_270_){
_start:
{
lean_object* v___x_271_; 
v___x_271_ = lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___redArg(v_a_269_);
return v___x_271_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0___boxed(lean_object* v_a_272_, lean_object* v_n_273_){
_start:
{
lean_object* v_res_274_; 
v_res_274_ = lp_shell__lean__final_List_repr_x27___at___00BufferRelay_instReprDrainResult_repr_spec__0(v_a_272_, v_n_273_);
lean_dec(v_n_273_);
return v_res_274_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq(lean_object* v_x_277_, lean_object* v_x_278_){
_start:
{
lean_object* v_output_279_; lean_object* v_pending_280_; lean_object* v_writes_281_; lean_object* v_calls_282_; uint8_t v_failed_283_; lean_object* v_output_284_; lean_object* v_pending_285_; lean_object* v_writes_286_; lean_object* v_calls_287_; uint8_t v_failed_288_; lean_object* v___x_289_; uint8_t v___x_290_; 
v_output_279_ = lean_ctor_get(v_x_277_, 0);
lean_inc(v_output_279_);
v_pending_280_ = lean_ctor_get(v_x_277_, 1);
lean_inc(v_pending_280_);
v_writes_281_ = lean_ctor_get(v_x_277_, 2);
lean_inc(v_writes_281_);
v_calls_282_ = lean_ctor_get(v_x_277_, 3);
lean_inc(v_calls_282_);
v_failed_283_ = lean_ctor_get_uint8(v_x_277_, sizeof(void*)*4);
lean_dec_ref(v_x_277_);
v_output_284_ = lean_ctor_get(v_x_278_, 0);
lean_inc(v_output_284_);
v_pending_285_ = lean_ctor_get(v_x_278_, 1);
lean_inc(v_pending_285_);
v_writes_286_ = lean_ctor_get(v_x_278_, 2);
lean_inc(v_writes_286_);
v_calls_287_ = lean_ctor_get(v_x_278_, 3);
lean_inc(v_calls_287_);
v_failed_288_ = lean_ctor_get_uint8(v_x_278_, sizeof(void*)*4);
lean_dec_ref(v_x_278_);
v___x_289_ = lean_alloc_closure((void*)(l_instDecidableEqUInt8___boxed), 2, 0);
lean_inc_ref(v___x_289_);
v___x_290_ = l_instDecidableEqList___redArg(v___x_289_, v_output_279_, v_output_284_);
if (v___x_290_ == 0)
{
lean_dec_ref(v___x_289_);
lean_dec(v_calls_287_);
lean_dec(v_writes_286_);
lean_dec(v_pending_285_);
lean_dec(v_calls_282_);
lean_dec(v_writes_281_);
lean_dec(v_pending_280_);
return v___x_290_;
}
else
{
uint8_t v___x_291_; 
v___x_291_ = l_instDecidableEqList___redArg(v___x_289_, v_pending_280_, v_pending_285_);
if (v___x_291_ == 0)
{
lean_dec(v_calls_287_);
lean_dec(v_writes_286_);
lean_dec(v_calls_282_);
lean_dec(v_writes_281_);
return v___x_291_;
}
else
{
lean_object* v___x_292_; uint8_t v___x_293_; 
v___x_292_ = lean_alloc_closure((void*)(l_Int_instDecidableEq___boxed), 2, 0);
v___x_293_ = l_instDecidableEqList___redArg(v___x_292_, v_writes_281_, v_writes_286_);
if (v___x_293_ == 0)
{
lean_dec(v_calls_287_);
lean_dec(v_calls_282_);
return v___x_293_;
}
else
{
uint8_t v___x_294_; 
v___x_294_ = lean_nat_dec_eq(v_calls_282_, v_calls_287_);
lean_dec(v_calls_287_);
lean_dec(v_calls_282_);
if (v___x_294_ == 0)
{
return v___x_294_;
}
else
{
if (v_failed_283_ == 0)
{
if (v_failed_288_ == 0)
{
return v___x_294_;
}
else
{
return v_failed_283_;
}
}
else
{
return v_failed_288_;
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq___boxed(lean_object* v_x_295_, lean_object* v_x_296_){
_start:
{
uint8_t v_res_297_; lean_object* v_r_298_; 
v_res_297_ = lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq(v_x_295_, v_x_296_);
v_r_298_ = lean_box(v_res_297_);
return v_r_298_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult(lean_object* v_x_299_, lean_object* v_x_300_){
_start:
{
uint8_t v___x_301_; 
v___x_301_ = lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult_decEq(v_x_299_, v_x_300_);
return v___x_301_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult___boxed(lean_object* v_x_302_, lean_object* v_x_303_){
_start:
{
uint8_t v_res_304_; lean_object* v_r_305_; 
v_res_304_ = lp_shell__lean__final_BufferRelay_instDecidableEqDrainResult(v_x_302_, v_x_303_);
v_r_305_ = lean_box(v_res_304_);
return v_r_305_;
}
}
static lean_object* _init_lp_shell__lean__final_BufferRelay_drain___closed__1(void){
_start:
{
lean_object* v___x_308_; lean_object* v___x_309_; 
v___x_308_ = lean_unsigned_to_nat(0u);
v___x_309_ = lean_nat_to_int(v___x_308_);
return v___x_309_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_drain(lean_object* v_view_310_, lean_object* v_writes_311_){
_start:
{
uint8_t v___x_312_; 
v___x_312_ = l_List_instDecidableEqNil___redArg(v_view_310_);
if (v___x_312_ == 0)
{
lean_object* v___x_313_; lean_object* v___x_314_; lean_object* v_fst_315_; lean_object* v_snd_316_; lean_object* v___y_318_; lean_object* v___x_338_; uint8_t v___x_339_; 
v___x_313_ = l_List_lengthTR___redArg(v_view_310_);
lean_inc(v___x_313_);
v___x_314_ = lp_shell__lean__final_BufferRelay_action(v___x_313_, v_writes_311_);
v_fst_315_ = lean_ctor_get(v___x_314_, 0);
lean_inc(v_fst_315_);
v_snd_316_ = lean_ctor_get(v___x_314_, 1);
lean_inc(v_snd_316_);
lean_dec_ref(v___x_314_);
v___x_338_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_drain___closed__1, &lp_shell__lean__final_BufferRelay_drain___closed__1_once, _init_lp_shell__lean__final_BufferRelay_drain___closed__1);
v___x_339_ = lean_int_dec_le(v_fst_315_, v___x_338_);
if (v___x_339_ == 0)
{
lean_object* v___x_340_; uint8_t v___x_341_; 
v___x_340_ = l_Int_toNat(v_fst_315_);
lean_dec(v_fst_315_);
v___x_341_ = lean_nat_dec_le(v___x_340_, v___x_313_);
if (v___x_341_ == 0)
{
lean_dec(v___x_340_);
v___y_318_ = v___x_313_;
goto v___jp_317_;
}
else
{
lean_dec(v___x_313_);
v___y_318_ = v___x_340_;
goto v___jp_317_;
}
}
else
{
lean_object* v___x_342_; lean_object* v___x_343_; lean_object* v___x_344_; 
lean_dec(v_fst_315_);
lean_dec(v___x_313_);
v___x_342_ = lean_box(0);
v___x_343_ = lean_unsigned_to_nat(1u);
v___x_344_ = lean_alloc_ctor(0, 4, 1);
lean_ctor_set(v___x_344_, 0, v___x_342_);
lean_ctor_set(v___x_344_, 1, v_view_310_);
lean_ctor_set(v___x_344_, 2, v_snd_316_);
lean_ctor_set(v___x_344_, 3, v___x_343_);
lean_ctor_set_uint8(v___x_344_, sizeof(void*)*4, v___x_339_);
return v___x_344_;
}
v___jp_317_:
{
lean_object* v___x_319_; lean_object* v_d_320_; lean_object* v_output_321_; lean_object* v_pending_322_; lean_object* v_writes_323_; lean_object* v_calls_324_; uint8_t v_failed_325_; lean_object* v___x_327_; uint8_t v_isShared_328_; uint8_t v_isSharedCheck_337_; 
lean_inc(v___y_318_);
v___x_319_ = l_List_drop___redArg(v___y_318_, v_view_310_);
v_d_320_ = lp_shell__lean__final_BufferRelay_drain(v___x_319_, v_snd_316_);
v_output_321_ = lean_ctor_get(v_d_320_, 0);
v_pending_322_ = lean_ctor_get(v_d_320_, 1);
v_writes_323_ = lean_ctor_get(v_d_320_, 2);
v_calls_324_ = lean_ctor_get(v_d_320_, 3);
v_failed_325_ = lean_ctor_get_uint8(v_d_320_, sizeof(void*)*4);
v_isSharedCheck_337_ = !lean_is_exclusive(v_d_320_);
if (v_isSharedCheck_337_ == 0)
{
v___x_327_ = v_d_320_;
v_isShared_328_ = v_isSharedCheck_337_;
goto v_resetjp_326_;
}
else
{
lean_inc(v_calls_324_);
lean_inc(v_writes_323_);
lean_inc(v_pending_322_);
lean_inc(v_output_321_);
lean_dec(v_d_320_);
v___x_327_ = lean_box(0);
v_isShared_328_ = v_isSharedCheck_337_;
goto v_resetjp_326_;
}
v_resetjp_326_:
{
lean_object* v___x_329_; lean_object* v___x_330_; lean_object* v___x_331_; lean_object* v___x_332_; lean_object* v___x_333_; lean_object* v___x_335_; 
v___x_329_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_drain___closed__0));
lean_inc(v_view_310_);
v___x_330_ = l___private_Init_Data_List_Impl_0__List_takeTR_go___redArg(v_view_310_, v_view_310_, v___y_318_, v___x_329_);
lean_dec(v_view_310_);
v___x_331_ = l_List_appendTR___redArg(v___x_330_, v_output_321_);
v___x_332_ = lean_unsigned_to_nat(1u);
v___x_333_ = lean_nat_add(v_calls_324_, v___x_332_);
lean_dec(v_calls_324_);
if (v_isShared_328_ == 0)
{
lean_ctor_set(v___x_327_, 3, v___x_333_);
lean_ctor_set(v___x_327_, 0, v___x_331_);
v___x_335_ = v___x_327_;
goto v_reusejp_334_;
}
else
{
lean_object* v_reuseFailAlloc_336_; 
v_reuseFailAlloc_336_ = lean_alloc_ctor(0, 4, 1);
lean_ctor_set(v_reuseFailAlloc_336_, 0, v___x_331_);
lean_ctor_set(v_reuseFailAlloc_336_, 1, v_pending_322_);
lean_ctor_set(v_reuseFailAlloc_336_, 2, v_writes_323_);
lean_ctor_set(v_reuseFailAlloc_336_, 3, v___x_333_);
lean_ctor_set_uint8(v_reuseFailAlloc_336_, sizeof(void*)*4, v_failed_325_);
v___x_335_ = v_reuseFailAlloc_336_;
goto v_reusejp_334_;
}
v_reusejp_334_:
{
return v___x_335_;
}
}
}
}
else
{
lean_object* v___x_345_; lean_object* v___x_346_; uint8_t v___x_347_; lean_object* v___x_348_; 
lean_dec(v_view_310_);
v___x_345_ = lean_box(0);
v___x_346_ = lean_unsigned_to_nat(0u);
v___x_347_ = 0;
v___x_348_ = lean_alloc_ctor(0, 4, 1);
lean_ctor_set(v___x_348_, 0, v___x_345_);
lean_ctor_set(v___x_348_, 1, v___x_345_);
lean_ctor_set(v___x_348_, 2, v_writes_311_);
lean_ctor_set(v___x_348_, 3, v___x_346_);
lean_ctor_set_uint8(v___x_348_, sizeof(void*)*4, v___x_347_);
return v___x_348_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_drain_match__1_splitter___redArg(lean_object* v_x_349_, lean_object* v_h__1_350_){
_start:
{
lean_object* v_fst_351_; lean_object* v_snd_352_; lean_object* v___x_353_; 
v_fst_351_ = lean_ctor_get(v_x_349_, 0);
lean_inc(v_fst_351_);
v_snd_352_ = lean_ctor_get(v_x_349_, 1);
lean_inc(v_snd_352_);
lean_dec_ref(v_x_349_);
v___x_353_ = lean_apply_2(v_h__1_350_, v_fst_351_, v_snd_352_);
return v___x_353_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_drain_match__1_splitter(lean_object* v_motive_354_, lean_object* v_x_355_, lean_object* v_h__1_356_){
_start:
{
lean_object* v_fst_357_; lean_object* v_snd_358_; lean_object* v___x_359_; 
v_fst_357_ = lean_ctor_get(v_x_355_, 0);
lean_inc(v_fst_357_);
v_snd_358_ = lean_ctor_get(v_x_355_, 1);
lean_inc(v_snd_358_);
lean_dec_ref(v_x_355_);
v___x_359_ = lean_apply_2(v_h__1_356_, v_fst_357_, v_snd_358_);
return v___x_359_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_readAmount(lean_object* v_input_360_, lean_object* v_q_361_){
_start:
{
lean_object* v___x_362_; lean_object* v___y_364_; lean_object* v___y_367_; lean_object* v___x_370_; lean_object* v___x_371_; uint8_t v___x_372_; 
v___x_362_ = lean_unsigned_to_nat(32u);
v___x_370_ = lean_unsigned_to_nat(1u);
v___x_371_ = l_Int_toNat(v_q_361_);
v___x_372_ = lean_nat_dec_le(v___x_370_, v___x_371_);
if (v___x_372_ == 0)
{
lean_dec(v___x_371_);
v___y_367_ = v___x_370_;
goto v___jp_366_;
}
else
{
v___y_367_ = v___x_371_;
goto v___jp_366_;
}
v___jp_363_:
{
uint8_t v___x_365_; 
v___x_365_ = lean_nat_dec_le(v___x_362_, v___y_364_);
if (v___x_365_ == 0)
{
return v___y_364_;
}
else
{
lean_dec(v___y_364_);
return v___x_362_;
}
}
v___jp_366_:
{
lean_object* v___x_368_; uint8_t v___x_369_; 
v___x_368_ = l_List_lengthTR___redArg(v_input_360_);
v___x_369_ = lean_nat_dec_le(v___y_367_, v___x_368_);
if (v___x_369_ == 0)
{
lean_dec(v___y_367_);
v___y_364_ = v___x_368_;
goto v___jp_363_;
}
else
{
lean_dec(v___x_368_);
v___y_364_ = v___y_367_;
goto v___jp_363_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_readAmount___boxed(lean_object* v_input_373_, lean_object* v_q_374_){
_start:
{
lean_object* v_res_375_; 
v_res_375_ = lp_shell__lean__final_BufferRelay_readAmount(v_input_373_, v_q_374_);
lean_dec(v_q_374_);
lean_dec(v_input_373_);
return v_res_375_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr___redArg(lean_object* v_x_376_){
_start:
{
lean_object* v_output_377_; lean_object* v_remaining_378_; lean_object* v_pending_379_; lean_object* v_status_380_; lean_object* v_readCalls_381_; lean_object* v_writeCalls_382_; lean_object* v___x_383_; lean_object* v___x_384_; lean_object* v___x_385_; lean_object* v___x_386_; lean_object* v___x_387_; uint8_t v___x_388_; lean_object* v___x_389_; lean_object* v___x_390_; lean_object* v___x_391_; lean_object* v___x_392_; lean_object* v___x_393_; lean_object* v___x_394_; lean_object* v___x_395_; lean_object* v___x_396_; lean_object* v___x_397_; lean_object* v___x_398_; lean_object* v___x_399_; lean_object* v___x_400_; lean_object* v___x_401_; lean_object* v___x_402_; lean_object* v___x_403_; lean_object* v___x_404_; lean_object* v___x_405_; lean_object* v___x_406_; lean_object* v___x_407_; lean_object* v___x_408_; lean_object* v___x_409_; lean_object* v___x_410_; lean_object* v___x_411_; lean_object* v___x_412_; lean_object* v___x_413_; lean_object* v___x_414_; lean_object* v___x_415_; lean_object* v___x_416_; lean_object* v___x_417_; lean_object* v___x_418_; lean_object* v___x_419_; lean_object* v___x_420_; lean_object* v___x_421_; lean_object* v___x_422_; lean_object* v___x_423_; lean_object* v___x_424_; lean_object* v___x_425_; lean_object* v___x_426_; lean_object* v___x_427_; lean_object* v___x_428_; lean_object* v___x_429_; lean_object* v___x_430_; lean_object* v___x_431_; lean_object* v___x_432_; lean_object* v___x_433_; lean_object* v___x_434_; lean_object* v___x_435_; lean_object* v___x_436_; lean_object* v___x_437_; lean_object* v___x_438_; lean_object* v___x_439_; lean_object* v___x_440_; lean_object* v___x_441_; lean_object* v___x_442_; lean_object* v___x_443_; lean_object* v___x_444_; lean_object* v___x_445_; lean_object* v___x_446_; lean_object* v___x_447_; lean_object* v___x_448_; lean_object* v___x_449_; lean_object* v___x_450_; 
v_output_377_ = lean_ctor_get(v_x_376_, 0);
lean_inc(v_output_377_);
v_remaining_378_ = lean_ctor_get(v_x_376_, 1);
lean_inc(v_remaining_378_);
v_pending_379_ = lean_ctor_get(v_x_376_, 2);
lean_inc(v_pending_379_);
v_status_380_ = lean_ctor_get(v_x_376_, 3);
lean_inc(v_status_380_);
v_readCalls_381_ = lean_ctor_get(v_x_376_, 4);
lean_inc(v_readCalls_381_);
v_writeCalls_382_ = lean_ctor_get(v_x_376_, 5);
lean_inc(v_writeCalls_382_);
lean_dec_ref(v_x_376_);
v___x_383_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__5));
v___x_384_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__6));
v___x_385_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__7);
v___x_386_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_output_377_);
v___x_387_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_387_, 0, v___x_385_);
lean_ctor_set(v___x_387_, 1, v___x_386_);
v___x_388_ = 0;
v___x_389_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_389_, 0, v___x_387_);
lean_ctor_set_uint8(v___x_389_, sizeof(void*)*1, v___x_388_);
v___x_390_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_390_, 0, v___x_384_);
lean_ctor_set(v___x_390_, 1, v___x_389_);
v___x_391_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__9));
v___x_392_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_392_, 0, v___x_390_);
lean_ctor_set(v___x_392_, 1, v___x_391_);
v___x_393_ = lean_box(1);
v___x_394_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_394_, 0, v___x_392_);
lean_ctor_set(v___x_394_, 1, v___x_393_);
v___x_395_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__11));
v___x_396_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_396_, 0, v___x_394_);
lean_ctor_set(v___x_396_, 1, v___x_395_);
v___x_397_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_397_, 0, v___x_396_);
lean_ctor_set(v___x_397_, 1, v___x_383_);
v___x_398_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__12);
v___x_399_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_remaining_378_);
v___x_400_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_400_, 0, v___x_398_);
lean_ctor_set(v___x_400_, 1, v___x_399_);
v___x_401_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_401_, 0, v___x_400_);
lean_ctor_set_uint8(v___x_401_, sizeof(void*)*1, v___x_388_);
v___x_402_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_402_, 0, v___x_397_);
lean_ctor_set(v___x_402_, 1, v___x_401_);
v___x_403_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_403_, 0, v___x_402_);
lean_ctor_set(v___x_403_, 1, v___x_391_);
v___x_404_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_404_, 0, v___x_403_);
lean_ctor_set(v___x_404_, 1, v___x_393_);
v___x_405_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__1));
v___x_406_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_406_, 0, v___x_404_);
lean_ctor_set(v___x_406_, 1, v___x_405_);
v___x_407_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_407_, 0, v___x_406_);
lean_ctor_set(v___x_407_, 1, v___x_383_);
v___x_408_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2, &lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2_once, _init_lp_shell__lean__final_BufferRelay_instReprDrainResult_repr___redArg___closed__2);
v___x_409_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_pending_379_);
v___x_410_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_410_, 0, v___x_408_);
lean_ctor_set(v___x_410_, 1, v___x_409_);
v___x_411_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_411_, 0, v___x_410_);
lean_ctor_set_uint8(v___x_411_, sizeof(void*)*1, v___x_388_);
v___x_412_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_412_, 0, v___x_407_);
lean_ctor_set(v___x_412_, 1, v___x_411_);
v___x_413_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_413_, 0, v___x_412_);
lean_ctor_set(v___x_413_, 1, v___x_391_);
v___x_414_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_414_, 0, v___x_413_);
lean_ctor_set(v___x_414_, 1, v___x_393_);
v___x_415_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__14));
v___x_416_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_416_, 0, v___x_414_);
lean_ctor_set(v___x_416_, 1, v___x_415_);
v___x_417_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_417_, 0, v___x_416_);
lean_ctor_set(v___x_417_, 1, v___x_383_);
v___x_418_ = l_Nat_reprFast(v_status_380_);
v___x_419_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_419_, 0, v___x_418_);
v___x_420_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_420_, 0, v___x_385_);
lean_ctor_set(v___x_420_, 1, v___x_419_);
v___x_421_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_421_, 0, v___x_420_);
lean_ctor_set_uint8(v___x_421_, sizeof(void*)*1, v___x_388_);
v___x_422_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_422_, 0, v___x_417_);
lean_ctor_set(v___x_422_, 1, v___x_421_);
v___x_423_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_423_, 0, v___x_422_);
lean_ctor_set(v___x_423_, 1, v___x_391_);
v___x_424_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_424_, 0, v___x_423_);
lean_ctor_set(v___x_424_, 1, v___x_393_);
v___x_425_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__16));
v___x_426_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_426_, 0, v___x_424_);
lean_ctor_set(v___x_426_, 1, v___x_425_);
v___x_427_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_427_, 0, v___x_426_);
lean_ctor_set(v___x_427_, 1, v___x_383_);
v___x_428_ = l_Nat_reprFast(v_readCalls_381_);
v___x_429_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_429_, 0, v___x_428_);
v___x_430_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_430_, 0, v___x_398_);
lean_ctor_set(v___x_430_, 1, v___x_429_);
v___x_431_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_431_, 0, v___x_430_);
lean_ctor_set_uint8(v___x_431_, sizeof(void*)*1, v___x_388_);
v___x_432_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_432_, 0, v___x_427_);
lean_ctor_set(v___x_432_, 1, v___x_431_);
v___x_433_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_433_, 0, v___x_432_);
lean_ctor_set(v___x_433_, 1, v___x_391_);
v___x_434_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_434_, 0, v___x_433_);
lean_ctor_set(v___x_434_, 1, v___x_393_);
v___x_435_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__18));
v___x_436_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_436_, 0, v___x_434_);
lean_ctor_set(v___x_436_, 1, v___x_435_);
v___x_437_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_437_, 0, v___x_436_);
lean_ctor_set(v___x_437_, 1, v___x_383_);
v___x_438_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__19);
v___x_439_ = l_Nat_reprFast(v_writeCalls_382_);
v___x_440_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_440_, 0, v___x_439_);
v___x_441_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_441_, 0, v___x_438_);
lean_ctor_set(v___x_441_, 1, v___x_440_);
v___x_442_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_442_, 0, v___x_441_);
lean_ctor_set_uint8(v___x_442_, sizeof(void*)*1, v___x_388_);
v___x_443_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_443_, 0, v___x_437_);
lean_ctor_set(v___x_443_, 1, v___x_442_);
v___x_444_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22, &lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22_once, _init_lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__22);
v___x_445_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__23));
v___x_446_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_446_, 0, v___x_445_);
lean_ctor_set(v___x_446_, 1, v___x_443_);
v___x_447_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_instReprOutcome_repr___redArg___closed__24));
v___x_448_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_448_, 0, v___x_446_);
lean_ctor_set(v___x_448_, 1, v___x_447_);
v___x_449_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_449_, 0, v___x_444_);
lean_ctor_set(v___x_449_, 1, v___x_448_);
v___x_450_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_450_, 0, v___x_449_);
lean_ctor_set_uint8(v___x_450_, sizeof(void*)*1, v___x_388_);
return v___x_450_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr(lean_object* v_x_451_, lean_object* v_prec_452_){
_start:
{
lean_object* v___x_453_; 
v___x_453_ = lp_shell__lean__final_BufferRelay_instReprDetailed_repr___redArg(v_x_451_);
return v___x_453_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instReprDetailed_repr___boxed(lean_object* v_x_454_, lean_object* v_prec_455_){
_start:
{
lean_object* v_res_456_; 
v_res_456_ = lp_shell__lean__final_BufferRelay_instReprDetailed_repr(v_x_454_, v_prec_455_);
lean_dec(v_prec_455_);
return v_res_456_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq(lean_object* v_x_459_, lean_object* v_x_460_){
_start:
{
lean_object* v_output_461_; lean_object* v_remaining_462_; lean_object* v_pending_463_; lean_object* v_status_464_; lean_object* v_readCalls_465_; lean_object* v_writeCalls_466_; lean_object* v_output_467_; lean_object* v_remaining_468_; lean_object* v_pending_469_; lean_object* v_status_470_; lean_object* v_readCalls_471_; lean_object* v_writeCalls_472_; lean_object* v___x_473_; uint8_t v___x_474_; 
v_output_461_ = lean_ctor_get(v_x_459_, 0);
lean_inc(v_output_461_);
v_remaining_462_ = lean_ctor_get(v_x_459_, 1);
lean_inc(v_remaining_462_);
v_pending_463_ = lean_ctor_get(v_x_459_, 2);
lean_inc(v_pending_463_);
v_status_464_ = lean_ctor_get(v_x_459_, 3);
lean_inc(v_status_464_);
v_readCalls_465_ = lean_ctor_get(v_x_459_, 4);
lean_inc(v_readCalls_465_);
v_writeCalls_466_ = lean_ctor_get(v_x_459_, 5);
lean_inc(v_writeCalls_466_);
lean_dec_ref(v_x_459_);
v_output_467_ = lean_ctor_get(v_x_460_, 0);
lean_inc(v_output_467_);
v_remaining_468_ = lean_ctor_get(v_x_460_, 1);
lean_inc(v_remaining_468_);
v_pending_469_ = lean_ctor_get(v_x_460_, 2);
lean_inc(v_pending_469_);
v_status_470_ = lean_ctor_get(v_x_460_, 3);
lean_inc(v_status_470_);
v_readCalls_471_ = lean_ctor_get(v_x_460_, 4);
lean_inc(v_readCalls_471_);
v_writeCalls_472_ = lean_ctor_get(v_x_460_, 5);
lean_inc(v_writeCalls_472_);
lean_dec_ref(v_x_460_);
v___x_473_ = lean_alloc_closure((void*)(l_instDecidableEqUInt8___boxed), 2, 0);
lean_inc_ref(v___x_473_);
v___x_474_ = l_instDecidableEqList___redArg(v___x_473_, v_output_461_, v_output_467_);
if (v___x_474_ == 0)
{
lean_dec_ref(v___x_473_);
lean_dec(v_writeCalls_472_);
lean_dec(v_readCalls_471_);
lean_dec(v_status_470_);
lean_dec(v_pending_469_);
lean_dec(v_remaining_468_);
lean_dec(v_writeCalls_466_);
lean_dec(v_readCalls_465_);
lean_dec(v_status_464_);
lean_dec(v_pending_463_);
lean_dec(v_remaining_462_);
return v___x_474_;
}
else
{
uint8_t v___x_475_; 
lean_inc_ref(v___x_473_);
v___x_475_ = l_instDecidableEqList___redArg(v___x_473_, v_remaining_462_, v_remaining_468_);
if (v___x_475_ == 0)
{
lean_dec_ref(v___x_473_);
lean_dec(v_writeCalls_472_);
lean_dec(v_readCalls_471_);
lean_dec(v_status_470_);
lean_dec(v_pending_469_);
lean_dec(v_writeCalls_466_);
lean_dec(v_readCalls_465_);
lean_dec(v_status_464_);
lean_dec(v_pending_463_);
return v___x_475_;
}
else
{
uint8_t v___x_476_; 
v___x_476_ = l_instDecidableEqList___redArg(v___x_473_, v_pending_463_, v_pending_469_);
if (v___x_476_ == 0)
{
lean_dec(v_writeCalls_472_);
lean_dec(v_readCalls_471_);
lean_dec(v_status_470_);
lean_dec(v_writeCalls_466_);
lean_dec(v_readCalls_465_);
lean_dec(v_status_464_);
return v___x_476_;
}
else
{
uint8_t v___x_477_; 
v___x_477_ = lean_nat_dec_eq(v_status_464_, v_status_470_);
lean_dec(v_status_470_);
lean_dec(v_status_464_);
if (v___x_477_ == 0)
{
lean_dec(v_writeCalls_472_);
lean_dec(v_readCalls_471_);
lean_dec(v_writeCalls_466_);
lean_dec(v_readCalls_465_);
return v___x_477_;
}
else
{
uint8_t v___x_478_; 
v___x_478_ = lean_nat_dec_eq(v_readCalls_465_, v_readCalls_471_);
lean_dec(v_readCalls_471_);
lean_dec(v_readCalls_465_);
if (v___x_478_ == 0)
{
lean_dec(v_writeCalls_472_);
lean_dec(v_writeCalls_466_);
return v___x_478_;
}
else
{
uint8_t v___x_479_; 
v___x_479_ = lean_nat_dec_eq(v_writeCalls_466_, v_writeCalls_472_);
lean_dec(v_writeCalls_472_);
lean_dec(v_writeCalls_466_);
return v___x_479_;
}
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq___boxed(lean_object* v_x_480_, lean_object* v_x_481_){
_start:
{
uint8_t v_res_482_; lean_object* v_r_483_; 
v_res_482_ = lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq(v_x_480_, v_x_481_);
v_r_483_ = lean_box(v_res_482_);
return v_r_483_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_instDecidableEqDetailed(lean_object* v_x_484_, lean_object* v_x_485_){
_start:
{
uint8_t v___x_486_; 
v___x_486_ = lp_shell__lean__final_BufferRelay_instDecidableEqDetailed_decEq(v_x_484_, v_x_485_);
return v___x_486_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_instDecidableEqDetailed___boxed(lean_object* v_x_487_, lean_object* v_x_488_){
_start:
{
uint8_t v_res_489_; lean_object* v_r_490_; 
v_res_489_ = lp_shell__lean__final_BufferRelay_instDecidableEqDetailed(v_x_487_, v_x_488_);
v_r_490_ = lean_box(v_res_489_);
return v_r_490_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_fill(lean_object* v_mem_491_, lean_object* v_input_492_, lean_object* v_q_493_, lean_object* v_a_494_){
_start:
{
lean_object* v___x_495_; lean_object* v___x_496_; lean_object* v___x_497_; lean_object* v___x_498_; uint8_t v___x_499_; 
v___x_495_ = lean_unsigned_to_nat(0u);
v___x_496_ = lp_shell__lean__final_BufferRelay_readAmount(v_input_492_, v_q_493_);
v___x_497_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_drain___closed__0));
lean_inc(v_input_492_);
v___x_498_ = l___private_Init_Data_List_Impl_0__List_takeTR_go___redArg(v_input_492_, v_input_492_, v___x_496_, v___x_497_);
lean_dec(v_input_492_);
v___x_499_ = lp_shell__lean__final_MemoryTransfer_store___redArg(v_mem_491_, v___x_495_, v___x_498_, v_a_494_);
lean_dec(v___x_498_);
return v___x_499_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_fill___boxed(lean_object* v_mem_500_, lean_object* v_input_501_, lean_object* v_q_502_, lean_object* v_a_503_){
_start:
{
uint8_t v_res_504_; lean_object* v_r_505_; 
v_res_504_ = lp_shell__lean__final_BufferRelay_fill(v_mem_500_, v_input_501_, v_q_502_, v_a_503_);
lean_dec(v_q_502_);
v_r_505_ = lean_box(v_res_504_);
return v_r_505_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_loaded(lean_object* v_mem_506_, lean_object* v_input_507_, lean_object* v_q_508_){
_start:
{
lean_object* v___x_509_; lean_object* v___x_510_; lean_object* v___x_511_; lean_object* v___x_512_; 
lean_inc(v_q_508_);
lean_inc(v_input_507_);
v___x_509_ = lean_alloc_closure((void*)(lp_shell__lean__final_BufferRelay_fill___boxed), 4, 3);
lean_closure_set(v___x_509_, 0, v_mem_506_);
lean_closure_set(v___x_509_, 1, v_input_507_);
lean_closure_set(v___x_509_, 2, v_q_508_);
v___x_510_ = lean_unsigned_to_nat(0u);
v___x_511_ = lp_shell__lean__final_BufferRelay_readAmount(v_input_507_, v_q_508_);
lean_dec(v_q_508_);
lean_dec(v_input_507_);
v___x_512_ = lp_shell__lean__final_MemoryTransfer_load___redArg(v___x_509_, v___x_510_, v___x_511_);
return v___x_512_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_execute(lean_object* v_mem_517_, lean_object* v_input_518_, lean_object* v_reads_519_, lean_object* v_writes_520_){
_start:
{
lean_object* v___x_521_; lean_object* v___x_522_; lean_object* v_fst_523_; lean_object* v_snd_524_; lean_object* v___x_525_; lean_object* v___x_526_; uint8_t v___x_527_; 
v___x_521_ = lean_unsigned_to_nat(32u);
v___x_522_ = lp_shell__lean__final_BufferRelay_action(v___x_521_, v_reads_519_);
v_fst_523_ = lean_ctor_get(v___x_522_, 0);
lean_inc(v_fst_523_);
v_snd_524_ = lean_ctor_get(v___x_522_, 1);
lean_inc(v_snd_524_);
lean_dec_ref(v___x_522_);
v___x_525_ = lean_unsigned_to_nat(0u);
v___x_526_ = lean_obj_once(&lp_shell__lean__final_BufferRelay_drain___closed__1, &lp_shell__lean__final_BufferRelay_drain___closed__1_once, _init_lp_shell__lean__final_BufferRelay_drain___closed__1);
v___x_527_ = lean_int_dec_lt(v_fst_523_, v___x_526_);
if (v___x_527_ == 0)
{
uint8_t v___x_528_; 
v___x_528_ = l_List_instDecidableEqNil___redArg(v_input_518_);
if (v___x_528_ == 0)
{
lean_object* v_k_529_; lean_object* v_nextMem_530_; lean_object* v___x_531_; lean_object* v_d_532_; uint8_t v_failed_533_; 
v_k_529_ = lp_shell__lean__final_BufferRelay_readAmount(v_input_518_, v_fst_523_);
lean_inc(v_fst_523_);
lean_inc_n(v_input_518_, 2);
lean_inc_ref(v_mem_517_);
v_nextMem_530_ = lean_alloc_closure((void*)(lp_shell__lean__final_BufferRelay_fill___boxed), 4, 3);
lean_closure_set(v_nextMem_530_, 0, v_mem_517_);
lean_closure_set(v_nextMem_530_, 1, v_input_518_);
lean_closure_set(v_nextMem_530_, 2, v_fst_523_);
v___x_531_ = lp_shell__lean__final_BufferRelay_loaded(v_mem_517_, v_input_518_, v_fst_523_);
v_d_532_ = lp_shell__lean__final_BufferRelay_drain(v___x_531_, v_writes_520_);
v_failed_533_ = lean_ctor_get_uint8(v_d_532_, sizeof(void*)*4);
if (v_failed_533_ == 0)
{
lean_object* v_output_534_; lean_object* v_writes_535_; lean_object* v_calls_536_; lean_object* v___x_537_; lean_object* v_r_538_; lean_object* v_output_539_; lean_object* v_remaining_540_; lean_object* v_pending_541_; lean_object* v_status_542_; lean_object* v_readCalls_543_; lean_object* v_writeCalls_544_; lean_object* v___x_546_; uint8_t v_isShared_547_; uint8_t v_isSharedCheck_555_; 
v_output_534_ = lean_ctor_get(v_d_532_, 0);
lean_inc(v_output_534_);
v_writes_535_ = lean_ctor_get(v_d_532_, 2);
lean_inc(v_writes_535_);
v_calls_536_ = lean_ctor_get(v_d_532_, 3);
lean_inc(v_calls_536_);
lean_dec_ref(v_d_532_);
v___x_537_ = l_List_drop___redArg(v_k_529_, v_input_518_);
lean_dec(v_input_518_);
v_r_538_ = lp_shell__lean__final_BufferRelay_execute(v_nextMem_530_, v___x_537_, v_snd_524_, v_writes_535_);
v_output_539_ = lean_ctor_get(v_r_538_, 0);
v_remaining_540_ = lean_ctor_get(v_r_538_, 1);
v_pending_541_ = lean_ctor_get(v_r_538_, 2);
v_status_542_ = lean_ctor_get(v_r_538_, 3);
v_readCalls_543_ = lean_ctor_get(v_r_538_, 4);
v_writeCalls_544_ = lean_ctor_get(v_r_538_, 5);
v_isSharedCheck_555_ = !lean_is_exclusive(v_r_538_);
if (v_isSharedCheck_555_ == 0)
{
v___x_546_ = v_r_538_;
v_isShared_547_ = v_isSharedCheck_555_;
goto v_resetjp_545_;
}
else
{
lean_inc(v_writeCalls_544_);
lean_inc(v_readCalls_543_);
lean_inc(v_status_542_);
lean_inc(v_pending_541_);
lean_inc(v_remaining_540_);
lean_inc(v_output_539_);
lean_dec(v_r_538_);
v___x_546_ = lean_box(0);
v_isShared_547_ = v_isSharedCheck_555_;
goto v_resetjp_545_;
}
v_resetjp_545_:
{
lean_object* v___x_548_; lean_object* v___x_549_; lean_object* v___x_550_; lean_object* v___x_551_; lean_object* v___x_553_; 
v___x_548_ = l_List_appendTR___redArg(v_output_534_, v_output_539_);
v___x_549_ = lean_unsigned_to_nat(1u);
v___x_550_ = lean_nat_add(v_readCalls_543_, v___x_549_);
lean_dec(v_readCalls_543_);
v___x_551_ = lean_nat_add(v_calls_536_, v_writeCalls_544_);
lean_dec(v_writeCalls_544_);
lean_dec(v_calls_536_);
if (v_isShared_547_ == 0)
{
lean_ctor_set(v___x_546_, 5, v___x_551_);
lean_ctor_set(v___x_546_, 4, v___x_550_);
lean_ctor_set(v___x_546_, 0, v___x_548_);
v___x_553_ = v___x_546_;
goto v_reusejp_552_;
}
else
{
lean_object* v_reuseFailAlloc_554_; 
v_reuseFailAlloc_554_ = lean_alloc_ctor(0, 6, 0);
lean_ctor_set(v_reuseFailAlloc_554_, 0, v___x_548_);
lean_ctor_set(v_reuseFailAlloc_554_, 1, v_remaining_540_);
lean_ctor_set(v_reuseFailAlloc_554_, 2, v_pending_541_);
lean_ctor_set(v_reuseFailAlloc_554_, 3, v_status_542_);
lean_ctor_set(v_reuseFailAlloc_554_, 4, v___x_550_);
lean_ctor_set(v_reuseFailAlloc_554_, 5, v___x_551_);
v___x_553_ = v_reuseFailAlloc_554_;
goto v_reusejp_552_;
}
v_reusejp_552_:
{
return v___x_553_;
}
}
}
else
{
lean_object* v_output_556_; lean_object* v_pending_557_; lean_object* v_calls_558_; lean_object* v___x_559_; lean_object* v___x_560_; lean_object* v___x_561_; lean_object* v___x_562_; 
lean_dec_ref(v_nextMem_530_);
lean_dec(v_snd_524_);
v_output_556_ = lean_ctor_get(v_d_532_, 0);
lean_inc(v_output_556_);
v_pending_557_ = lean_ctor_get(v_d_532_, 1);
lean_inc(v_pending_557_);
v_calls_558_ = lean_ctor_get(v_d_532_, 3);
lean_inc(v_calls_558_);
lean_dec_ref(v_d_532_);
v___x_559_ = l_List_drop___redArg(v_k_529_, v_input_518_);
lean_dec(v_input_518_);
v___x_560_ = lean_unsigned_to_nat(2u);
v___x_561_ = lean_unsigned_to_nat(1u);
v___x_562_ = lean_alloc_ctor(0, 6, 0);
lean_ctor_set(v___x_562_, 0, v_output_556_);
lean_ctor_set(v___x_562_, 1, v___x_559_);
lean_ctor_set(v___x_562_, 2, v_pending_557_);
lean_ctor_set(v___x_562_, 3, v___x_560_);
lean_ctor_set(v___x_562_, 4, v___x_561_);
lean_ctor_set(v___x_562_, 5, v_calls_558_);
return v___x_562_;
}
}
else
{
lean_object* v___x_563_; 
lean_dec(v_snd_524_);
lean_dec(v_fst_523_);
lean_dec(v_writes_520_);
lean_dec(v_input_518_);
lean_dec_ref(v_mem_517_);
v___x_563_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_execute___closed__0));
return v___x_563_;
}
}
else
{
lean_object* v___x_564_; lean_object* v___x_565_; lean_object* v___x_566_; 
lean_dec(v_snd_524_);
lean_dec(v_fst_523_);
lean_dec(v_writes_520_);
lean_dec_ref(v_mem_517_);
v___x_564_ = lean_box(0);
v___x_565_ = lean_unsigned_to_nat(1u);
v___x_566_ = lean_alloc_ctor(0, 6, 0);
lean_ctor_set(v___x_566_, 0, v___x_564_);
lean_ctor_set(v___x_566_, 1, v_input_518_);
lean_ctor_set(v___x_566_, 2, v___x_564_);
lean_ctor_set(v___x_566_, 3, v___x_565_);
lean_ctor_set(v___x_566_, 4, v___x_565_);
lean_ctor_set(v___x_566_, 5, v___x_525_);
return v___x_566_;
}
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_BufferRelay_runDetailed___lam__0(lean_object* v_x_567_){
_start:
{
uint8_t v___x_568_; 
v___x_568_ = 0;
return v___x_568_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_runDetailed___lam__0___boxed(lean_object* v_x_569_){
_start:
{
uint8_t v_res_570_; lean_object* v_r_571_; 
v_res_570_ = lp_shell__lean__final_BufferRelay_runDetailed___lam__0(v_x_569_);
lean_dec(v_x_569_);
v_r_571_ = lean_box(v_res_570_);
return v_r_571_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_runDetailed(lean_object* v_input_573_, lean_object* v_reads_574_, lean_object* v_writes_575_){
_start:
{
lean_object* v___f_576_; lean_object* v___x_577_; 
v___f_576_ = ((lean_object*)(lp_shell__lean__final_BufferRelay_runDetailed___closed__0));
v___x_577_ = lp_shell__lean__final_BufferRelay_execute(v___f_576_, v_input_573_, v_reads_574_, v_writes_575_);
return v___x_577_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_BufferRelay_run(lean_object* v_input_578_, lean_object* v_reads_579_, lean_object* v_writes_580_){
_start:
{
lean_object* v_r_581_; lean_object* v_output_582_; lean_object* v_remaining_583_; lean_object* v_status_584_; lean_object* v_readCalls_585_; lean_object* v_writeCalls_586_; lean_object* v___x_587_; 
v_r_581_ = lp_shell__lean__final_BufferRelay_runDetailed(v_input_578_, v_reads_579_, v_writes_580_);
v_output_582_ = lean_ctor_get(v_r_581_, 0);
lean_inc(v_output_582_);
v_remaining_583_ = lean_ctor_get(v_r_581_, 1);
lean_inc(v_remaining_583_);
v_status_584_ = lean_ctor_get(v_r_581_, 3);
lean_inc(v_status_584_);
v_readCalls_585_ = lean_ctor_get(v_r_581_, 4);
lean_inc(v_readCalls_585_);
v_writeCalls_586_ = lean_ctor_get(v_r_581_, 5);
lean_inc(v_writeCalls_586_);
lean_dec_ref(v_r_581_);
v___x_587_ = lean_alloc_ctor(0, 5, 0);
lean_ctor_set(v___x_587_, 0, v_output_582_);
lean_ctor_set(v___x_587_, 1, v_remaining_583_);
lean_ctor_set(v___x_587_, 2, v_status_584_);
lean_ctor_set(v___x_587_, 3, v_readCalls_585_);
lean_ctor_set(v___x_587_, 4, v_writeCalls_586_);
return v___x_587_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_action_match__1_splitter___redArg(lean_object* v_x_588_, lean_object* v_h__1_589_, lean_object* v_h__2_590_){
_start:
{
if (lean_obj_tag(v_x_588_) == 0)
{
lean_object* v___x_591_; lean_object* v___x_592_; 
lean_dec(v_h__2_590_);
v___x_591_ = lean_box(0);
v___x_592_ = lean_apply_1(v_h__1_589_, v___x_591_);
return v___x_592_;
}
else
{
lean_object* v_head_593_; lean_object* v_tail_594_; lean_object* v___x_595_; 
lean_dec(v_h__1_589_);
v_head_593_ = lean_ctor_get(v_x_588_, 0);
lean_inc(v_head_593_);
v_tail_594_ = lean_ctor_get(v_x_588_, 1);
lean_inc(v_tail_594_);
lean_dec_ref_known(v_x_588_, 2);
v___x_595_ = lean_apply_2(v_h__2_590_, v_head_593_, v_tail_594_);
return v___x_595_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_BufferRelay_0__BufferRelay_action_match__1_splitter(lean_object* v_motive_596_, lean_object* v_x_597_, lean_object* v_h__1_598_, lean_object* v_h__2_599_){
_start:
{
if (lean_obj_tag(v_x_597_) == 0)
{
lean_object* v___x_600_; lean_object* v___x_601_; 
lean_dec(v_h__2_599_);
v___x_600_ = lean_box(0);
v___x_601_ = lean_apply_1(v_h__1_598_, v___x_600_);
return v___x_601_;
}
else
{
lean_object* v_head_602_; lean_object* v_tail_603_; lean_object* v___x_604_; 
lean_dec(v_h__1_598_);
v_head_602_ = lean_ctor_get(v_x_597_, 0);
lean_inc(v_head_602_);
v_tail_603_ = lean_ctor_get(v_x_597_, 1);
lean_inc(v_tail_603_);
lean_dec_ref_known(v_x_597_, 2);
v___x_604_ = lean_apply_2(v_h__2_599_, v_head_602_, v_tail_603_);
return v___x_604_;
}
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_shell__lean__final_MemoryTransfer(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_shell__lean__final_BufferRelay(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_shell__lean__final_MemoryTransfer(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif

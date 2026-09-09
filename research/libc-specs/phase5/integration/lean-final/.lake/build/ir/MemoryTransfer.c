// Lean compiler output
// Module: MemoryTransfer
// Imports: public import Init public meta import Init public import Std
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
lean_object* lean_string_length(lean_object*);
lean_object* lean_nat_to_int(lean_object*);
lean_object* l_Repr_addAppParen(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
lean_object* l_Std_Format_joinSep___at___00Array_repr___at___00Std_Time_TimeZone_TZif_instReprTZifV1_repr_spec__1_spec__2(lean_object*, lean_object*);
lean_object* l_Std_Format_fill(lean_object*);
lean_object* l_Nat_reprFast(lean_object*);
lean_object* lean_nat_sub(lean_object*, lean_object*);
lean_object* l_List_lengthTR___redArg(lean_object*);
uint8_t lean_nat_dec_lt(lean_object*, lean_object*);
lean_object* l_List_get___redArg(lean_object*, lean_object*);
lean_object* lean_nat_add(lean_object*, lean_object*);
lean_object* l_List_ofFn___redArg(lean_object*, lean_object*);
lean_object* l_List_appendTR___redArg(lean_object*, lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* l_instDecidableEqUInt8___boxed(lean_object*, lean_object*);
uint8_t l_instDecidableEqList___redArg(lean_object*, lean_object*, lean_object*);
lean_object* lean_mk_empty_array_with_capacity(lean_object*);
lean_object* l___private_Init_Data_List_Impl_0__List_takeTR_go___redArg(lean_object*, lean_object*, lean_object*, lean_object*);
lean_object* l_List_drop___redArg(lean_object*, lean_object*);
uint8_t lean_nat_dec_le(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer___boxed(lean_object*, lean_object*);
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = "{ "};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__0_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 6, .m_capacity = 6, .m_length = 5, .m_data = "block"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__1 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__1_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__1_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__2 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__2_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__3 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__3_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 5, .m_capacity = 5, .m_length = 4, .m_data = " := "};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__4 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__4_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__4_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__5 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__5_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__3_value),((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__5_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__6 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__6_value;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = ","};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__8 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__8_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__9_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__8_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__9 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__9_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__10_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 7, .m_capacity = 7, .m_length = 6, .m_data = "offset"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__10 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__10_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__11_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__10_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__11 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__11_value;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__13_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = " }"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__13 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__13_value;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__16_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__0_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__16 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__16_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__17_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__13_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__17 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__17_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_MemoryTransfer_instReprPointer___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer___closed__0_value;
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableValid(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableValid___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_store___redArg(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_store___redArg___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_store(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_store___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0___boxed(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_toCtorIdx(uint8_t);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_toCtorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim(lean_object*, lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim(lean_object*, uint8_t, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_IOError_ofNat(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ofNat___boxed(lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError(uint8_t, uint8_t);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError___boxed(lean_object*, lean_object*);
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 35, .m_capacity = 35, .m_length = 34, .m_data = "MemoryTransfer.IOError.interrupted"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__0_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__1 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__1_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 35, .m_capacity = 35, .m_length = 34, .m_data = "MemoryTransfer.IOError.unavailable"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__2 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__2_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__3 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__3_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 30, .m_capacity = 30, .m_length = 29, .m_data = "MemoryTransfer.IOError.device"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__4 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__4_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__4_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__5 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__5_value;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6;
static lean_once_cell_t lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr(uint8_t, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_MemoryTransfer_instReprIOError___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprIOError___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorIdx(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_fail_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_fail_elim(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ready_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ready_elim(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment___boxed(lean_object*, lean_object*);
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 32, .m_capacity = 32, .m_length = 31, .m_data = "MemoryTransfer.Environment.fail"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__0_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__1 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__1_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__1_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__2 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__2_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 33, .m_capacity = 33, .m_length = 32, .m_data = "MemoryTransfer.Environment.ready"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__3 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__3_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__3_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__4 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__4_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__4_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__5 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__5_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_MemoryTransfer_instReprEnvironment___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprEnvironment___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_amount(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_amount___boxed(lean_object*, lean_object*, lean_object*);
static const lean_array_object lp_shell__lean__final_MemoryTransfer_afterRead___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_array_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 246}, .m_size = 0, .m_capacity = 0, .m_data = {}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_afterRead___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_afterRead___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_afterRead(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_read(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_read___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_MemoryTransfer_0__MemoryTransfer_instReprEnvironment_repr_match__1_splitter___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final___private_MemoryTransfer_0__MemoryTransfer_instReprEnvironment_repr_match__1_splitter(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit___redArg(lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0___boxed(lean_object*);
static const lean_closure_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0___boxed, .m_arity = 1, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(128) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__1 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__1_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(13) << 1) | 1)),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__1_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__2 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(10) << 1) | 1)),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__2_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__3 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__3_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(255) << 1) | 1)),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__3_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__4 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__4_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(0) << 1) | 1)),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__4_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__5 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__5_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(42) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__6 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__6_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*3 + 0, .m_other = 3, .m_tag = 0}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__0_value),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__5_value),((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__6_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__7 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__7_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_initial___closed__7_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorIdx(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorIdx___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ub_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ub_elim(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_error_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_error_elim(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ok_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ok_elim(lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq___boxed(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation___boxed(lean_object*, lean_object*);
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 3, .m_capacity = 3, .m_length = 2, .m_data = "[]"};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__0 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__0_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__1 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__1_value;
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = "["};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__2 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__9_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__3 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__3_value;
static const lean_string_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 2, .m_capacity = 2, .m_length = 1, .m_data = "]"};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__4 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__4_value;
static lean_once_cell_t lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5;
static lean_once_cell_t lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__2_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__7 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__7_value;
static const lean_ctor_object lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__8_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__4_value)}};
static const lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__8 = (const lean_object*)&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__8_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(lean_object*);
static const lean_string_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 39, .m_capacity = 39, .m_length = 38, .m_data = "MemoryTransfer.Examples.Observation.ub"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__0_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__1 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__1_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 42, .m_capacity = 42, .m_length = 41, .m_data = "MemoryTransfer.Examples.Observation.error"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__2 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__2_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__3_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__2_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__3 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__3_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__4_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__3_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__4 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__4_value;
static const lean_string_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__5_value = {.m_header = {.m_rc = 0, .m_cs_sz = 0, .m_other = 0, .m_tag = 249}, .m_size = 39, .m_capacity = 39, .m_length = 38, .m_data = "MemoryTransfer.Examples.Observation.ok"};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__5 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__5_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__6_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*1 + 0, .m_other = 1, .m_tag = 3}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__5_value)}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__6 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__6_value;
static const lean_ctor_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__7_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 5}, .m_objs = {((lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__6_value),((lean_object*)(((size_t)(1) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__7 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__7_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___boxed(lean_object*, lean_object*);
static const lean_closure_object lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_closure_object) + sizeof(void*)*0, .m_other = 0, .m_tag = 245}, .m_fun = (void*)lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___boxed, .m_arity = 2, .m_num_fixed = 0, .m_objs = {} };
static const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation___closed__0 = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation___closed__0_value;
LEAN_EXPORT const lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation = (const lean_object*)&lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_observe(lean_object*, lean_object*);
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq(lean_object* v_x_1_, lean_object* v_x_2_){
_start:
{
lean_object* v_block_3_; lean_object* v_offset_4_; lean_object* v_block_5_; lean_object* v_offset_6_; uint8_t v___x_7_; 
v_block_3_ = lean_ctor_get(v_x_1_, 0);
v_offset_4_ = lean_ctor_get(v_x_1_, 1);
v_block_5_ = lean_ctor_get(v_x_2_, 0);
v_offset_6_ = lean_ctor_get(v_x_2_, 1);
v___x_7_ = lean_nat_dec_eq(v_block_3_, v_block_5_);
if (v___x_7_ == 0)
{
return v___x_7_;
}
else
{
uint8_t v___x_8_; 
v___x_8_ = lean_nat_dec_eq(v_offset_4_, v_offset_6_);
return v___x_8_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq___boxed(lean_object* v_x_9_, lean_object* v_x_10_){
_start:
{
uint8_t v_res_11_; lean_object* v_r_12_; 
v_res_11_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq(v_x_9_, v_x_10_);
lean_dec_ref(v_x_10_);
lean_dec_ref(v_x_9_);
v_r_12_ = lean_box(v_res_11_);
return v_r_12_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer(lean_object* v_x_13_, lean_object* v_x_14_){
_start:
{
uint8_t v___x_15_; 
v___x_15_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer_decEq(v_x_13_, v_x_14_);
return v___x_15_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer___boxed(lean_object* v_x_16_, lean_object* v_x_17_){
_start:
{
uint8_t v_res_18_; lean_object* v_r_19_; 
v_res_18_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqPointer(v_x_16_, v_x_17_);
lean_dec_ref(v_x_17_);
lean_dec_ref(v_x_16_);
v_r_19_ = lean_box(v_res_18_);
return v_r_19_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7(void){
_start:
{
lean_object* v___x_33_; lean_object* v___x_34_; 
v___x_33_ = lean_unsigned_to_nat(9u);
v___x_34_ = lean_nat_to_int(v___x_33_);
return v___x_34_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12(void){
_start:
{
lean_object* v___x_41_; lean_object* v___x_42_; 
v___x_41_ = lean_unsigned_to_nat(10u);
v___x_42_ = lean_nat_to_int(v___x_41_);
return v___x_42_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14(void){
_start:
{
lean_object* v___x_44_; lean_object* v___x_45_; 
v___x_44_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__0));
v___x_45_ = lean_string_length(v___x_44_);
return v___x_45_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15(void){
_start:
{
lean_object* v___x_46_; lean_object* v___x_47_; 
v___x_46_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14, &lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14_once, _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__14);
v___x_47_ = lean_nat_to_int(v___x_46_);
return v___x_47_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg(lean_object* v_x_52_){
_start:
{
lean_object* v_block_53_; lean_object* v_offset_54_; lean_object* v___x_56_; uint8_t v_isShared_57_; uint8_t v_isSharedCheck_89_; 
v_block_53_ = lean_ctor_get(v_x_52_, 0);
v_offset_54_ = lean_ctor_get(v_x_52_, 1);
v_isSharedCheck_89_ = !lean_is_exclusive(v_x_52_);
if (v_isSharedCheck_89_ == 0)
{
v___x_56_ = v_x_52_;
v_isShared_57_ = v_isSharedCheck_89_;
goto v_resetjp_55_;
}
else
{
lean_inc(v_offset_54_);
lean_inc(v_block_53_);
lean_dec(v_x_52_);
v___x_56_ = lean_box(0);
v_isShared_57_ = v_isSharedCheck_89_;
goto v_resetjp_55_;
}
v_resetjp_55_:
{
lean_object* v___x_58_; lean_object* v___x_59_; lean_object* v___x_60_; lean_object* v___x_61_; lean_object* v___x_62_; lean_object* v___x_64_; 
v___x_58_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__5));
v___x_59_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__6));
v___x_60_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__7);
v___x_61_ = l_Nat_reprFast(v_block_53_);
v___x_62_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_62_, 0, v___x_61_);
if (v_isShared_57_ == 0)
{
lean_ctor_set_tag(v___x_56_, 4);
lean_ctor_set(v___x_56_, 1, v___x_62_);
lean_ctor_set(v___x_56_, 0, v___x_60_);
v___x_64_ = v___x_56_;
goto v_reusejp_63_;
}
else
{
lean_object* v_reuseFailAlloc_88_; 
v_reuseFailAlloc_88_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v_reuseFailAlloc_88_, 0, v___x_60_);
lean_ctor_set(v_reuseFailAlloc_88_, 1, v___x_62_);
v___x_64_ = v_reuseFailAlloc_88_;
goto v_reusejp_63_;
}
v_reusejp_63_:
{
uint8_t v___x_65_; lean_object* v___x_66_; lean_object* v___x_67_; lean_object* v___x_68_; lean_object* v___x_69_; lean_object* v___x_70_; lean_object* v___x_71_; lean_object* v___x_72_; lean_object* v___x_73_; lean_object* v___x_74_; lean_object* v___x_75_; lean_object* v___x_76_; lean_object* v___x_77_; lean_object* v___x_78_; lean_object* v___x_79_; lean_object* v___x_80_; lean_object* v___x_81_; lean_object* v___x_82_; lean_object* v___x_83_; lean_object* v___x_84_; lean_object* v___x_85_; lean_object* v___x_86_; lean_object* v___x_87_; 
v___x_65_ = 0;
v___x_66_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_66_, 0, v___x_64_);
lean_ctor_set_uint8(v___x_66_, sizeof(void*)*1, v___x_65_);
v___x_67_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_67_, 0, v___x_59_);
lean_ctor_set(v___x_67_, 1, v___x_66_);
v___x_68_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__9));
v___x_69_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_69_, 0, v___x_67_);
lean_ctor_set(v___x_69_, 1, v___x_68_);
v___x_70_ = lean_box(1);
v___x_71_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_71_, 0, v___x_69_);
lean_ctor_set(v___x_71_, 1, v___x_70_);
v___x_72_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__11));
v___x_73_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_73_, 0, v___x_71_);
lean_ctor_set(v___x_73_, 1, v___x_72_);
v___x_74_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_74_, 0, v___x_73_);
lean_ctor_set(v___x_74_, 1, v___x_58_);
v___x_75_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12, &lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12_once, _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__12);
v___x_76_ = l_Nat_reprFast(v_offset_54_);
v___x_77_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_77_, 0, v___x_76_);
v___x_78_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_78_, 0, v___x_75_);
lean_ctor_set(v___x_78_, 1, v___x_77_);
v___x_79_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_79_, 0, v___x_78_);
lean_ctor_set_uint8(v___x_79_, sizeof(void*)*1, v___x_65_);
v___x_80_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_80_, 0, v___x_74_);
lean_ctor_set(v___x_80_, 1, v___x_79_);
v___x_81_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15, &lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15_once, _init_lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__15);
v___x_82_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__16));
v___x_83_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_83_, 0, v___x_82_);
lean_ctor_set(v___x_83_, 1, v___x_80_);
v___x_84_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg___closed__17));
v___x_85_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_85_, 0, v___x_83_);
lean_ctor_set(v___x_85_, 1, v___x_84_);
v___x_86_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_86_, 0, v___x_81_);
lean_ctor_set(v___x_86_, 1, v___x_85_);
v___x_87_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_87_, 0, v___x_86_);
lean_ctor_set_uint8(v___x_87_, sizeof(void*)*1, v___x_65_);
return v___x_87_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr(lean_object* v_x_90_, lean_object* v_prec_91_){
_start:
{
lean_object* v___x_92_; 
v___x_92_ = lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___redArg(v_x_90_);
return v___x_92_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprPointer_repr___boxed(lean_object* v_x_93_, lean_object* v_prec_94_){
_start:
{
lean_object* v_res_95_; 
v_res_95_ = lp_shell__lean__final_MemoryTransfer_instReprPointer_repr(v_x_93_, v_prec_94_);
lean_dec(v_prec_94_);
return v_res_95_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1(lean_object* v_block_98_, lean_object* v_size_99_, lean_object* v_p_100_, lean_object* v_n_101_){
_start:
{
lean_object* v_block_102_; lean_object* v_offset_103_; uint8_t v___x_104_; 
v_block_102_ = lean_ctor_get(v_p_100_, 0);
v_offset_103_ = lean_ctor_get(v_p_100_, 1);
v___x_104_ = lean_nat_dec_eq(v_block_102_, v_block_98_);
if (v___x_104_ == 0)
{
return v___x_104_;
}
else
{
lean_object* v___x_105_; uint8_t v___x_106_; 
v___x_105_ = lean_nat_add(v_offset_103_, v_n_101_);
v___x_106_ = lean_nat_dec_le(v___x_105_, v_size_99_);
lean_dec(v___x_105_);
return v___x_106_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1___boxed(lean_object* v_block_107_, lean_object* v_size_108_, lean_object* v_p_109_, lean_object* v_n_110_){
_start:
{
uint8_t v_res_111_; lean_object* v_r_112_; 
v_res_111_ = lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1(v_block_107_, v_size_108_, v_p_109_, v_n_110_);
lean_dec(v_n_110_);
lean_dec_ref(v_p_109_);
lean_dec(v_size_108_);
lean_dec(v_block_107_);
v_r_112_ = lean_box(v_res_111_);
return v_r_112_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableValid(lean_object* v_block_113_, lean_object* v_size_114_, lean_object* v_p_115_, lean_object* v_n_116_){
_start:
{
uint8_t v___x_117_; 
v___x_117_ = lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1(v_block_113_, v_size_114_, v_p_115_, v_n_116_);
return v___x_117_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableValid___boxed(lean_object* v_block_118_, lean_object* v_size_119_, lean_object* v_p_120_, lean_object* v_n_121_){
_start:
{
uint8_t v_res_122_; lean_object* v_r_123_; 
v_res_122_ = lp_shell__lean__final_MemoryTransfer_instDecidableValid(v_block_118_, v_size_119_, v_p_120_, v_n_121_);
lean_dec(v_n_121_);
lean_dec_ref(v_p_120_);
lean_dec(v_size_119_);
lean_dec(v_block_118_);
v_r_123_ = lean_box(v_res_122_);
return v_r_123_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_store___redArg(lean_object* v_m_124_, lean_object* v_off_125_, lean_object* v_xs_126_, lean_object* v_i_127_){
_start:
{
uint8_t v___x_128_; 
v___x_128_ = lean_nat_dec_le(v_off_125_, v_i_127_);
if (v___x_128_ == 0)
{
lean_object* v___x_129_; uint8_t v___x_130_; 
v___x_129_ = lean_apply_1(v_m_124_, v_i_127_);
v___x_130_ = lean_unbox(v___x_129_);
return v___x_130_;
}
else
{
lean_object* v___x_131_; lean_object* v___x_132_; uint8_t v___x_133_; 
v___x_131_ = lean_nat_sub(v_i_127_, v_off_125_);
v___x_132_ = l_List_lengthTR___redArg(v_xs_126_);
v___x_133_ = lean_nat_dec_lt(v___x_131_, v___x_132_);
lean_dec(v___x_132_);
if (v___x_133_ == 0)
{
lean_object* v___x_134_; uint8_t v___x_135_; 
lean_dec(v___x_131_);
v___x_134_ = lean_apply_1(v_m_124_, v_i_127_);
v___x_135_ = lean_unbox(v___x_134_);
return v___x_135_;
}
else
{
lean_object* v___x_136_; uint8_t v___x_137_; 
lean_dec(v_i_127_);
lean_dec_ref(v_m_124_);
v___x_136_ = l_List_get___redArg(v_xs_126_, v___x_131_);
v___x_137_ = lean_unbox(v___x_136_);
lean_dec(v___x_136_);
return v___x_137_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_store___redArg___boxed(lean_object* v_m_138_, lean_object* v_off_139_, lean_object* v_xs_140_, lean_object* v_i_141_){
_start:
{
uint8_t v_res_142_; lean_object* v_r_143_; 
v_res_142_ = lp_shell__lean__final_MemoryTransfer_store___redArg(v_m_138_, v_off_139_, v_xs_140_, v_i_141_);
lean_dec(v_xs_140_);
lean_dec(v_off_139_);
v_r_143_ = lean_box(v_res_142_);
return v_r_143_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_store(lean_object* v_size_144_, lean_object* v_m_145_, lean_object* v_off_146_, lean_object* v_xs_147_, lean_object* v_i_148_){
_start:
{
uint8_t v___x_149_; 
v___x_149_ = lp_shell__lean__final_MemoryTransfer_store___redArg(v_m_145_, v_off_146_, v_xs_147_, v_i_148_);
return v___x_149_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_store___boxed(lean_object* v_size_150_, lean_object* v_m_151_, lean_object* v_off_152_, lean_object* v_xs_153_, lean_object* v_i_154_){
_start:
{
uint8_t v_res_155_; lean_object* v_r_156_; 
v_res_155_ = lp_shell__lean__final_MemoryTransfer_store(v_size_150_, v_m_151_, v_off_152_, v_xs_153_, v_i_154_);
lean_dec(v_xs_153_);
lean_dec(v_off_152_);
lean_dec(v_size_150_);
v_r_156_ = lean_box(v_res_155_);
return v_r_156_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0(lean_object* v_off_157_, lean_object* v_m_158_, lean_object* v_i_159_){
_start:
{
lean_object* v___x_160_; lean_object* v___x_161_; uint8_t v___x_162_; 
v___x_160_ = lean_nat_add(v_off_157_, v_i_159_);
v___x_161_ = lean_apply_1(v_m_158_, v___x_160_);
v___x_162_ = lean_unbox(v___x_161_);
return v___x_162_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0___boxed(lean_object* v_off_163_, lean_object* v_m_164_, lean_object* v_i_165_){
_start:
{
uint8_t v_res_166_; lean_object* v_r_167_; 
v_res_166_ = lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0(v_off_163_, v_m_164_, v_i_165_);
lean_dec(v_i_165_);
lean_dec(v_off_163_);
v_r_167_ = lean_box(v_res_166_);
return v_r_167_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___redArg(lean_object* v_m_168_, lean_object* v_off_169_, lean_object* v_n_170_){
_start:
{
lean_object* v___f_171_; lean_object* v___x_172_; 
v___f_171_ = lean_alloc_closure((void*)(lp_shell__lean__final_MemoryTransfer_load___redArg___lam__0___boxed), 3, 2);
lean_closure_set(v___f_171_, 0, v_off_169_);
lean_closure_set(v___f_171_, 1, v_m_168_);
v___x_172_ = l_List_ofFn___redArg(v_n_170_, v___f_171_);
return v___x_172_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load(lean_object* v_size_173_, lean_object* v_m_174_, lean_object* v_off_175_, lean_object* v_n_176_, lean_object* v_h_177_){
_start:
{
lean_object* v___x_178_; 
v___x_178_ = lp_shell__lean__final_MemoryTransfer_load___redArg(v_m_174_, v_off_175_, v_n_176_);
return v___x_178_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_load___boxed(lean_object* v_size_179_, lean_object* v_m_180_, lean_object* v_off_181_, lean_object* v_n_182_, lean_object* v_h_183_){
_start:
{
lean_object* v_res_184_; 
v_res_184_ = lp_shell__lean__final_MemoryTransfer_load(v_size_179_, v_m_180_, v_off_181_, v_n_182_, v_h_183_);
lean_dec(v_size_179_);
return v_res_184_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(uint8_t v_x_185_){
_start:
{
switch(v_x_185_)
{
case 0:
{
lean_object* v___x_186_; 
v___x_186_ = lean_unsigned_to_nat(0u);
return v___x_186_;
}
case 1:
{
lean_object* v___x_187_; 
v___x_187_ = lean_unsigned_to_nat(1u);
return v___x_187_;
}
default: 
{
lean_object* v___x_188_; 
v___x_188_ = lean_unsigned_to_nat(2u);
return v___x_188_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx___boxed(lean_object* v_x_189_){
_start:
{
uint8_t v_x_boxed_190_; lean_object* v_res_191_; 
v_x_boxed_190_ = lean_unbox(v_x_189_);
v_res_191_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(v_x_boxed_190_);
return v_res_191_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_toCtorIdx(uint8_t v_x_192_){
_start:
{
lean_object* v___x_193_; 
v___x_193_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(v_x_192_);
return v___x_193_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_toCtorIdx___boxed(lean_object* v_x_194_){
_start:
{
uint8_t v_x_4__boxed_195_; lean_object* v_res_196_; 
v_x_4__boxed_195_ = lean_unbox(v_x_194_);
v_res_196_ = lp_shell__lean__final_MemoryTransfer_IOError_toCtorIdx(v_x_4__boxed_195_);
return v_res_196_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___redArg(lean_object* v_k_197_){
_start:
{
lean_inc(v_k_197_);
return v_k_197_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___redArg___boxed(lean_object* v_k_198_){
_start:
{
lean_object* v_res_199_; 
v_res_199_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___redArg(v_k_198_);
lean_dec(v_k_198_);
return v_res_199_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim(lean_object* v_motive_200_, lean_object* v_ctorIdx_201_, uint8_t v_t_202_, lean_object* v_h_203_, lean_object* v_k_204_){
_start:
{
lean_inc(v_k_204_);
return v_k_204_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ctorElim___boxed(lean_object* v_motive_205_, lean_object* v_ctorIdx_206_, lean_object* v_t_207_, lean_object* v_h_208_, lean_object* v_k_209_){
_start:
{
uint8_t v_t_boxed_210_; lean_object* v_res_211_; 
v_t_boxed_210_ = lean_unbox(v_t_207_);
v_res_211_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorElim(v_motive_205_, v_ctorIdx_206_, v_t_boxed_210_, v_h_208_, v_k_209_);
lean_dec(v_k_209_);
lean_dec(v_ctorIdx_206_);
return v_res_211_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___redArg(lean_object* v_interrupted_212_){
_start:
{
lean_inc(v_interrupted_212_);
return v_interrupted_212_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___redArg___boxed(lean_object* v_interrupted_213_){
_start:
{
lean_object* v_res_214_; 
v_res_214_ = lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___redArg(v_interrupted_213_);
lean_dec(v_interrupted_213_);
return v_res_214_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim(lean_object* v_motive_215_, uint8_t v_t_216_, lean_object* v_h_217_, lean_object* v_interrupted_218_){
_start:
{
lean_inc(v_interrupted_218_);
return v_interrupted_218_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim___boxed(lean_object* v_motive_219_, lean_object* v_t_220_, lean_object* v_h_221_, lean_object* v_interrupted_222_){
_start:
{
uint8_t v_t_boxed_223_; lean_object* v_res_224_; 
v_t_boxed_223_ = lean_unbox(v_t_220_);
v_res_224_ = lp_shell__lean__final_MemoryTransfer_IOError_interrupted_elim(v_motive_219_, v_t_boxed_223_, v_h_221_, v_interrupted_222_);
lean_dec(v_interrupted_222_);
return v_res_224_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___redArg(lean_object* v_unavailable_225_){
_start:
{
lean_inc(v_unavailable_225_);
return v_unavailable_225_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___redArg___boxed(lean_object* v_unavailable_226_){
_start:
{
lean_object* v_res_227_; 
v_res_227_ = lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___redArg(v_unavailable_226_);
lean_dec(v_unavailable_226_);
return v_res_227_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim(lean_object* v_motive_228_, uint8_t v_t_229_, lean_object* v_h_230_, lean_object* v_unavailable_231_){
_start:
{
lean_inc(v_unavailable_231_);
return v_unavailable_231_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim___boxed(lean_object* v_motive_232_, lean_object* v_t_233_, lean_object* v_h_234_, lean_object* v_unavailable_235_){
_start:
{
uint8_t v_t_boxed_236_; lean_object* v_res_237_; 
v_t_boxed_236_ = lean_unbox(v_t_233_);
v_res_237_ = lp_shell__lean__final_MemoryTransfer_IOError_unavailable_elim(v_motive_232_, v_t_boxed_236_, v_h_234_, v_unavailable_235_);
lean_dec(v_unavailable_235_);
return v_res_237_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___redArg(lean_object* v_device_238_){
_start:
{
lean_inc(v_device_238_);
return v_device_238_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___redArg___boxed(lean_object* v_device_239_){
_start:
{
lean_object* v_res_240_; 
v_res_240_ = lp_shell__lean__final_MemoryTransfer_IOError_device_elim___redArg(v_device_239_);
lean_dec(v_device_239_);
return v_res_240_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim(lean_object* v_motive_241_, uint8_t v_t_242_, lean_object* v_h_243_, lean_object* v_device_244_){
_start:
{
lean_inc(v_device_244_);
return v_device_244_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_device_elim___boxed(lean_object* v_motive_245_, lean_object* v_t_246_, lean_object* v_h_247_, lean_object* v_device_248_){
_start:
{
uint8_t v_t_boxed_249_; lean_object* v_res_250_; 
v_t_boxed_249_ = lean_unbox(v_t_246_);
v_res_250_ = lp_shell__lean__final_MemoryTransfer_IOError_device_elim(v_motive_245_, v_t_boxed_249_, v_h_247_, v_device_248_);
lean_dec(v_device_248_);
return v_res_250_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_IOError_ofNat(lean_object* v_n_251_){
_start:
{
lean_object* v___x_252_; uint8_t v___x_253_; 
v___x_252_ = lean_unsigned_to_nat(0u);
v___x_253_ = lean_nat_dec_le(v_n_251_, v___x_252_);
if (v___x_253_ == 0)
{
lean_object* v___x_254_; uint8_t v___x_255_; 
v___x_254_ = lean_unsigned_to_nat(1u);
v___x_255_ = lean_nat_dec_le(v_n_251_, v___x_254_);
if (v___x_255_ == 0)
{
uint8_t v___x_256_; 
v___x_256_ = 2;
return v___x_256_;
}
else
{
uint8_t v___x_257_; 
v___x_257_ = 1;
return v___x_257_;
}
}
else
{
uint8_t v___x_258_; 
v___x_258_ = 0;
return v___x_258_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_IOError_ofNat___boxed(lean_object* v_n_259_){
_start:
{
uint8_t v_res_260_; lean_object* v_r_261_; 
v_res_260_ = lp_shell__lean__final_MemoryTransfer_IOError_ofNat(v_n_259_);
lean_dec(v_n_259_);
v_r_261_ = lean_box(v_res_260_);
return v_r_261_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError(uint8_t v_x_262_, uint8_t v_y_263_){
_start:
{
lean_object* v___x_264_; lean_object* v___x_265_; uint8_t v___x_266_; 
v___x_264_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(v_x_262_);
v___x_265_ = lp_shell__lean__final_MemoryTransfer_IOError_ctorIdx(v_y_263_);
v___x_266_ = lean_nat_dec_eq(v___x_264_, v___x_265_);
lean_dec(v___x_265_);
lean_dec(v___x_264_);
return v___x_266_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError___boxed(lean_object* v_x_267_, lean_object* v_y_268_){
_start:
{
uint8_t v_x_13__boxed_269_; uint8_t v_y_14__boxed_270_; uint8_t v_res_271_; lean_object* v_r_272_; 
v_x_13__boxed_269_ = lean_unbox(v_x_267_);
v_y_14__boxed_270_ = lean_unbox(v_y_268_);
v_res_271_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError(v_x_13__boxed_269_, v_y_14__boxed_270_);
v_r_272_ = lean_box(v_res_271_);
return v_r_272_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6(void){
_start:
{
lean_object* v___x_282_; lean_object* v___x_283_; 
v___x_282_ = lean_unsigned_to_nat(2u);
v___x_283_ = lean_nat_to_int(v___x_282_);
return v___x_283_;
}
}
static lean_object* _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7(void){
_start:
{
lean_object* v___x_284_; lean_object* v___x_285_; 
v___x_284_ = lean_unsigned_to_nat(1u);
v___x_285_ = lean_nat_to_int(v___x_284_);
return v___x_285_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr(uint8_t v_x_286_, lean_object* v_prec_287_){
_start:
{
lean_object* v___y_289_; lean_object* v___y_296_; lean_object* v___y_303_; 
switch(v_x_286_)
{
case 0:
{
lean_object* v___x_309_; uint8_t v___x_310_; 
v___x_309_ = lean_unsigned_to_nat(1024u);
v___x_310_ = lean_nat_dec_le(v___x_309_, v_prec_287_);
if (v___x_310_ == 0)
{
lean_object* v___x_311_; 
v___x_311_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_289_ = v___x_311_;
goto v___jp_288_;
}
else
{
lean_object* v___x_312_; 
v___x_312_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_289_ = v___x_312_;
goto v___jp_288_;
}
}
case 1:
{
lean_object* v___x_313_; uint8_t v___x_314_; 
v___x_313_ = lean_unsigned_to_nat(1024u);
v___x_314_ = lean_nat_dec_le(v___x_313_, v_prec_287_);
if (v___x_314_ == 0)
{
lean_object* v___x_315_; 
v___x_315_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_296_ = v___x_315_;
goto v___jp_295_;
}
else
{
lean_object* v___x_316_; 
v___x_316_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_296_ = v___x_316_;
goto v___jp_295_;
}
}
default: 
{
lean_object* v___x_317_; uint8_t v___x_318_; 
v___x_317_ = lean_unsigned_to_nat(1024u);
v___x_318_ = lean_nat_dec_le(v___x_317_, v_prec_287_);
if (v___x_318_ == 0)
{
lean_object* v___x_319_; 
v___x_319_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_303_ = v___x_319_;
goto v___jp_302_;
}
else
{
lean_object* v___x_320_; 
v___x_320_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_303_ = v___x_320_;
goto v___jp_302_;
}
}
}
v___jp_288_:
{
lean_object* v___x_290_; lean_object* v___x_291_; uint8_t v___x_292_; lean_object* v___x_293_; lean_object* v___x_294_; 
v___x_290_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__1));
lean_inc(v___y_289_);
v___x_291_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_291_, 0, v___y_289_);
lean_ctor_set(v___x_291_, 1, v___x_290_);
v___x_292_ = 0;
v___x_293_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_293_, 0, v___x_291_);
lean_ctor_set_uint8(v___x_293_, sizeof(void*)*1, v___x_292_);
v___x_294_ = l_Repr_addAppParen(v___x_293_, v_prec_287_);
return v___x_294_;
}
v___jp_295_:
{
lean_object* v___x_297_; lean_object* v___x_298_; uint8_t v___x_299_; lean_object* v___x_300_; lean_object* v___x_301_; 
v___x_297_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__3));
lean_inc(v___y_296_);
v___x_298_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_298_, 0, v___y_296_);
lean_ctor_set(v___x_298_, 1, v___x_297_);
v___x_299_ = 0;
v___x_300_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_300_, 0, v___x_298_);
lean_ctor_set_uint8(v___x_300_, sizeof(void*)*1, v___x_299_);
v___x_301_ = l_Repr_addAppParen(v___x_300_, v_prec_287_);
return v___x_301_;
}
v___jp_302_:
{
lean_object* v___x_304_; lean_object* v___x_305_; uint8_t v___x_306_; lean_object* v___x_307_; lean_object* v___x_308_; 
v___x_304_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__5));
lean_inc(v___y_303_);
v___x_305_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_305_, 0, v___y_303_);
lean_ctor_set(v___x_305_, 1, v___x_304_);
v___x_306_ = 0;
v___x_307_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_307_, 0, v___x_305_);
lean_ctor_set_uint8(v___x_307_, sizeof(void*)*1, v___x_306_);
v___x_308_ = l_Repr_addAppParen(v___x_307_, v_prec_287_);
return v___x_308_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___boxed(lean_object* v_x_321_, lean_object* v_prec_322_){
_start:
{
uint8_t v_x_177__boxed_323_; lean_object* v_res_324_; 
v_x_177__boxed_323_ = lean_unbox(v_x_321_);
v_res_324_ = lp_shell__lean__final_MemoryTransfer_instReprIOError_repr(v_x_177__boxed_323_, v_prec_322_);
lean_dec(v_prec_322_);
return v_res_324_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorIdx(lean_object* v_x_327_){
_start:
{
if (lean_obj_tag(v_x_327_) == 0)
{
lean_object* v___x_328_; 
v___x_328_ = lean_unsigned_to_nat(0u);
return v___x_328_;
}
else
{
lean_object* v___x_329_; 
v___x_329_ = lean_unsigned_to_nat(1u);
return v___x_329_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorIdx___boxed(lean_object* v_x_330_){
_start:
{
lean_object* v_res_331_; 
v_res_331_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorIdx(v_x_330_);
lean_dec_ref(v_x_330_);
return v_res_331_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(lean_object* v_t_332_, lean_object* v_k_333_){
_start:
{
if (lean_obj_tag(v_t_332_) == 0)
{
uint8_t v_e_334_; lean_object* v___x_335_; lean_object* v___x_336_; 
v_e_334_ = lean_ctor_get_uint8(v_t_332_, 0);
lean_dec_ref_known(v_t_332_, 0);
v___x_335_ = lean_box(v_e_334_);
v___x_336_ = lean_apply_1(v_k_333_, v___x_335_);
return v___x_336_;
}
else
{
lean_object* v_quota_337_; lean_object* v___x_338_; 
v_quota_337_ = lean_ctor_get(v_t_332_, 0);
lean_inc(v_quota_337_);
lean_dec_ref_known(v_t_332_, 1);
v___x_338_ = lean_apply_1(v_k_333_, v_quota_337_);
return v___x_338_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim(lean_object* v_motive_339_, lean_object* v_ctorIdx_340_, lean_object* v_t_341_, lean_object* v_h_342_, lean_object* v_k_343_){
_start:
{
lean_object* v___x_344_; 
v___x_344_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(v_t_341_, v_k_343_);
return v___x_344_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___boxed(lean_object* v_motive_345_, lean_object* v_ctorIdx_346_, lean_object* v_t_347_, lean_object* v_h_348_, lean_object* v_k_349_){
_start:
{
lean_object* v_res_350_; 
v_res_350_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim(v_motive_345_, v_ctorIdx_346_, v_t_347_, v_h_348_, v_k_349_);
lean_dec(v_ctorIdx_346_);
return v_res_350_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_fail_elim___redArg(lean_object* v_t_351_, lean_object* v_fail_352_){
_start:
{
lean_object* v___x_353_; 
v___x_353_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(v_t_351_, v_fail_352_);
return v___x_353_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_fail_elim(lean_object* v_motive_354_, lean_object* v_t_355_, lean_object* v_h_356_, lean_object* v_fail_357_){
_start:
{
lean_object* v___x_358_; 
v___x_358_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(v_t_355_, v_fail_357_);
return v___x_358_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ready_elim___redArg(lean_object* v_t_359_, lean_object* v_ready_360_){
_start:
{
lean_object* v___x_361_; 
v___x_361_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(v_t_359_, v_ready_360_);
return v___x_361_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Environment_ready_elim(lean_object* v_motive_362_, lean_object* v_t_363_, lean_object* v_h_364_, lean_object* v_ready_365_){
_start:
{
lean_object* v___x_366_; 
v___x_366_ = lp_shell__lean__final_MemoryTransfer_Environment_ctorElim___redArg(v_t_363_, v_ready_365_);
return v___x_366_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq(lean_object* v_x_367_, lean_object* v_x_368_){
_start:
{
if (lean_obj_tag(v_x_367_) == 0)
{
if (lean_obj_tag(v_x_368_) == 0)
{
uint8_t v_e_369_; uint8_t v_e_370_; uint8_t v___x_371_; 
v_e_369_ = lean_ctor_get_uint8(v_x_367_, 0);
v_e_370_ = lean_ctor_get_uint8(v_x_368_, 0);
v___x_371_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError(v_e_369_, v_e_370_);
return v___x_371_;
}
else
{
uint8_t v___x_372_; 
v___x_372_ = 0;
return v___x_372_;
}
}
else
{
if (lean_obj_tag(v_x_368_) == 0)
{
uint8_t v___x_373_; 
v___x_373_ = 0;
return v___x_373_;
}
else
{
lean_object* v_quota_374_; lean_object* v_quota_375_; uint8_t v___x_376_; 
v_quota_374_ = lean_ctor_get(v_x_367_, 0);
v_quota_375_ = lean_ctor_get(v_x_368_, 0);
v___x_376_ = lean_nat_dec_eq(v_quota_374_, v_quota_375_);
return v___x_376_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq___boxed(lean_object* v_x_377_, lean_object* v_x_378_){
_start:
{
uint8_t v_res_379_; lean_object* v_r_380_; 
v_res_379_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq(v_x_377_, v_x_378_);
lean_dec_ref(v_x_378_);
lean_dec_ref(v_x_377_);
v_r_380_ = lean_box(v_res_379_);
return v_r_380_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment(lean_object* v_x_381_, lean_object* v_x_382_){
_start:
{
uint8_t v___x_383_; 
v___x_383_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment_decEq(v_x_381_, v_x_382_);
return v___x_383_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment___boxed(lean_object* v_x_384_, lean_object* v_x_385_){
_start:
{
uint8_t v_res_386_; lean_object* v_r_387_; 
v_res_386_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqEnvironment(v_x_384_, v_x_385_);
lean_dec_ref(v_x_385_);
lean_dec_ref(v_x_384_);
v_r_387_ = lean_box(v_res_386_);
return v_r_387_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr(lean_object* v_x_400_, lean_object* v_prec_401_){
_start:
{
if (lean_obj_tag(v_x_400_) == 0)
{
uint8_t v_e_402_; lean_object* v___y_404_; lean_object* v___x_413_; uint8_t v___x_414_; 
v_e_402_ = lean_ctor_get_uint8(v_x_400_, 0);
lean_dec_ref_known(v_x_400_, 0);
v___x_413_ = lean_unsigned_to_nat(1024u);
v___x_414_ = lean_nat_dec_le(v___x_413_, v_prec_401_);
if (v___x_414_ == 0)
{
lean_object* v___x_415_; 
v___x_415_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_404_ = v___x_415_;
goto v___jp_403_;
}
else
{
lean_object* v___x_416_; 
v___x_416_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_404_ = v___x_416_;
goto v___jp_403_;
}
v___jp_403_:
{
lean_object* v___x_405_; lean_object* v___x_406_; lean_object* v___x_407_; lean_object* v___x_408_; lean_object* v___x_409_; uint8_t v___x_410_; lean_object* v___x_411_; lean_object* v___x_412_; 
v___x_405_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__2));
v___x_406_ = lean_unsigned_to_nat(1024u);
v___x_407_ = lp_shell__lean__final_MemoryTransfer_instReprIOError_repr(v_e_402_, v___x_406_);
v___x_408_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_408_, 0, v___x_405_);
lean_ctor_set(v___x_408_, 1, v___x_407_);
lean_inc(v___y_404_);
v___x_409_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_409_, 0, v___y_404_);
lean_ctor_set(v___x_409_, 1, v___x_408_);
v___x_410_ = 0;
v___x_411_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_411_, 0, v___x_409_);
lean_ctor_set_uint8(v___x_411_, sizeof(void*)*1, v___x_410_);
v___x_412_ = l_Repr_addAppParen(v___x_411_, v_prec_401_);
return v___x_412_;
}
}
else
{
lean_object* v_quota_417_; lean_object* v___x_419_; uint8_t v_isShared_420_; uint8_t v_isSharedCheck_437_; 
v_quota_417_ = lean_ctor_get(v_x_400_, 0);
v_isSharedCheck_437_ = !lean_is_exclusive(v_x_400_);
if (v_isSharedCheck_437_ == 0)
{
v___x_419_ = v_x_400_;
v_isShared_420_ = v_isSharedCheck_437_;
goto v_resetjp_418_;
}
else
{
lean_inc(v_quota_417_);
lean_dec(v_x_400_);
v___x_419_ = lean_box(0);
v_isShared_420_ = v_isSharedCheck_437_;
goto v_resetjp_418_;
}
v_resetjp_418_:
{
lean_object* v___y_422_; lean_object* v___x_433_; uint8_t v___x_434_; 
v___x_433_ = lean_unsigned_to_nat(1024u);
v___x_434_ = lean_nat_dec_le(v___x_433_, v_prec_401_);
if (v___x_434_ == 0)
{
lean_object* v___x_435_; 
v___x_435_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_422_ = v___x_435_;
goto v___jp_421_;
}
else
{
lean_object* v___x_436_; 
v___x_436_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_422_ = v___x_436_;
goto v___jp_421_;
}
v___jp_421_:
{
lean_object* v___x_423_; lean_object* v___x_424_; lean_object* v___x_426_; 
v___x_423_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___closed__5));
v___x_424_ = l_Nat_reprFast(v_quota_417_);
if (v_isShared_420_ == 0)
{
lean_ctor_set_tag(v___x_419_, 3);
lean_ctor_set(v___x_419_, 0, v___x_424_);
v___x_426_ = v___x_419_;
goto v_reusejp_425_;
}
else
{
lean_object* v_reuseFailAlloc_432_; 
v_reuseFailAlloc_432_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v_reuseFailAlloc_432_, 0, v___x_424_);
v___x_426_ = v_reuseFailAlloc_432_;
goto v_reusejp_425_;
}
v_reusejp_425_:
{
lean_object* v___x_427_; lean_object* v___x_428_; uint8_t v___x_429_; lean_object* v___x_430_; lean_object* v___x_431_; 
v___x_427_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_427_, 0, v___x_423_);
lean_ctor_set(v___x_427_, 1, v___x_426_);
lean_inc(v___y_422_);
v___x_428_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_428_, 0, v___y_422_);
lean_ctor_set(v___x_428_, 1, v___x_427_);
v___x_429_ = 0;
v___x_430_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_430_, 0, v___x_428_);
lean_ctor_set_uint8(v___x_430_, sizeof(void*)*1, v___x_429_);
v___x_431_ = l_Repr_addAppParen(v___x_430_, v_prec_401_);
return v___x_431_;
}
}
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr___boxed(lean_object* v_x_438_, lean_object* v_prec_439_){
_start:
{
lean_object* v_res_440_; 
v_res_440_ = lp_shell__lean__final_MemoryTransfer_instReprEnvironment_repr(v_x_438_, v_prec_439_);
lean_dec(v_prec_439_);
return v_res_440_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg(lean_object* v_x_443_){
_start:
{
switch(lean_obj_tag(v_x_443_))
{
case 0:
{
lean_object* v___x_444_; 
v___x_444_ = lean_unsigned_to_nat(0u);
return v___x_444_;
}
case 1:
{
lean_object* v___x_445_; 
v___x_445_ = lean_unsigned_to_nat(1u);
return v___x_445_;
}
default: 
{
lean_object* v___x_446_; 
v___x_446_ = lean_unsigned_to_nat(2u);
return v___x_446_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg___boxed(lean_object* v_x_447_){
_start:
{
lean_object* v_res_448_; 
v_res_448_ = lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg(v_x_447_);
lean_dec(v_x_447_);
return v_res_448_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx(lean_object* v_size_449_, lean_object* v_x_450_){
_start:
{
lean_object* v___x_451_; 
v___x_451_ = lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___redArg(v_x_450_);
return v___x_451_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorIdx___boxed(lean_object* v_size_452_, lean_object* v_x_453_){
_start:
{
lean_object* v_res_454_; 
v_res_454_ = lp_shell__lean__final_MemoryTransfer_Result_ctorIdx(v_size_452_, v_x_453_);
lean_dec(v_x_453_);
lean_dec(v_size_452_);
return v_res_454_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(lean_object* v_t_455_, lean_object* v_k_456_){
_start:
{
switch(lean_obj_tag(v_t_455_))
{
case 0:
{
lean_object* v_count_457_; lean_object* v_state_458_; lean_object* v___x_459_; 
v_count_457_ = lean_ctor_get(v_t_455_, 0);
lean_inc(v_count_457_);
v_state_458_ = lean_ctor_get(v_t_455_, 1);
lean_inc_ref(v_state_458_);
lean_dec_ref_known(v_t_455_, 2);
v___x_459_ = lean_apply_2(v_k_456_, v_count_457_, v_state_458_);
return v___x_459_;
}
case 1:
{
uint8_t v_e_460_; lean_object* v_state_461_; lean_object* v___x_462_; lean_object* v___x_463_; 
v_e_460_ = lean_ctor_get_uint8(v_t_455_, sizeof(void*)*1);
v_state_461_ = lean_ctor_get(v_t_455_, 0);
lean_inc_ref(v_state_461_);
lean_dec_ref_known(v_t_455_, 1);
v___x_462_ = lean_box(v_e_460_);
v___x_463_ = lean_apply_2(v_k_456_, v___x_462_, v_state_461_);
return v___x_463_;
}
default: 
{
return v_k_456_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim(lean_object* v_size_464_, lean_object* v_motive_465_, lean_object* v_ctorIdx_466_, lean_object* v_t_467_, lean_object* v_h_468_, lean_object* v_k_469_){
_start:
{
lean_object* v___x_470_; 
v___x_470_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_467_, v_k_469_);
return v___x_470_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ctorElim___boxed(lean_object* v_size_471_, lean_object* v_motive_472_, lean_object* v_ctorIdx_473_, lean_object* v_t_474_, lean_object* v_h_475_, lean_object* v_k_476_){
_start:
{
lean_object* v_res_477_; 
v_res_477_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim(v_size_471_, v_motive_472_, v_ctorIdx_473_, v_t_474_, v_h_475_, v_k_476_);
lean_dec(v_ctorIdx_473_);
lean_dec(v_size_471_);
return v_res_477_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim___redArg(lean_object* v_t_478_, lean_object* v_ok_479_){
_start:
{
lean_object* v___x_480_; 
v___x_480_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_478_, v_ok_479_);
return v___x_480_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim(lean_object* v_size_481_, lean_object* v_motive_482_, lean_object* v_t_483_, lean_object* v_h_484_, lean_object* v_ok_485_){
_start:
{
lean_object* v___x_486_; 
v___x_486_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_483_, v_ok_485_);
return v___x_486_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ok_elim___boxed(lean_object* v_size_487_, lean_object* v_motive_488_, lean_object* v_t_489_, lean_object* v_h_490_, lean_object* v_ok_491_){
_start:
{
lean_object* v_res_492_; 
v_res_492_ = lp_shell__lean__final_MemoryTransfer_Result_ok_elim(v_size_487_, v_motive_488_, v_t_489_, v_h_490_, v_ok_491_);
lean_dec(v_size_487_);
return v_res_492_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim___redArg(lean_object* v_t_493_, lean_object* v_error_494_){
_start:
{
lean_object* v___x_495_; 
v___x_495_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_493_, v_error_494_);
return v___x_495_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim(lean_object* v_size_496_, lean_object* v_motive_497_, lean_object* v_t_498_, lean_object* v_h_499_, lean_object* v_error_500_){
_start:
{
lean_object* v___x_501_; 
v___x_501_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_498_, v_error_500_);
return v___x_501_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_error_elim___boxed(lean_object* v_size_502_, lean_object* v_motive_503_, lean_object* v_t_504_, lean_object* v_h_505_, lean_object* v_error_506_){
_start:
{
lean_object* v_res_507_; 
v_res_507_ = lp_shell__lean__final_MemoryTransfer_Result_error_elim(v_size_502_, v_motive_503_, v_t_504_, v_h_505_, v_error_506_);
lean_dec(v_size_502_);
return v_res_507_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim___redArg(lean_object* v_t_508_, lean_object* v_ub_509_){
_start:
{
lean_object* v___x_510_; 
v___x_510_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_508_, v_ub_509_);
return v___x_510_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim(lean_object* v_size_511_, lean_object* v_motive_512_, lean_object* v_t_513_, lean_object* v_h_514_, lean_object* v_ub_515_){
_start:
{
lean_object* v___x_516_; 
v___x_516_ = lp_shell__lean__final_MemoryTransfer_Result_ctorElim___redArg(v_t_513_, v_ub_515_);
return v___x_516_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Result_ub_elim___boxed(lean_object* v_size_517_, lean_object* v_motive_518_, lean_object* v_t_519_, lean_object* v_h_520_, lean_object* v_ub_521_){
_start:
{
lean_object* v_res_522_; 
v_res_522_ = lp_shell__lean__final_MemoryTransfer_Result_ub_elim(v_size_517_, v_motive_518_, v_t_519_, v_h_520_, v_ub_521_);
lean_dec(v_size_517_);
return v_res_522_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_amount(lean_object* v_request_523_, lean_object* v_quota_524_, lean_object* v_input_525_){
_start:
{
lean_object* v___y_527_; lean_object* v___x_529_; uint8_t v___x_530_; 
v___x_529_ = l_List_lengthTR___redArg(v_input_525_);
v___x_530_ = lean_nat_dec_le(v_quota_524_, v___x_529_);
if (v___x_530_ == 0)
{
lean_dec(v_quota_524_);
v___y_527_ = v___x_529_;
goto v___jp_526_;
}
else
{
lean_dec(v___x_529_);
v___y_527_ = v_quota_524_;
goto v___jp_526_;
}
v___jp_526_:
{
uint8_t v___x_528_; 
v___x_528_ = lean_nat_dec_le(v_request_523_, v___y_527_);
if (v___x_528_ == 0)
{
return v___y_527_;
}
else
{
lean_dec(v___y_527_);
lean_inc(v_request_523_);
return v_request_523_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_amount___boxed(lean_object* v_request_531_, lean_object* v_quota_532_, lean_object* v_input_533_){
_start:
{
lean_object* v_res_534_; 
v_res_534_ = lp_shell__lean__final_MemoryTransfer_amount(v_request_531_, v_quota_532_, v_input_533_);
lean_dec(v_input_533_);
lean_dec(v_request_531_);
return v_res_534_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_afterRead(lean_object* v_size_537_, lean_object* v_s_538_, lean_object* v_p_539_, lean_object* v_k_540_){
_start:
{
lean_object* v_mem_541_; lean_object* v_input_542_; lean_object* v_output_543_; lean_object* v___x_545_; uint8_t v_isShared_546_; uint8_t v_isSharedCheck_555_; 
v_mem_541_ = lean_ctor_get(v_s_538_, 0);
v_input_542_ = lean_ctor_get(v_s_538_, 1);
v_output_543_ = lean_ctor_get(v_s_538_, 2);
v_isSharedCheck_555_ = !lean_is_exclusive(v_s_538_);
if (v_isSharedCheck_555_ == 0)
{
v___x_545_ = v_s_538_;
v_isShared_546_ = v_isSharedCheck_555_;
goto v_resetjp_544_;
}
else
{
lean_inc(v_output_543_);
lean_inc(v_input_542_);
lean_inc(v_mem_541_);
lean_dec(v_s_538_);
v___x_545_ = lean_box(0);
v_isShared_546_ = v_isSharedCheck_555_;
goto v_resetjp_544_;
}
v_resetjp_544_:
{
lean_object* v_offset_547_; lean_object* v___x_548_; lean_object* v___x_549_; lean_object* v___x_550_; lean_object* v___x_551_; lean_object* v___x_553_; 
v_offset_547_ = lean_ctor_get(v_p_539_, 1);
lean_inc(v_offset_547_);
lean_dec_ref(v_p_539_);
v___x_548_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_afterRead___closed__0));
lean_inc(v_k_540_);
lean_inc(v_input_542_);
v___x_549_ = l___private_Init_Data_List_Impl_0__List_takeTR_go___redArg(v_input_542_, v_input_542_, v_k_540_, v___x_548_);
v___x_550_ = lean_alloc_closure((void*)(lp_shell__lean__final_MemoryTransfer_store___boxed), 5, 4);
lean_closure_set(v___x_550_, 0, v_size_537_);
lean_closure_set(v___x_550_, 1, v_mem_541_);
lean_closure_set(v___x_550_, 2, v_offset_547_);
lean_closure_set(v___x_550_, 3, v___x_549_);
v___x_551_ = l_List_drop___redArg(v_k_540_, v_input_542_);
lean_dec(v_input_542_);
if (v_isShared_546_ == 0)
{
lean_ctor_set(v___x_545_, 1, v___x_551_);
lean_ctor_set(v___x_545_, 0, v___x_550_);
v___x_553_ = v___x_545_;
goto v_reusejp_552_;
}
else
{
lean_object* v_reuseFailAlloc_554_; 
v_reuseFailAlloc_554_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_554_, 0, v___x_550_);
lean_ctor_set(v_reuseFailAlloc_554_, 1, v___x_551_);
lean_ctor_set(v_reuseFailAlloc_554_, 2, v_output_543_);
v___x_553_ = v_reuseFailAlloc_554_;
goto v_reusejp_552_;
}
v_reusejp_552_:
{
return v___x_553_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_read(lean_object* v_size_556_, lean_object* v_block_557_, lean_object* v_s_558_, lean_object* v_p_559_, lean_object* v_request_560_, lean_object* v_env_561_){
_start:
{
uint8_t v___x_562_; 
v___x_562_ = lp_shell__lean__final_MemoryTransfer_instDecidableValid___aux__1(v_block_557_, v_size_556_, v_p_559_, v_request_560_);
if (v___x_562_ == 0)
{
lean_object* v___x_563_; 
lean_dec_ref(v_env_561_);
lean_dec_ref(v_p_559_);
lean_dec_ref(v_s_558_);
lean_dec(v_size_556_);
v___x_563_ = lean_box(2);
return v___x_563_;
}
else
{
if (lean_obj_tag(v_env_561_) == 0)
{
uint8_t v_e_564_; lean_object* v___x_565_; 
lean_dec_ref(v_p_559_);
lean_dec(v_size_556_);
v_e_564_ = lean_ctor_get_uint8(v_env_561_, 0);
lean_dec_ref_known(v_env_561_, 0);
v___x_565_ = lean_alloc_ctor(1, 1, 1);
lean_ctor_set(v___x_565_, 0, v_s_558_);
lean_ctor_set_uint8(v___x_565_, sizeof(void*)*1, v_e_564_);
return v___x_565_;
}
else
{
lean_object* v_quota_566_; lean_object* v_input_567_; lean_object* v_k_568_; lean_object* v___x_569_; lean_object* v___x_570_; 
v_quota_566_ = lean_ctor_get(v_env_561_, 0);
lean_inc(v_quota_566_);
lean_dec_ref_known(v_env_561_, 1);
v_input_567_ = lean_ctor_get(v_s_558_, 1);
v_k_568_ = lp_shell__lean__final_MemoryTransfer_amount(v_request_560_, v_quota_566_, v_input_567_);
lean_inc(v_k_568_);
v___x_569_ = lp_shell__lean__final_MemoryTransfer_afterRead(v_size_556_, v_s_558_, v_p_559_, v_k_568_);
v___x_570_ = lean_alloc_ctor(0, 2, 0);
lean_ctor_set(v___x_570_, 0, v_k_568_);
lean_ctor_set(v___x_570_, 1, v___x_569_);
return v___x_570_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_read___boxed(lean_object* v_size_571_, lean_object* v_block_572_, lean_object* v_s_573_, lean_object* v_p_574_, lean_object* v_request_575_, lean_object* v_env_576_){
_start:
{
lean_object* v_res_577_; 
v_res_577_ = lp_shell__lean__final_MemoryTransfer_read(v_size_571_, v_block_572_, v_s_573_, v_p_574_, v_request_575_, v_env_576_);
lean_dec(v_request_575_);
lean_dec(v_block_572_);
return v_res_577_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_MemoryTransfer_0__MemoryTransfer_instReprEnvironment_repr_match__1_splitter___redArg(lean_object* v_x_578_, lean_object* v_h__1_579_, lean_object* v_h__2_580_){
_start:
{
if (lean_obj_tag(v_x_578_) == 0)
{
uint8_t v_e_581_; lean_object* v___x_582_; lean_object* v___x_583_; 
lean_dec(v_h__2_580_);
v_e_581_ = lean_ctor_get_uint8(v_x_578_, 0);
lean_dec_ref_known(v_x_578_, 0);
v___x_582_ = lean_box(v_e_581_);
v___x_583_ = lean_apply_1(v_h__1_579_, v___x_582_);
return v___x_583_;
}
else
{
lean_object* v_quota_584_; lean_object* v___x_585_; 
lean_dec(v_h__1_579_);
v_quota_584_ = lean_ctor_get(v_x_578_, 0);
lean_inc(v_quota_584_);
lean_dec_ref_known(v_x_578_, 1);
v___x_585_ = lean_apply_1(v_h__2_580_, v_quota_584_);
return v___x_585_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final___private_MemoryTransfer_0__MemoryTransfer_instReprEnvironment_repr_match__1_splitter(lean_object* v_motive_586_, lean_object* v_x_587_, lean_object* v_h__1_588_, lean_object* v_h__2_589_){
_start:
{
if (lean_obj_tag(v_x_587_) == 0)
{
uint8_t v_e_590_; lean_object* v___x_591_; lean_object* v___x_592_; 
lean_dec(v_h__2_589_);
v_e_590_ = lean_ctor_get_uint8(v_x_587_, 0);
lean_dec_ref_known(v_x_587_, 0);
v___x_591_ = lean_box(v_e_590_);
v___x_592_ = lean_apply_1(v_h__1_588_, v___x_591_);
return v___x_592_;
}
else
{
lean_object* v_quota_593_; lean_object* v___x_594_; 
lean_dec(v_h__1_588_);
v_quota_593_ = lean_ctor_get(v_x_587_, 0);
lean_inc(v_quota_593_);
lean_dec_ref_known(v_x_587_, 1);
v___x_594_ = lean_apply_1(v_h__2_589_, v_quota_593_);
return v___x_594_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit___redArg(lean_object* v_s_595_, lean_object* v_p_596_, lean_object* v_k_597_){
_start:
{
lean_object* v_mem_598_; lean_object* v_input_599_; lean_object* v_output_600_; lean_object* v___x_602_; uint8_t v_isShared_603_; uint8_t v_isSharedCheck_610_; 
v_mem_598_ = lean_ctor_get(v_s_595_, 0);
v_input_599_ = lean_ctor_get(v_s_595_, 1);
v_output_600_ = lean_ctor_get(v_s_595_, 2);
v_isSharedCheck_610_ = !lean_is_exclusive(v_s_595_);
if (v_isSharedCheck_610_ == 0)
{
v___x_602_ = v_s_595_;
v_isShared_603_ = v_isSharedCheck_610_;
goto v_resetjp_601_;
}
else
{
lean_inc(v_output_600_);
lean_inc(v_input_599_);
lean_inc(v_mem_598_);
lean_dec(v_s_595_);
v___x_602_ = lean_box(0);
v_isShared_603_ = v_isSharedCheck_610_;
goto v_resetjp_601_;
}
v_resetjp_601_:
{
lean_object* v_offset_604_; lean_object* v___x_605_; lean_object* v___x_606_; lean_object* v___x_608_; 
v_offset_604_ = lean_ctor_get(v_p_596_, 1);
lean_inc(v_offset_604_);
lean_dec_ref(v_p_596_);
lean_inc_ref(v_mem_598_);
v___x_605_ = lp_shell__lean__final_MemoryTransfer_load___redArg(v_mem_598_, v_offset_604_, v_k_597_);
v___x_606_ = l_List_appendTR___redArg(v_output_600_, v___x_605_);
if (v_isShared_603_ == 0)
{
lean_ctor_set(v___x_602_, 2, v___x_606_);
v___x_608_ = v___x_602_;
goto v_reusejp_607_;
}
else
{
lean_object* v_reuseFailAlloc_609_; 
v_reuseFailAlloc_609_ = lean_alloc_ctor(0, 3, 0);
lean_ctor_set(v_reuseFailAlloc_609_, 0, v_mem_598_);
lean_ctor_set(v_reuseFailAlloc_609_, 1, v_input_599_);
lean_ctor_set(v_reuseFailAlloc_609_, 2, v___x_606_);
v___x_608_ = v_reuseFailAlloc_609_;
goto v_reusejp_607_;
}
v_reusejp_607_:
{
return v___x_608_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit(lean_object* v_size_611_, lean_object* v_s_612_, lean_object* v_p_613_, lean_object* v_k_614_, lean_object* v_h_615_){
_start:
{
lean_object* v___x_616_; 
v___x_616_ = lp_shell__lean__final_MemoryTransfer_emit___redArg(v_s_612_, v_p_613_, v_k_614_);
return v___x_616_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_emit___boxed(lean_object* v_size_617_, lean_object* v_s_618_, lean_object* v_p_619_, lean_object* v_k_620_, lean_object* v_h_621_){
_start:
{
lean_object* v_res_622_; 
v_res_622_ = lp_shell__lean__final_MemoryTransfer_emit(v_size_617_, v_s_618_, v_p_619_, v_k_620_, v_h_621_);
lean_dec(v_size_617_);
return v_res_622_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0(lean_object* v_x_623_){
_start:
{
uint8_t v___x_624_; 
v___x_624_ = 170;
return v___x_624_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0___boxed(lean_object* v_x_625_){
_start:
{
uint8_t v_res_626_; lean_object* v_r_627_; 
v_res_626_ = lp_shell__lean__final_MemoryTransfer_Examples_initial___lam__0(v_x_625_);
lean_dec(v_x_625_);
v_r_627_ = lean_box(v_res_626_);
return v_r_627_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorIdx(lean_object* v_x_658_){
_start:
{
switch(lean_obj_tag(v_x_658_))
{
case 0:
{
lean_object* v___x_659_; 
v___x_659_ = lean_unsigned_to_nat(0u);
return v___x_659_;
}
case 1:
{
lean_object* v___x_660_; 
v___x_660_ = lean_unsigned_to_nat(1u);
return v___x_660_;
}
default: 
{
lean_object* v___x_661_; 
v___x_661_ = lean_unsigned_to_nat(2u);
return v___x_661_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorIdx___boxed(lean_object* v_x_662_){
_start:
{
lean_object* v_res_663_; 
v_res_663_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorIdx(v_x_662_);
lean_dec(v_x_662_);
return v_res_663_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(lean_object* v_t_664_, lean_object* v_k_665_){
_start:
{
switch(lean_obj_tag(v_t_664_))
{
case 0:
{
return v_k_665_;
}
case 1:
{
uint8_t v_e_666_; lean_object* v_memory_667_; lean_object* v_input_668_; lean_object* v_output_669_; lean_object* v___x_670_; lean_object* v___x_671_; 
v_e_666_ = lean_ctor_get_uint8(v_t_664_, sizeof(void*)*3);
v_memory_667_ = lean_ctor_get(v_t_664_, 0);
lean_inc(v_memory_667_);
v_input_668_ = lean_ctor_get(v_t_664_, 1);
lean_inc(v_input_668_);
v_output_669_ = lean_ctor_get(v_t_664_, 2);
lean_inc(v_output_669_);
lean_dec_ref_known(v_t_664_, 3);
v___x_670_ = lean_box(v_e_666_);
v___x_671_ = lean_apply_4(v_k_665_, v___x_670_, v_memory_667_, v_input_668_, v_output_669_);
return v___x_671_;
}
default: 
{
lean_object* v_count_672_; lean_object* v_memory_673_; lean_object* v_input_674_; lean_object* v_output_675_; lean_object* v___x_676_; 
v_count_672_ = lean_ctor_get(v_t_664_, 0);
lean_inc(v_count_672_);
v_memory_673_ = lean_ctor_get(v_t_664_, 1);
lean_inc(v_memory_673_);
v_input_674_ = lean_ctor_get(v_t_664_, 2);
lean_inc(v_input_674_);
v_output_675_ = lean_ctor_get(v_t_664_, 3);
lean_inc(v_output_675_);
lean_dec_ref_known(v_t_664_, 4);
v___x_676_ = lean_apply_4(v_k_665_, v_count_672_, v_memory_673_, v_input_674_, v_output_675_);
return v___x_676_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim(lean_object* v_motive_677_, lean_object* v_ctorIdx_678_, lean_object* v_t_679_, lean_object* v_h_680_, lean_object* v_k_681_){
_start:
{
lean_object* v___x_682_; 
v___x_682_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_679_, v_k_681_);
return v___x_682_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___boxed(lean_object* v_motive_683_, lean_object* v_ctorIdx_684_, lean_object* v_t_685_, lean_object* v_h_686_, lean_object* v_k_687_){
_start:
{
lean_object* v_res_688_; 
v_res_688_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim(v_motive_683_, v_ctorIdx_684_, v_t_685_, v_h_686_, v_k_687_);
lean_dec(v_ctorIdx_684_);
return v_res_688_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ub_elim___redArg(lean_object* v_t_689_, lean_object* v_ub_690_){
_start:
{
lean_object* v___x_691_; 
v___x_691_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_689_, v_ub_690_);
return v___x_691_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ub_elim(lean_object* v_motive_692_, lean_object* v_t_693_, lean_object* v_h_694_, lean_object* v_ub_695_){
_start:
{
lean_object* v___x_696_; 
v___x_696_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_693_, v_ub_695_);
return v___x_696_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_error_elim___redArg(lean_object* v_t_697_, lean_object* v_error_698_){
_start:
{
lean_object* v___x_699_; 
v___x_699_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_697_, v_error_698_);
return v___x_699_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_error_elim(lean_object* v_motive_700_, lean_object* v_t_701_, lean_object* v_h_702_, lean_object* v_error_703_){
_start:
{
lean_object* v___x_704_; 
v___x_704_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_701_, v_error_703_);
return v___x_704_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ok_elim___redArg(lean_object* v_t_705_, lean_object* v_ok_706_){
_start:
{
lean_object* v___x_707_; 
v___x_707_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_705_, v_ok_706_);
return v___x_707_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_Observation_ok_elim(lean_object* v_motive_708_, lean_object* v_t_709_, lean_object* v_h_710_, lean_object* v_ok_711_){
_start:
{
lean_object* v___x_712_; 
v___x_712_ = lp_shell__lean__final_MemoryTransfer_Examples_Observation_ctorElim___redArg(v_t_709_, v_ok_711_);
return v___x_712_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq(lean_object* v_x_713_, lean_object* v_x_714_){
_start:
{
switch(lean_obj_tag(v_x_713_))
{
case 0:
{
if (lean_obj_tag(v_x_714_) == 0)
{
uint8_t v___x_715_; 
v___x_715_ = 1;
return v___x_715_;
}
else
{
uint8_t v___x_716_; 
lean_dec(v_x_714_);
v___x_716_ = 0;
return v___x_716_;
}
}
case 1:
{
uint8_t v_e_717_; lean_object* v_memory_718_; lean_object* v_input_719_; lean_object* v_output_720_; uint8_t v___x_721_; 
v_e_717_ = lean_ctor_get_uint8(v_x_713_, sizeof(void*)*3);
v_memory_718_ = lean_ctor_get(v_x_713_, 0);
lean_inc(v_memory_718_);
v_input_719_ = lean_ctor_get(v_x_713_, 1);
lean_inc(v_input_719_);
v_output_720_ = lean_ctor_get(v_x_713_, 2);
lean_inc(v_output_720_);
lean_dec_ref_known(v_x_713_, 3);
v___x_721_ = 0;
if (lean_obj_tag(v_x_714_) == 1)
{
uint8_t v_e_722_; lean_object* v_memory_723_; lean_object* v_input_724_; lean_object* v_output_725_; uint8_t v___x_726_; 
v_e_722_ = lean_ctor_get_uint8(v_x_714_, sizeof(void*)*3);
v_memory_723_ = lean_ctor_get(v_x_714_, 0);
lean_inc(v_memory_723_);
v_input_724_ = lean_ctor_get(v_x_714_, 1);
lean_inc(v_input_724_);
v_output_725_ = lean_ctor_get(v_x_714_, 2);
lean_inc(v_output_725_);
lean_dec_ref_known(v_x_714_, 3);
v___x_726_ = lp_shell__lean__final_MemoryTransfer_instDecidableEqIOError(v_e_717_, v_e_722_);
if (v___x_726_ == 0)
{
lean_dec(v_output_725_);
lean_dec(v_input_724_);
lean_dec(v_memory_723_);
lean_dec(v_output_720_);
lean_dec(v_input_719_);
lean_dec(v_memory_718_);
return v___x_721_;
}
else
{
lean_object* v___x_727_; uint8_t v___x_728_; 
v___x_727_ = lean_alloc_closure((void*)(l_instDecidableEqUInt8___boxed), 2, 0);
lean_inc_ref(v___x_727_);
v___x_728_ = l_instDecidableEqList___redArg(v___x_727_, v_memory_718_, v_memory_723_);
if (v___x_728_ == 0)
{
lean_dec_ref(v___x_727_);
lean_dec(v_output_725_);
lean_dec(v_input_724_);
lean_dec(v_output_720_);
lean_dec(v_input_719_);
return v___x_721_;
}
else
{
uint8_t v___x_729_; 
lean_inc_ref(v___x_727_);
v___x_729_ = l_instDecidableEqList___redArg(v___x_727_, v_input_719_, v_input_724_);
if (v___x_729_ == 0)
{
lean_dec_ref(v___x_727_);
lean_dec(v_output_725_);
lean_dec(v_output_720_);
return v___x_721_;
}
else
{
uint8_t v___x_730_; 
v___x_730_ = l_instDecidableEqList___redArg(v___x_727_, v_output_720_, v_output_725_);
if (v___x_730_ == 0)
{
return v___x_721_;
}
else
{
return v___x_730_;
}
}
}
}
}
else
{
lean_dec(v_output_720_);
lean_dec(v_input_719_);
lean_dec(v_memory_718_);
lean_dec(v_x_714_);
return v___x_721_;
}
}
default: 
{
lean_object* v_count_731_; lean_object* v_memory_732_; lean_object* v_input_733_; lean_object* v_output_734_; uint8_t v___x_735_; 
v_count_731_ = lean_ctor_get(v_x_713_, 0);
lean_inc(v_count_731_);
v_memory_732_ = lean_ctor_get(v_x_713_, 1);
lean_inc(v_memory_732_);
v_input_733_ = lean_ctor_get(v_x_713_, 2);
lean_inc(v_input_733_);
v_output_734_ = lean_ctor_get(v_x_713_, 3);
lean_inc(v_output_734_);
lean_dec_ref_known(v_x_713_, 4);
v___x_735_ = 0;
if (lean_obj_tag(v_x_714_) == 2)
{
lean_object* v_count_736_; lean_object* v_memory_737_; lean_object* v_input_738_; lean_object* v_output_739_; uint8_t v___x_740_; 
v_count_736_ = lean_ctor_get(v_x_714_, 0);
lean_inc(v_count_736_);
v_memory_737_ = lean_ctor_get(v_x_714_, 1);
lean_inc(v_memory_737_);
v_input_738_ = lean_ctor_get(v_x_714_, 2);
lean_inc(v_input_738_);
v_output_739_ = lean_ctor_get(v_x_714_, 3);
lean_inc(v_output_739_);
lean_dec_ref_known(v_x_714_, 4);
v___x_740_ = lean_nat_dec_eq(v_count_731_, v_count_736_);
lean_dec(v_count_736_);
lean_dec(v_count_731_);
if (v___x_740_ == 0)
{
lean_dec(v_output_739_);
lean_dec(v_input_738_);
lean_dec(v_memory_737_);
lean_dec(v_output_734_);
lean_dec(v_input_733_);
lean_dec(v_memory_732_);
return v___x_735_;
}
else
{
lean_object* v___x_741_; uint8_t v___x_742_; 
v___x_741_ = lean_alloc_closure((void*)(l_instDecidableEqUInt8___boxed), 2, 0);
lean_inc_ref(v___x_741_);
v___x_742_ = l_instDecidableEqList___redArg(v___x_741_, v_memory_732_, v_memory_737_);
if (v___x_742_ == 0)
{
lean_dec_ref(v___x_741_);
lean_dec(v_output_739_);
lean_dec(v_input_738_);
lean_dec(v_output_734_);
lean_dec(v_input_733_);
return v___x_735_;
}
else
{
uint8_t v___x_743_; 
lean_inc_ref(v___x_741_);
v___x_743_ = l_instDecidableEqList___redArg(v___x_741_, v_input_733_, v_input_738_);
if (v___x_743_ == 0)
{
lean_dec_ref(v___x_741_);
lean_dec(v_output_739_);
lean_dec(v_output_734_);
return v___x_735_;
}
else
{
uint8_t v___x_744_; 
v___x_744_ = l_instDecidableEqList___redArg(v___x_741_, v_output_734_, v_output_739_);
if (v___x_744_ == 0)
{
return v___x_735_;
}
else
{
return v___x_744_;
}
}
}
}
}
else
{
lean_dec(v_output_734_);
lean_dec(v_input_733_);
lean_dec(v_memory_732_);
lean_dec(v_count_731_);
lean_dec(v_x_714_);
return v___x_735_;
}
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq___boxed(lean_object* v_x_745_, lean_object* v_x_746_){
_start:
{
uint8_t v_res_747_; lean_object* v_r_748_; 
v_res_747_ = lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq(v_x_745_, v_x_746_);
v_r_748_ = lean_box(v_res_747_);
return v_r_748_;
}
}
LEAN_EXPORT uint8_t lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation(lean_object* v_x_749_, lean_object* v_x_750_){
_start:
{
uint8_t v___x_751_; 
v___x_751_ = lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation_decEq(v_x_749_, v_x_750_);
return v___x_751_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation___boxed(lean_object* v_x_752_, lean_object* v_x_753_){
_start:
{
uint8_t v_res_754_; lean_object* v_r_755_; 
v_res_754_ = lp_shell__lean__final_MemoryTransfer_Examples_instDecidableEqObservation(v_x_752_, v_x_753_);
v_r_755_ = lean_box(v_res_754_);
return v_r_755_;
}
}
static lean_object* _init_lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5(void){
_start:
{
lean_object* v___x_764_; lean_object* v___x_765_; 
v___x_764_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__2));
v___x_765_ = lean_string_length(v___x_764_);
return v___x_765_;
}
}
static lean_object* _init_lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6(void){
_start:
{
lean_object* v___x_766_; lean_object* v___x_767_; 
v___x_766_ = lean_obj_once(&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5, &lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5_once, _init_lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__5);
v___x_767_ = lean_nat_to_int(v___x_766_);
return v___x_767_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(lean_object* v_a_772_){
_start:
{
if (lean_obj_tag(v_a_772_) == 0)
{
lean_object* v___x_773_; 
v___x_773_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__1));
return v___x_773_;
}
else
{
lean_object* v___x_774_; lean_object* v___x_775_; lean_object* v___x_776_; lean_object* v___x_777_; lean_object* v___x_778_; lean_object* v___x_779_; lean_object* v___x_780_; lean_object* v___x_781_; lean_object* v___x_782_; 
v___x_774_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__3));
v___x_775_ = l_Std_Format_joinSep___at___00Array_repr___at___00Std_Time_TimeZone_TZif_instReprTZifV1_repr_spec__1_spec__2(v_a_772_, v___x_774_);
v___x_776_ = lean_obj_once(&lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6, &lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6_once, _init_lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__6);
v___x_777_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__7));
v___x_778_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_778_, 0, v___x_777_);
lean_ctor_set(v___x_778_, 1, v___x_775_);
v___x_779_ = ((lean_object*)(lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg___closed__8));
v___x_780_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_780_, 0, v___x_778_);
lean_ctor_set(v___x_780_, 1, v___x_779_);
v___x_781_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_781_, 0, v___x_776_);
lean_ctor_set(v___x_781_, 1, v___x_780_);
v___x_782_ = l_Std_Format_fill(v___x_781_);
return v___x_782_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr(lean_object* v_x_798_, lean_object* v_prec_799_){
_start:
{
lean_object* v___y_801_; 
switch(lean_obj_tag(v_x_798_))
{
case 0:
{
lean_object* v___x_807_; uint8_t v___x_808_; 
v___x_807_ = lean_unsigned_to_nat(1024u);
v___x_808_ = lean_nat_dec_le(v___x_807_, v_prec_799_);
if (v___x_808_ == 0)
{
lean_object* v___x_809_; 
v___x_809_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_801_ = v___x_809_;
goto v___jp_800_;
}
else
{
lean_object* v___x_810_; 
v___x_810_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_801_ = v___x_810_;
goto v___jp_800_;
}
}
case 1:
{
uint8_t v_e_811_; lean_object* v_memory_812_; lean_object* v_input_813_; lean_object* v_output_814_; lean_object* v___y_816_; lean_object* v___x_835_; uint8_t v___x_836_; 
v_e_811_ = lean_ctor_get_uint8(v_x_798_, sizeof(void*)*3);
v_memory_812_ = lean_ctor_get(v_x_798_, 0);
lean_inc(v_memory_812_);
v_input_813_ = lean_ctor_get(v_x_798_, 1);
lean_inc(v_input_813_);
v_output_814_ = lean_ctor_get(v_x_798_, 2);
lean_inc(v_output_814_);
lean_dec_ref_known(v_x_798_, 3);
v___x_835_ = lean_unsigned_to_nat(1024u);
v___x_836_ = lean_nat_dec_le(v___x_835_, v_prec_799_);
if (v___x_836_ == 0)
{
lean_object* v___x_837_; 
v___x_837_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_816_ = v___x_837_;
goto v___jp_815_;
}
else
{
lean_object* v___x_838_; 
v___x_838_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_816_ = v___x_838_;
goto v___jp_815_;
}
v___jp_815_:
{
lean_object* v___x_817_; lean_object* v___x_818_; lean_object* v___x_819_; lean_object* v___x_820_; lean_object* v___x_821_; lean_object* v___x_822_; lean_object* v___x_823_; lean_object* v___x_824_; lean_object* v___x_825_; lean_object* v___x_826_; lean_object* v___x_827_; lean_object* v___x_828_; lean_object* v___x_829_; lean_object* v___x_830_; lean_object* v___x_831_; uint8_t v___x_832_; lean_object* v___x_833_; lean_object* v___x_834_; 
v___x_817_ = lean_box(1);
v___x_818_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__4));
v___x_819_ = lean_unsigned_to_nat(1024u);
v___x_820_ = lp_shell__lean__final_MemoryTransfer_instReprIOError_repr(v_e_811_, v___x_819_);
v___x_821_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_821_, 0, v___x_818_);
lean_ctor_set(v___x_821_, 1, v___x_820_);
v___x_822_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_822_, 0, v___x_821_);
lean_ctor_set(v___x_822_, 1, v___x_817_);
v___x_823_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_memory_812_);
v___x_824_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_824_, 0, v___x_822_);
lean_ctor_set(v___x_824_, 1, v___x_823_);
v___x_825_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_825_, 0, v___x_824_);
lean_ctor_set(v___x_825_, 1, v___x_817_);
v___x_826_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_input_813_);
v___x_827_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_827_, 0, v___x_825_);
lean_ctor_set(v___x_827_, 1, v___x_826_);
v___x_828_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_828_, 0, v___x_827_);
lean_ctor_set(v___x_828_, 1, v___x_817_);
v___x_829_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_output_814_);
v___x_830_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_830_, 0, v___x_828_);
lean_ctor_set(v___x_830_, 1, v___x_829_);
lean_inc(v___y_816_);
v___x_831_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_831_, 0, v___y_816_);
lean_ctor_set(v___x_831_, 1, v___x_830_);
v___x_832_ = 0;
v___x_833_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_833_, 0, v___x_831_);
lean_ctor_set_uint8(v___x_833_, sizeof(void*)*1, v___x_832_);
v___x_834_ = l_Repr_addAppParen(v___x_833_, v_prec_799_);
return v___x_834_;
}
}
default: 
{
lean_object* v_count_839_; lean_object* v_memory_840_; lean_object* v_input_841_; lean_object* v_output_842_; lean_object* v___y_844_; lean_object* v___x_863_; uint8_t v___x_864_; 
v_count_839_ = lean_ctor_get(v_x_798_, 0);
lean_inc(v_count_839_);
v_memory_840_ = lean_ctor_get(v_x_798_, 1);
lean_inc(v_memory_840_);
v_input_841_ = lean_ctor_get(v_x_798_, 2);
lean_inc(v_input_841_);
v_output_842_ = lean_ctor_get(v_x_798_, 3);
lean_inc(v_output_842_);
lean_dec_ref_known(v_x_798_, 4);
v___x_863_ = lean_unsigned_to_nat(1024u);
v___x_864_ = lean_nat_dec_le(v___x_863_, v_prec_799_);
if (v___x_864_ == 0)
{
lean_object* v___x_865_; 
v___x_865_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__6);
v___y_844_ = v___x_865_;
goto v___jp_843_;
}
else
{
lean_object* v___x_866_; 
v___x_866_ = lean_obj_once(&lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7, &lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7_once, _init_lp_shell__lean__final_MemoryTransfer_instReprIOError_repr___closed__7);
v___y_844_ = v___x_866_;
goto v___jp_843_;
}
v___jp_843_:
{
lean_object* v___x_845_; lean_object* v___x_846_; lean_object* v___x_847_; lean_object* v___x_848_; lean_object* v___x_849_; lean_object* v___x_850_; lean_object* v___x_851_; lean_object* v___x_852_; lean_object* v___x_853_; lean_object* v___x_854_; lean_object* v___x_855_; lean_object* v___x_856_; lean_object* v___x_857_; lean_object* v___x_858_; lean_object* v___x_859_; uint8_t v___x_860_; lean_object* v___x_861_; lean_object* v___x_862_; 
v___x_845_ = lean_box(1);
v___x_846_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__7));
v___x_847_ = l_Nat_reprFast(v_count_839_);
v___x_848_ = lean_alloc_ctor(3, 1, 0);
lean_ctor_set(v___x_848_, 0, v___x_847_);
v___x_849_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_849_, 0, v___x_846_);
lean_ctor_set(v___x_849_, 1, v___x_848_);
v___x_850_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_850_, 0, v___x_849_);
lean_ctor_set(v___x_850_, 1, v___x_845_);
v___x_851_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_memory_840_);
v___x_852_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_852_, 0, v___x_850_);
lean_ctor_set(v___x_852_, 1, v___x_851_);
v___x_853_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_853_, 0, v___x_852_);
lean_ctor_set(v___x_853_, 1, v___x_845_);
v___x_854_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_input_841_);
v___x_855_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_855_, 0, v___x_853_);
lean_ctor_set(v___x_855_, 1, v___x_854_);
v___x_856_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_856_, 0, v___x_855_);
lean_ctor_set(v___x_856_, 1, v___x_845_);
v___x_857_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_output_842_);
v___x_858_ = lean_alloc_ctor(5, 2, 0);
lean_ctor_set(v___x_858_, 0, v___x_856_);
lean_ctor_set(v___x_858_, 1, v___x_857_);
lean_inc(v___y_844_);
v___x_859_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_859_, 0, v___y_844_);
lean_ctor_set(v___x_859_, 1, v___x_858_);
v___x_860_ = 0;
v___x_861_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_861_, 0, v___x_859_);
lean_ctor_set_uint8(v___x_861_, sizeof(void*)*1, v___x_860_);
v___x_862_ = l_Repr_addAppParen(v___x_861_, v_prec_799_);
return v___x_862_;
}
}
}
v___jp_800_:
{
lean_object* v___x_802_; lean_object* v___x_803_; uint8_t v___x_804_; lean_object* v___x_805_; lean_object* v___x_806_; 
v___x_802_ = ((lean_object*)(lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___closed__1));
lean_inc(v___y_801_);
v___x_803_ = lean_alloc_ctor(4, 2, 0);
lean_ctor_set(v___x_803_, 0, v___y_801_);
lean_ctor_set(v___x_803_, 1, v___x_802_);
v___x_804_ = 0;
v___x_805_ = lean_alloc_ctor(6, 1, 1);
lean_ctor_set(v___x_805_, 0, v___x_803_);
lean_ctor_set_uint8(v___x_805_, sizeof(void*)*1, v___x_804_);
v___x_806_ = l_Repr_addAppParen(v___x_805_, v_prec_799_);
return v___x_806_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr___boxed(lean_object* v_x_867_, lean_object* v_prec_868_){
_start:
{
lean_object* v_res_869_; 
v_res_869_ = lp_shell__lean__final_MemoryTransfer_Examples_instReprObservation_repr(v_x_867_, v_prec_868_);
lean_dec(v_prec_868_);
return v_res_869_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0(lean_object* v_a_870_, lean_object* v_n_871_){
_start:
{
lean_object* v___x_872_; 
v___x_872_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___redArg(v_a_870_);
return v___x_872_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0___boxed(lean_object* v_a_873_, lean_object* v_n_874_){
_start:
{
lean_object* v_res_875_; 
v_res_875_ = lp_shell__lean__final_List_repr_x27___at___00MemoryTransfer_Examples_instReprObservation_repr_spec__0(v_a_873_, v_n_874_);
lean_dec(v_n_874_);
return v_res_875_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_MemoryTransfer_Examples_observe(lean_object* v_size_878_, lean_object* v_x_879_){
_start:
{
switch(lean_obj_tag(v_x_879_))
{
case 0:
{
lean_object* v_state_880_; lean_object* v_count_881_; lean_object* v_mem_882_; lean_object* v_input_883_; lean_object* v_output_884_; lean_object* v___x_885_; lean_object* v___x_886_; 
v_state_880_ = lean_ctor_get(v_x_879_, 1);
lean_inc_ref(v_state_880_);
v_count_881_ = lean_ctor_get(v_x_879_, 0);
lean_inc(v_count_881_);
lean_dec_ref_known(v_x_879_, 2);
v_mem_882_ = lean_ctor_get(v_state_880_, 0);
lean_inc_ref(v_mem_882_);
v_input_883_ = lean_ctor_get(v_state_880_, 1);
lean_inc(v_input_883_);
v_output_884_ = lean_ctor_get(v_state_880_, 2);
lean_inc(v_output_884_);
lean_dec_ref(v_state_880_);
v___x_885_ = l_List_ofFn___redArg(v_size_878_, v_mem_882_);
v___x_886_ = lean_alloc_ctor(2, 4, 0);
lean_ctor_set(v___x_886_, 0, v_count_881_);
lean_ctor_set(v___x_886_, 1, v___x_885_);
lean_ctor_set(v___x_886_, 2, v_input_883_);
lean_ctor_set(v___x_886_, 3, v_output_884_);
return v___x_886_;
}
case 1:
{
lean_object* v_state_887_; uint8_t v_e_888_; lean_object* v_mem_889_; lean_object* v_input_890_; lean_object* v_output_891_; lean_object* v___x_892_; lean_object* v___x_893_; 
v_state_887_ = lean_ctor_get(v_x_879_, 0);
lean_inc_ref(v_state_887_);
v_e_888_ = lean_ctor_get_uint8(v_x_879_, sizeof(void*)*1);
lean_dec_ref_known(v_x_879_, 1);
v_mem_889_ = lean_ctor_get(v_state_887_, 0);
lean_inc_ref(v_mem_889_);
v_input_890_ = lean_ctor_get(v_state_887_, 1);
lean_inc(v_input_890_);
v_output_891_ = lean_ctor_get(v_state_887_, 2);
lean_inc(v_output_891_);
lean_dec_ref(v_state_887_);
v___x_892_ = l_List_ofFn___redArg(v_size_878_, v_mem_889_);
v___x_893_ = lean_alloc_ctor(1, 3, 1);
lean_ctor_set(v___x_893_, 0, v___x_892_);
lean_ctor_set(v___x_893_, 1, v_input_890_);
lean_ctor_set(v___x_893_, 2, v_output_891_);
lean_ctor_set_uint8(v___x_893_, sizeof(void*)*3, v_e_888_);
return v___x_893_;
}
default: 
{
lean_object* v___x_894_; 
lean_dec(v_size_878_);
v___x_894_ = lean_box(0);
return v___x_894_;
}
}
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Std(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_shell__lean__final_MemoryTransfer(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Std(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif

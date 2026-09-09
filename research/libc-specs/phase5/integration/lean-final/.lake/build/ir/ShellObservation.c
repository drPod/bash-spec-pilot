// Lean compiler output
// Module: ShellObservation
// Imports: public import Init public meta import Init public import BufferRelay
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
lean_object* lean_nat_to_int(lean_object*);
lean_object* lp_shell__lean__final_BufferRelay_run(lean_object*, lean_object*, lean_object*);
lean_object* lean_int_neg(lean_object*);
uint8_t lean_nat_dec_eq(lean_object*, lean_object*);
lean_object* l_List_appendTR___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg___boxed(lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___boxed(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim___boxed(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_call_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_call_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_seq_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_seq_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_andThen_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_andThen_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_orElse_elim___redArg(lean_object*, lean_object*);
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_orElse_elim(lean_object*, lean_object*, lean_object*, lean_object*, lean_object*);
static const lean_ctor_object lp_shell__lean__final_ShellObservation_andMark___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(33) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_ShellObservation_andMark___closed__0 = (const lean_object*)&lp_shell__lean__final_ShellObservation_andMark___closed__0_value;
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_andMark(lean_object*);
static const lean_ctor_object lp_shell__lean__final_ShellObservation_success___closed__0_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(99) << 1) | 1)),((lean_object*)(((size_t)(0) << 1) | 1))}};
static const lean_object* lp_shell__lean__final_ShellObservation_success___closed__0 = (const lean_object*)&lp_shell__lean__final_ShellObservation_success___closed__0_value;
static const lean_ctor_object lp_shell__lean__final_ShellObservation_success___closed__1_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(98) << 1) | 1)),((lean_object*)&lp_shell__lean__final_ShellObservation_success___closed__0_value)}};
static const lean_object* lp_shell__lean__final_ShellObservation_success___closed__1 = (const lean_object*)&lp_shell__lean__final_ShellObservation_success___closed__1_value;
static const lean_ctor_object lp_shell__lean__final_ShellObservation_success___closed__2_value = {.m_header = {.m_rc = 0, .m_cs_sz = sizeof(lean_ctor_object) + sizeof(void*)*2 + 0, .m_other = 2, .m_tag = 1}, .m_objs = {((lean_object*)(((size_t)(97) << 1) | 1)),((lean_object*)&lp_shell__lean__final_ShellObservation_success___closed__1_value)}};
static const lean_object* lp_shell__lean__final_ShellObservation_success___closed__2 = (const lean_object*)&lp_shell__lean__final_ShellObservation_success___closed__2_value;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_success___closed__3_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_success___closed__3;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_success___closed__4_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_success___closed__4;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_success___closed__5_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_success___closed__5;
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_success;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_lateError___closed__0_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_lateError___closed__0;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_lateError___closed__1_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_lateError___closed__1;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_lateError___closed__2_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_lateError___closed__2;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_lateError___closed__3_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_lateError___closed__3;
static lean_once_cell_t lp_shell__lean__final_ShellObservation_lateError___closed__4_once = LEAN_ONCE_CELL_INITIALIZER;
static lean_object* lp_shell__lean__final_ShellObservation_lateError___closed__4;
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_lateError;
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg(lean_object* v_x_1_){
_start:
{
switch(lean_obj_tag(v_x_1_))
{
case 0:
{
lean_object* v___x_2_; 
v___x_2_ = lean_unsigned_to_nat(0u);
return v___x_2_;
}
case 1:
{
lean_object* v___x_3_; 
v___x_3_ = lean_unsigned_to_nat(1u);
return v___x_3_;
}
case 2:
{
lean_object* v___x_4_; 
v___x_4_ = lean_unsigned_to_nat(2u);
return v___x_4_;
}
default: 
{
lean_object* v___x_5_; 
v___x_5_ = lean_unsigned_to_nat(3u);
return v___x_5_;
}
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg___boxed(lean_object* v_x_6_){
_start:
{
lean_object* v_res_7_; 
v_res_7_ = lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg(v_x_6_);
lean_dec_ref(v_x_6_);
return v_res_7_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx(lean_object* v_Atom_8_, lean_object* v_x_9_){
_start:
{
lean_object* v___x_10_; 
v___x_10_ = lp_shell__lean__final_ShellObservation_Command_ctorIdx___redArg(v_x_9_);
return v___x_10_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorIdx___boxed(lean_object* v_Atom_11_, lean_object* v_x_12_){
_start:
{
lean_object* v_res_13_; 
v_res_13_ = lp_shell__lean__final_ShellObservation_Command_ctorIdx(v_Atom_11_, v_x_12_);
lean_dec_ref(v_x_12_);
return v_res_13_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(lean_object* v_t_14_, lean_object* v_k_15_){
_start:
{
if (lean_obj_tag(v_t_14_) == 0)
{
lean_object* v_name_16_; lean_object* v___x_17_; 
v_name_16_ = lean_ctor_get(v_t_14_, 0);
lean_inc(v_name_16_);
lean_dec_ref_known(v_t_14_, 1);
v___x_17_ = lean_apply_1(v_k_15_, v_name_16_);
return v___x_17_;
}
else
{
lean_object* v_left_18_; lean_object* v_right_19_; lean_object* v___x_20_; 
v_left_18_ = lean_ctor_get(v_t_14_, 0);
lean_inc_ref(v_left_18_);
v_right_19_ = lean_ctor_get(v_t_14_, 1);
lean_inc_ref(v_right_19_);
lean_dec_ref(v_t_14_);
v___x_20_ = lean_apply_2(v_k_15_, v_left_18_, v_right_19_);
return v___x_20_;
}
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim(lean_object* v_Atom_21_, lean_object* v_motive_22_, lean_object* v_ctorIdx_23_, lean_object* v_t_24_, lean_object* v_h_25_, lean_object* v_k_26_){
_start:
{
lean_object* v___x_27_; 
v___x_27_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_24_, v_k_26_);
return v___x_27_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_ctorElim___boxed(lean_object* v_Atom_28_, lean_object* v_motive_29_, lean_object* v_ctorIdx_30_, lean_object* v_t_31_, lean_object* v_h_32_, lean_object* v_k_33_){
_start:
{
lean_object* v_res_34_; 
v_res_34_ = lp_shell__lean__final_ShellObservation_Command_ctorElim(v_Atom_28_, v_motive_29_, v_ctorIdx_30_, v_t_31_, v_h_32_, v_k_33_);
lean_dec(v_ctorIdx_30_);
return v_res_34_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_call_elim___redArg(lean_object* v_t_35_, lean_object* v_call_36_){
_start:
{
lean_object* v___x_37_; 
v___x_37_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_35_, v_call_36_);
return v___x_37_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_call_elim(lean_object* v_Atom_38_, lean_object* v_motive_39_, lean_object* v_t_40_, lean_object* v_h_41_, lean_object* v_call_42_){
_start:
{
lean_object* v___x_43_; 
v___x_43_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_40_, v_call_42_);
return v___x_43_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_seq_elim___redArg(lean_object* v_t_44_, lean_object* v_seq_45_){
_start:
{
lean_object* v___x_46_; 
v___x_46_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_44_, v_seq_45_);
return v___x_46_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_seq_elim(lean_object* v_Atom_47_, lean_object* v_motive_48_, lean_object* v_t_49_, lean_object* v_h_50_, lean_object* v_seq_51_){
_start:
{
lean_object* v___x_52_; 
v___x_52_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_49_, v_seq_51_);
return v___x_52_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_andThen_elim___redArg(lean_object* v_t_53_, lean_object* v_andThen_54_){
_start:
{
lean_object* v___x_55_; 
v___x_55_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_53_, v_andThen_54_);
return v___x_55_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_andThen_elim(lean_object* v_Atom_56_, lean_object* v_motive_57_, lean_object* v_t_58_, lean_object* v_h_59_, lean_object* v_andThen_60_){
_start:
{
lean_object* v___x_61_; 
v___x_61_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_58_, v_andThen_60_);
return v___x_61_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_orElse_elim___redArg(lean_object* v_t_62_, lean_object* v_orElse_63_){
_start:
{
lean_object* v___x_64_; 
v___x_64_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_62_, v_orElse_63_);
return v___x_64_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_Command_orElse_elim(lean_object* v_Atom_65_, lean_object* v_motive_66_, lean_object* v_t_67_, lean_object* v_h_68_, lean_object* v_orElse_69_){
_start:
{
lean_object* v___x_70_; 
v___x_70_ = lp_shell__lean__final_ShellObservation_Command_ctorElim___redArg(v_t_67_, v_orElse_69_);
return v___x_70_;
}
}
LEAN_EXPORT lean_object* lp_shell__lean__final_ShellObservation_andMark(lean_object* v_r_75_){
_start:
{
lean_object* v_output_76_; lean_object* v_status_77_; lean_object* v___x_78_; uint8_t v___x_79_; 
v_output_76_ = lean_ctor_get(v_r_75_, 0);
lean_inc(v_output_76_);
v_status_77_ = lean_ctor_get(v_r_75_, 2);
lean_inc(v_status_77_);
lean_dec_ref(v_r_75_);
v___x_78_ = lean_unsigned_to_nat(0u);
v___x_79_ = lean_nat_dec_eq(v_status_77_, v___x_78_);
lean_dec(v_status_77_);
if (v___x_79_ == 0)
{
return v_output_76_;
}
else
{
lean_object* v___x_80_; lean_object* v___x_81_; 
v___x_80_ = ((lean_object*)(lp_shell__lean__final_ShellObservation_andMark___closed__0));
v___x_81_ = l_List_appendTR___redArg(v_output_76_, v___x_80_);
return v___x_81_;
}
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_success___closed__3(void){
_start:
{
lean_object* v___x_94_; lean_object* v___x_95_; 
v___x_94_ = lean_unsigned_to_nat(3u);
v___x_95_ = lean_nat_to_int(v___x_94_);
return v___x_95_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_success___closed__4(void){
_start:
{
lean_object* v___x_96_; lean_object* v___x_97_; lean_object* v___x_98_; 
v___x_96_ = lean_box(0);
v___x_97_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_success___closed__3, &lp_shell__lean__final_ShellObservation_success___closed__3_once, _init_lp_shell__lean__final_ShellObservation_success___closed__3);
v___x_98_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_98_, 0, v___x_97_);
lean_ctor_set(v___x_98_, 1, v___x_96_);
return v___x_98_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_success___closed__5(void){
_start:
{
lean_object* v___x_99_; lean_object* v___x_100_; lean_object* v___x_101_; lean_object* v___x_102_; 
v___x_99_ = lean_box(0);
v___x_100_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_success___closed__4, &lp_shell__lean__final_ShellObservation_success___closed__4_once, _init_lp_shell__lean__final_ShellObservation_success___closed__4);
v___x_101_ = ((lean_object*)(lp_shell__lean__final_ShellObservation_success___closed__2));
v___x_102_ = lp_shell__lean__final_BufferRelay_run(v___x_101_, v___x_100_, v___x_99_);
return v___x_102_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_success(void){
_start:
{
lean_object* v___x_103_; 
v___x_103_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_success___closed__5, &lp_shell__lean__final_ShellObservation_success___closed__5_once, _init_lp_shell__lean__final_ShellObservation_success___closed__5);
return v___x_103_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError___closed__0(void){
_start:
{
lean_object* v___x_104_; lean_object* v___x_105_; 
v___x_104_ = lean_unsigned_to_nat(1u);
v___x_105_ = lean_nat_to_int(v___x_104_);
return v___x_105_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError___closed__1(void){
_start:
{
lean_object* v___x_106_; lean_object* v___x_107_; 
v___x_106_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_lateError___closed__0, &lp_shell__lean__final_ShellObservation_lateError___closed__0_once, _init_lp_shell__lean__final_ShellObservation_lateError___closed__0);
v___x_107_ = lean_int_neg(v___x_106_);
return v___x_107_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError___closed__2(void){
_start:
{
lean_object* v___x_108_; lean_object* v___x_109_; lean_object* v___x_110_; 
v___x_108_ = lean_box(0);
v___x_109_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_lateError___closed__1, &lp_shell__lean__final_ShellObservation_lateError___closed__1_once, _init_lp_shell__lean__final_ShellObservation_lateError___closed__1);
v___x_110_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_110_, 0, v___x_109_);
lean_ctor_set(v___x_110_, 1, v___x_108_);
return v___x_110_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError___closed__3(void){
_start:
{
lean_object* v___x_111_; lean_object* v___x_112_; lean_object* v___x_113_; 
v___x_111_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_lateError___closed__2, &lp_shell__lean__final_ShellObservation_lateError___closed__2_once, _init_lp_shell__lean__final_ShellObservation_lateError___closed__2);
v___x_112_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_success___closed__3, &lp_shell__lean__final_ShellObservation_success___closed__3_once, _init_lp_shell__lean__final_ShellObservation_success___closed__3);
v___x_113_ = lean_alloc_ctor(1, 2, 0);
lean_ctor_set(v___x_113_, 0, v___x_112_);
lean_ctor_set(v___x_113_, 1, v___x_111_);
return v___x_113_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError___closed__4(void){
_start:
{
lean_object* v___x_114_; lean_object* v___x_115_; lean_object* v___x_116_; lean_object* v___x_117_; 
v___x_114_ = lean_box(0);
v___x_115_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_lateError___closed__3, &lp_shell__lean__final_ShellObservation_lateError___closed__3_once, _init_lp_shell__lean__final_ShellObservation_lateError___closed__3);
v___x_116_ = ((lean_object*)(lp_shell__lean__final_ShellObservation_success___closed__2));
v___x_117_ = lp_shell__lean__final_BufferRelay_run(v___x_116_, v___x_115_, v___x_114_);
return v___x_117_;
}
}
static lean_object* _init_lp_shell__lean__final_ShellObservation_lateError(void){
_start:
{
lean_object* v___x_118_; 
v___x_118_ = lean_obj_once(&lp_shell__lean__final_ShellObservation_lateError___closed__4, &lp_shell__lean__final_ShellObservation_lateError___closed__4_once, _init_lp_shell__lean__final_ShellObservation_lateError___closed__4);
return v___x_118_;
}
}
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_Init(uint8_t builtin);
lean_object* initialize_shell__lean__final_BufferRelay(uint8_t builtin);
static bool _G_initialized = false;
LEAN_EXPORT lean_object* initialize_shell__lean__final_ShellObservation(uint8_t builtin) {
lean_object * res;
if (_G_initialized) return lean_io_result_mk_ok(lean_box(0));
_G_initialized = true;
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_Init(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
res = initialize_shell__lean__final_BufferRelay(builtin);
if (lean_io_result_is_error(res)) return res;
lean_dec_ref(res);
lp_shell__lean__final_ShellObservation_success = _init_lp_shell__lean__final_ShellObservation_success();
lean_mark_persistent(lp_shell__lean__final_ShellObservation_success);
lp_shell__lean__final_ShellObservation_lateError = _init_lp_shell__lean__final_ShellObservation_lateError();
lean_mark_persistent(lp_shell__lean__final_ShellObservation_lateError);
return lean_io_result_mk_ok(lean_box(0));
}
#ifdef __cplusplus
}
#endif

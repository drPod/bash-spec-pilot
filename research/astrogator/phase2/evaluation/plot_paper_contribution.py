#!/usr/bin/env python3
"""Two-panel paper-level evidence: compiler fidelity and downstream decision preservation."""
import csv,hashlib,json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from plot_evaluation import HERE

def main():
    paths=[HERE.parent/'integration/translation-summary.json',HERE.parent/'end_to_end/all-summary.json']
    t,e=[json.loads(p.read_text())for p in paths]
    assert len(t['arms'])==4 and all(a['complete']for a in t['arms'].values())
    assert set(e['arms'])=={'compact-all','handbook-all'}and all(a['complete']for a in e['arms'].values())
    fig,(a,b)=plt.subplots(1,2,figsize=(13,8),sharey=True,gridspec_kw={'width_ratios':[1,1.4],'wspace':.12})
    rows=[];names=[]
    for guide in ('compact','handbook'):
        for model,identity in [('gpt6','gpt-6-astra'),('opus55','claude-opus-5-5')]:
            for rep in ('0','1','2'):
                i=len(rows);label=f"{guide.capitalize()} · {'GPT-6'if model=='gpt6'else'Opus 5.5'} · r{rep}";names.append(label)
                stage=t['arms'][guide+'/'+identity]['per_repeat'][rep];out=e['arms'][guide+'-all']['models'][model][rep]['reference_decided'];assert out['denominator']==1528
                assert sum(out[k]for k in ('same_decision','became_unavailable','accept_to_reject','reject_to_accept'))==1528
                a.barh(i-.17,stage['lowered'],height=.29,color='#4C72B0',label='Compiler success'if i==0 else None)
                a.barh(i+.17,stage['effect_match'],height=.29,color='#55A868',label='Reference-effect agreement'if i==0 else None)
                for y,v in [(i-.17,stage['lowered']),(i+.17,stage['effect_match'])]:a.text(v-.2,y,str(v),ha='right',va='center',fontsize=7,color='white')
                left=0
                for key,color,title in [('same_decision','#55A868','Same decision'),('became_unavailable','#A6A6A6','Became unavailable'),('accept_to_reject','#DD8452','Accept → reject'),('reject_to_accept','#C44E52','Reject → accept')]:
                    v=out[key];b.barh(i,v,left=left,height=.72,color=color,label=title if i==0 else None)
                    if v>=40:b.text(left+v/2,i,str(v),ha='center',va='center',fontsize=7,color='black'if key=='became_unavailable'else'white')
                    left+=v
                rows.append({'guide':guide,'model':model,'repeat':rep,'tasks':21,**stage,**out})
    a.set_yticks(range(len(names)),names);a.invert_yaxis();a.set_xlim(0,21);a.set_xticks([0,5,10,15,21]);a.set_xlabel('Tasks / 21');b.set_xlim(0,1528);b.set_xlabel('Programs decided by supplied-query control / 1,528')
    a.set_title('A. Query compilation and effect agreement',fontsize=11);b.set_title('B. Downstream decision preservation',fontsize=11)
    for ax in(a,b):ax.grid(axis='x',alpha=.15);ax.set_axisbelow(True);ax.spines[['top','right']].set_visible(False)
    for y in(2.5,5.5,8.5):
        for ax in(a,b):ax.axhline(y,color='#dddddd',linewidth=.7)
    a.legend(loc='upper left',bbox_to_anchor=(0,-.1),frameon=False,fontsize=8)
    b.legend(loc='upper left',bbox_to_anchor=(0,-.1),frameon=False,fontsize=8,ncol=2)
    fig.suptitle('Compiler-grounded guidance preserves more of the verification pipeline',fontsize=14,y=.98)
    fig.text(.02,.018,'Same 21 tasks and program corpus across conditions; all three task-level translation repeats shown. Agreement is not correctness.\nReference-effect equality is a compiler-representation check. Panel B excludes 710 supplied-query-unavailable programs; the full corpus has 2,238 programs.\nDefault verifier semantics; residual obligations remain. Supplied queries are controls, not independently validated gold.',fontsize=8)
    fig.subplots_adjust(left=.24,right=.98,top=.92,bottom=.2)
    out=HERE/'figures-paper';out.mkdir(exist_ok=True)
    for ext in('png','pdf'):fig.savefig(out/f'paper-contribution.{ext}',dpi=220)
    with(out/'paper-contribution.csv').open('w',newline='')as f:w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    (out/'CAPTION.md').write_text('''# Compiler-grounded query generation and verification preservation

**A.** Compiler success and reference-effect agreement among the same21tasks per repetition. Reference-effect agreement compares normalized compiler effects; it is not a complete semantic-equivalence proof or independently reviewed user-intent label. The handbook adds compiler-grounded documentation/examples; this is a prompt-information intervention, not constrained decoding or a matched-token-budget experiment.

**B.** Outcomes restricted to the same1,528programs for which the verbatim supplied-query control produced an accept/reject decision. All three repetitions are retained separately. Green preserves that decision, gray loses the decision, orange flips acceptance to rejection, and red flips rejection to acceptance. Counts smaller than40remain visible as segments and are exact in CSV. These transitions are not automatically new errors or corrections. The full2,238program corpus includes710supplied-query-unavailable programs; all-program stages appear in the companion pipeline figure/JSON. The supplied a18 query uses its actual domain, unlike the older corpus sweep's domain substitution; nine control differences are recorded in the source summary.

The same21tasks and programs recur across conditions, so repetitions and program/query cells are not independent problems. Behavioral labels exist only for four selected tasks; the other17tasks support paired decision evidence, not correctness rates. Original pinned default permission semantics are used. Acceptance may retain modeled assumptions/residuals. GPT-6 Astra is the requested CLI model; successful Claude responses report Opus5.5. Provider budgets differ and global Claude CLI plugin hooks remained active. The fixed benchmark and outcome-informed development cannot establish unseen-task generalization.
''')
    (out/'manifest.json').write_text(json.dumps({'input_sha256':{str(p):hashlib.sha256(p.read_bytes()).hexdigest()for p in paths},'script_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in out.iterdir()if p.name!='manifest.json'}},indent=2)+'\n')
    print(out)
if __name__=='__main__':main()

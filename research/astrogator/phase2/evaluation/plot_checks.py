#!/usr/bin/env python3
"""Plot generated checks only on a common resolved cohort; no denominator mixing."""
import argparse,csv,hashlib,json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from plot_evaluation import HERE,NAMES,COLORS

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--include-python',action='store_true');a=ap.parse_args()
    source=HERE/('common-all-checks.json' if a.include_python else 'common-dsl-checks.json')
    d=json.loads(source.read_text());assert d['complete'];ms=d['metrics']['strict_integrity']
    order=[m for m in ms if m not in ('judge','native_syntax','astrogator_configured_heuristics')]
    names=dict(NAMES)
    for m in order:
        if m.startswith(('dsl_','python_')):
            arm,modelrep=m.split('_',1);model,rep=modelrep.split('-')
            names[m]=f"{'Python' if arm=='python' else 'DSL'} checks: {'GPT-6' if model=='gpt6' else 'Opus 5.5'}, {rep}"
    fig,axes=plt.subplots(1,2,figsize=(12,max(5,len(order)*.39)),sharey=True,gridspec_kw={'wspace':.08})
    for ax,label in zip(axes,('fail','pass')):
        totals=[]
        for i,m in enumerate(order):
            left=0
            for dec,prefix in [('reject','rejected'),('accept','accepted'),('unavailable','unavailable')]:
                v=ms[m][prefix+'_'+label]
                ax.barh(i,v,left=left,color=COLORS[dec],height=.7,label=dec.capitalize() if i==0 else None)
                if v>=4:ax.text(left+v/2,i,str(v),ha='center',va='center',fontsize=8,color='black' if dec=='unavailable' else 'white')
                left+=v
            totals.append(left)
        assert len(set(totals))==1
        ax.set(xlim=(0,totals[0]),xlabel='Programs',title=f"Locally {'failing' if label=='fail' else 'passing'} programs (n = {totals[0]})")
        ax.grid(axis='x',alpha=.15);ax.set_axisbelow(True)
    axes[0].set_yticks(range(len(order)),[names[m] for m in order]);axes[0].invert_yaxis()
    axes[1].legend(loc='lower right',bbox_to_anchor=(1,-.2),ncol=3,frameon=False)
    fig.suptitle(f"Generated checks and direct judgment — matched {d['common_programs']}-program cohort",fontsize=12)
    fig.text(.02,.015,'Strict password integrity; exact-byte file checks. Shared researcher-authored fixtures; every repetition shown.\nVerifier uses default semantics; unavailable is not rejection. See caption for generation and oracle limits.'+('\nPython Opus unavailable: frozen runner rejects stdout/getent patterns; not demonstrated semantic test failure.' if a.include_python else ''),fontsize=8)
    fig.subplots_adjust(left=.33,right=.98,top=.9,bottom=.2)
    out=HERE/('figures-all-checks' if a.include_python else 'figures-dsl-checks');out.mkdir(exist_ok=True)
    for ext in ('png','pdf'):fig.savefig(out/f'matched-checks.{ext}',dpi=220)
    with (out/'matched-checks.csv').open('w',newline='') as f:
        rows=[{'method':m,**ms[m]} for m in order];w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
    timeout_note=' Python Opus r0 has 205 gate abstentions and r1 has 106: read-only stdout/getent patterns are rejected by conservative frozen runner restrictions. These are compatibility limits, not demonstrated semantic failures. Candidate execution timeouts leave labels unresolved; the frozen policy does not retry them as infrastructure failures or borrow historical labels. Descendant cleanup may outlast the inner timeout, with a 110-second outer container cap for Python execution.' if a.include_python else ''
    (out/'CAPTION.md').write_text(f"# Matched generated-check comparison\n\nEvery plotted method uses the same {d['common_programs']} programs with resolved labels in all included generated-check arms. Excluded identities: {d['excluded_by_arm']}. Primary judge/verifier results retain422 and are reported separately.{timeout_note} Strict-integrity labels are an outcome-informed sensitivity, not independently approved gold. All check repetitions are shown separately, without selecting the best. Researchers supplied fixtures and post-generation reference gates; fixture discovery was not automated. Verifier permission semantics are upstream default and acceptance may retain residual obligations. Debian metadata changes heuristic scope only. GPT-6 Astra is the requested model alias; successful Claude responses report Opus5.5. Inference budgets differ and Claude CLI global plugin hooks remained active. This is descriptive evidence on four selected tasks.\n")
    (out/'manifest.json').write_text(json.dumps({'input_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'source':str(source),'script_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in out.iterdir() if p.name!='manifest.json'}},indent=2)+'\n')
    print(out)
if __name__=='__main__':main()

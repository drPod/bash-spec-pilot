#!/usr/bin/env python3
"""Plot completed all-task NL→FQL pipeline stages, not unlabeled accuracy."""
import csv,hashlib,json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from plot_evaluation import HERE,COLORS

def main():
    source=HERE.parent/'end_to_end/all-summary.json';d=json.loads(source.read_text())
    assert set(d['arms'])=={'compact-all','handbook-all'} and all(a['complete'] for a in d['arms'].values())
    plotted=[]
    fig,axes=plt.subplots(1,2,figsize=(12,6),sharex=True,sharey=True)
    for ax,(arm,data) in zip(axes,sorted(d['arms'].items())):
        names=['Supplied-query control']
        control=data['control_statuses'];ca=control.get('accepted_with_possible_residuals',0);cr=control.get('verification_rejected',0);cu=2238-ca-cr
        left=0
        for dec,v in [('accept',ca),('reject',cr),('unavailable',cu)]:
            ax.barh(0,v,left=left,height=.65,color=COLORS[dec],label=dec.capitalize())
            if v>=50:ax.text(left+v/2,0,str(v),ha='center',va='center',color='black' if dec=='unavailable' else 'white',fontsize=8)
            left+=v
        plotted.append({'guide':arm,'model':'supplied_query_control','repeat':'control','accept':ca,'reject':cr,'unavailable':cu,'status_changes_vs_supplied':0})
        for model,reps in data['models'].items():
            for rep,s in sorted(reps.items()):
                i=len(names);names.append(f"{'GPT-6' if model=='gpt6' else 'Opus 5.5'} r{rep}")
                accept=s['statuses'].get('accepted_with_possible_residuals',0);reject=s['statuses'].get('verification_rejected',0);unavailable=2238-accept-reject
                assert accept+reject==s['decisions']
                left=0
                for dec,v in [('accept',accept),('reject',reject),('unavailable',unavailable)]:
                    ax.barh(i,v,left=left,height=.65,color=COLORS[dec],label=None)
                    if v>=50:ax.text(left+v/2,i,str(v),ha='center',va='center',color='black' if dec=='unavailable' else 'white',fontsize=8)
                    left+=v
                plotted.append({'guide':arm,'model':model,'repeat':rep,'accept':accept,'reject':reject,'unavailable':unavailable,'status_changes_vs_supplied':s['changed_status'],**{'transition_'+k:v for k,v in s['transitions'].items()}})
        ax.set_yticks(range(len(names)),names);ax.set_xlim(0,2238);ax.set_xlabel('Processed programs');ax.set_title(arm.replace('-all','').capitalize()+' guide');ax.grid(axis='x',alpha=.15);ax.set_axisbelow(True)
    axes[0].invert_yaxis()
    axes[1].legend(loc='lower right',bbox_to_anchor=(1,-.22),ncol=3,frameon=False)
    fig.suptitle('Natural language → generated FQL → original verifier: all 21 tasks',fontsize=13)
    fig.text(.03,.025,'Each row reuses the same 2,238 programs; three task-level translation repeats per model. Supplied-query agreement is not accuracy.\nExecution labels exist for only four tasks. Unavailable includes query failures and program lowering failures; detailed stages in CSV/JSON.\nDefault permission semantics; acceptance remains conditional on modeled assumptions and residual obligations.',fontsize=8)
    fig.subplots_adjust(left=.23,right=.98,top=.88,bottom=.23,wspace=.08)
    out=HERE/'figures-pipeline';out.mkdir(exist_ok=True)
    for ext in ('png','pdf'):fig.savefig(out/f'pipeline-stages.{ext}',dpi=220)
    fields=sorted(set().union(*(r.keys()for r in plotted)))
    with (out/'pipeline-stages.csv').open('w',newline='')as f:w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(plotted)
    (out/'CAPTION.md').write_text('''# End-to-end pipeline stages

All21 tasks and2,238 processed programs, with72 missing processed artifacts excluded. Each row evaluates one task-level query per task from a specified model and guide repetition. The same programs recur across rows; neither repeats nor program/query cells are independent tasks. The supplied-query control is not independently validated gold. The other17tasks have no behavioral labels, so this is stage/coverage evidence rather than accuracy. Exact status transitions and query text appear in the source summary and changed-cell files. Invalid queries and lowering failures are unavailable, not rejected programs. The original pinned verifier uses default permission semantics; acceptance may retain residual obligations. Budgets differ between model providers; global Claude CLI hooks remained active. See the separate four-task labeled comparison for local error counts and oracle sensitivity. No best-repeat selection is used.
''')
    (out/'manifest.json').write_text(json.dumps({'source':str(source),'input_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'script_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in out.iterdir()if p.name!='manifest.json'}},indent=2)+'\n')
    print(out)
if __name__=='__main__':main()

#!/usr/bin/env python3
"""Publication-style figures from COMPLETE paired runs only; also export plotted CSV.

Run: uv run --no-project --with matplotlib==3.10.7 python .../plot_evaluation.py
"""
import csv
import hashlib
import json
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

HERE=Path(__file__).resolve().parent
NAMES={'native_syntax':'Ansible syntax check','astrogator':'Astrogator base',
       'astrogator_configured_heuristics':'Astrogator + heuristics (all OS metadata)',
       'debian_metadata_heuristics':'Astrogator + heuristics (Debian metadata)',
       'judge':'Qwen 2.5 1.5B judge','gpt6':'GPT-6 Astra judge','opus55':'Opus 5.5 judge'}
ORDER=list(NAMES)
COLORS={'accept':'#4C72B0','reject':'#DD8452','unavailable':'#A6A6A6'}


def main():
    paths=[HERE/'frontier-full-comparison.json',HERE/'additional-baselines.json',HERE/'revised-summary.json']
    frontier,extra,revised=[json.loads(p.read_text()) for p in paths]
    assert all(frontier['complete'].values()) and all(extra['complete'].values()) and revised['complete']
    assert frontier['expected_processed']==422 and revised['observed_cases']==410
    for source in (frontier,extra):assert 'strict_integrity' in source['metrics']
    metrics={variant:{m:(extra if m in ('native_syntax','debian_metadata_heuristics') else frontier)['metrics'][variant][m]
                      for m in ORDER} for variant in ('original','strict_integrity','newline_sensitivity')}
    output=HERE/'figures';output.mkdir(exist_ok=True)
    plotted=[]
    for variant,ms in metrics.items():
        for m,s in ms.items():plotted.append({'label_variant':variant,'method':m,**s})
    fields=list(plotted[0])
    with (output/'paired-outcomes.csv').open('w',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=fields);writer.writeheader();writer.writerows(plotted)
    plt.rcParams.update({'font.family':'DejaVu Sans','font.size':9,'axes.spines.top':False,'axes.spines.right':False,
                         'pdf.fonttype':42,'ps.fonttype':42})
    for variant in ('original','strict_integrity'):
        ms=metrics[variant];first=next(iter(ms.values()))
        fails=first['accepted_fail']+first['rejected_fail']+first['unavailable_fail']
        passes=first['accepted_pass']+first['rejected_pass']+first['unavailable_pass']
        fig,axes=plt.subplots(1,2,figsize=(12,4.8),sharey=True,gridspec_kw={'wspace':.08})
        for ax,label,total in zip(axes,('fail','pass'),(fails,passes)):
            left=np.zeros(len(ORDER))
            for decision,prefix in [('reject','rejected'),('accept','accepted'),('unavailable','unavailable')]:
                values=np.array([ms[m][prefix+'_'+label] for m in ORDER])
                ax.barh(np.arange(len(ORDER)),values,left=left,color=COLORS[decision],height=.7,label=decision.capitalize())
                for i,v in enumerate(values):
                    if v>=4:ax.text(left[i]+v/2,i,str(v),va='center',ha='center',color='white' if decision!='unavailable' else 'black',fontsize=8)
                left+=values
            ax.set_xlim(0,total);ax.set_xlabel('Programs');ax.grid(axis='x',alpha=.15);ax.set_axisbelow(True)
            ax.set_title(f'Locally failing programs (n = {fails})' if label=='fail' else f'Locally passing programs (n = {passes})',fontsize=11)
        axes[0].set_yticks(np.arange(len(ORDER)),[NAMES[m] for m in ORDER]);axes[0].invert_yaxis()
        axes[1].legend(loc='lower right',bbox_to_anchor=(1,-.25),ncol=3,frameon=False)
        title='Original local checks' if variant=='original' else 'Revised password integrity; exact-byte file checks'
        fig.suptitle(title+' — complete 422-program comparison',fontsize=12,y=.99)
        fig.text(.02,.015,'Four selected tasks on Debian. Verifier mode: upstream default; accepts may carry residual obligations. Unavailable is not rejection.',fontsize=8)
        fig.subplots_adjust(left=.31,right=.98,top=.87,bottom=.2)
        for suffix in ('png','pdf'):fig.savefig(output/f'paired-outcomes-{variant}.{suffix}',dpi=220)
        plt.close(fig)
    fig,ax=plt.subplots(figsize=(8,5))
    marks={'original':'o','strict_integrity':'s','newline_sensitivity':'^'}
    palette=plt.get_cmap('tab10')
    for i,m in enumerate(ORDER):
        xy=[]
        for variant in metrics:
            s=metrics[variant][m]
            if s['accepted_failure_risk'] is None:continue
            x,y=s['coverage']*100,s['accepted_failure_risk']*100;xy.append((x,y))
            ax.scatter(x,y,c=[palette(i)],marker=marks[variant],s=45,zorder=3)
        if xy:
            ax.plot([p[0] for p in xy],[p[1] for p in xy],color=palette(i),alpha=.55,linewidth=.8)
            ax.plot([],[],marker='o',linestyle='',color=palette(i),label=NAMES[m])
    ax.set(xlabel='Decision coverage (%)',ylabel='Locally failing fraction among accepted programs (%)',
           title='Coverage and accepted-program risk under label sensitivity')
    minimum_coverage=min(s['coverage']*100 for ms in metrics.values() for s in ms.values())
    ax.grid(alpha=.2);ax.set_xlim(max(0,minimum_coverage-4),102);ax.set_ylim(bottom=-1)
    ax.legend(loc='upper left',bbox_to_anchor=(1.01,1),frameon=False,fontsize=8)
    fig.text(.08,.015,'Markers: circle = original; square = strict password integrity; triangle = final-newline sensitivity.\nNo observed accepted failures does not prove zero true risk; these are four selected tasks.',fontsize=8)
    fig.subplots_adjust(left=.1,right=.61,top=.9,bottom=.2)
    for suffix in ('png','pdf'):fig.savefig(output/f'coverage-risk-sensitivity.{suffix}',dpi=220)
    plt.close(fig)
    (output/'CAPTIONS.md').write_text('''# Figure captions

**Paired outcomes.** All 422 processed programs from the four-task slice, with method decisions separated by local behavioral/execution labels. Original and revised-label panels use the same predictions. Orange denotes rejection, blue acceptance, and gray unavailability; these colors encode decisions, not an unconditional judgment of correctness. The revised labels strengthen password-account integrity using a real hash fixture while retaining exact-byte file checks. Verifier mode is pinned upstream default permission semantics. Astrogator outputs remain conditional on its model and residual obligations. The Debian arm changes heuristic metadata scope only, not verifier OS branches. The experimental constant-mode permission guard is evaluated separately.

**Coverage and accepted-program risk.** Each method's decision coverage and fraction of locally failing programs among accepted programs under three explicitly separated label interpretations. Circles use original checks, squares revised password integrity, and triangles additionally permit one final newline when creating the a06 file. Undefined acceptance risk would be omitted, not plotted as zero. These are descriptive development-suite results, not task-generalization estimates. Provider inference budgets differ; no latency or cost comparison is implied.

CSV data and source SHA-256 hashes accompany the PDF and PNG figures. These figures are generated only after both full frontier runs and the oracle sensitivity study are complete.

Model identity: GPT-6 Astra is the requested CLI model (`gpt-6-astra`); its event stream does not independently attest the server-resolved revision. Successful Opus responses report `claude-opus-5-5` in provider model-usage metadata.

The saved task prompts omit labels, reference solutions, and oracle code. Global Claude CLI session hooks remained active; completely empty client context is not established. Provider inference budgets differ.
''')
    manifest={'matplotlib_version':matplotlib.__version__,'input_sha256':{str(p.relative_to(HERE)):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
              'script_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'files':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in output.iterdir() if p.is_file() and p.name!='manifest.json'}}
    (output/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({'output':str(output),'files':sorted(manifest['files'])}))


if __name__=='__main__':main()

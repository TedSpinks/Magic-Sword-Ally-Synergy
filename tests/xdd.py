# delta-debug the junk set (seed 1) in 0x40-byte chunks over 0-0x8000: smallest set of chunks that still stalls
import subprocess,sys,os
SEED=sys.argv[1]; CH=0x100
chunks=list(range(0,0x8000,CH))
def spec(cs): return ','.join('%X-%X'%(c,c+CH) for c in cs)
cache={}
def start(cs):
    env=dict(os.environ,MS_SEED=SEED)
    return subprocess.Popen(['python3','xj.py',spec(cs),'x'],stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True,env=env)
def fin(p): return p.communicate()[0].strip().endswith('STALL')
def test2(a,b):
    pa,pb=start(a),start(b) if b is not None else None
    return fin(pa),(fin(pb) if pb else None)
cs=chunks; n=2
print('full set stalls?',test2(cs,None)[0],flush=True)
while len(cs)>1:
    size=max(1,len(cs)//n); parts=[cs[i:i+size] for i in range(0,len(cs),size)]
    red=False
    for i in range(0,len(parts),2):
        a=parts[i]; b=parts[i+1] if i+1<len(parts) else None
        ra,rb=test2(a,b)
        print(' subset %d chunks: %s'%(len(a),ra),'| subset %d chunks: %s'%(len(b),rb) if b else '',flush=True)
        if ra: cs=a; n=2; red=True; break
        if rb: cs=b; n=2; red=True; break
    if red: print('reduced to',len(cs),'chunks',flush=True); continue
    # try complements
    comps=[[c for c in cs if c not in p] for p in parts]
    for i in range(0,len(comps),2):
        a=comps[i]; b=comps[i+1] if i+1<len(comps) else None
        ra,rb=test2(a,b)
        print(' complement %d: %s'%(len(a),ra),'| complement: %s'%rb if b else '',flush=True)
        if ra: cs=a; n=max(n-1,2); red=True; break
        if rb: cs=b; n=max(n-1,2); red=True; break
    if red: print('reduced to',len(cs),'chunks',flush=True); continue
    if n>=len(cs): break
    n=min(len(cs),n*2)
print('MINIMAL chunk starts:',['%04X'%c for c in cs])

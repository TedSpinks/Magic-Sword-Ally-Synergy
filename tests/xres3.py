import sys,os; sys.path.insert(0,'.')
from xlib import *
core=sys.argv[1]; rom=sys.argv[2]; n=int(sys.argv[3]); res=[]
if core=='bsnes': os.environ['SETV']='bsnes_entropy=High'
for t in range(n):
    c=Core(CORES[core],S+'rom/'+rom); c.run(5)
    C.memmove(c.l.retro_get_memory_data(0),bytes(make_sram(7)),0x800)
    c.run(300)
    for step in range(14):
        c.tap(m(START),3,0); c.run(240)
        if c.b(0x401)==0 and c.b(0x402)==2 and c.b(0x403)==7: break
    c.run(300); ok=c.b(0x403)==7 and c.b(0x401)==0
    r='ok' if ok else 'STALL'
    if not ok:
        pcs=set()
        for i in range(10): c.run(5); pcs.add('%06X'%cpu(c)['pc'])
        r+=' scene=%d pcs=%s'%(c.b(0x401),sorted(pcs)[:3])
    res.append(r)
print(core,rom,'START-flow resume: stalls',sum(1 for x in res if x.startswith('STALL')),'of',n,res,flush=True)

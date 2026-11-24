import sys,os; sys.path.insert(0,'.')
from xlib import *
core=sys.argv[1]; rom=sys.argv[2]; n=int(sys.argv[3])
if core=='bsnes': os.environ['SETV']='bsnes_entropy=High'
res=[]
for t in range(n):
    c=Core(CORES[core],S+'rom/'+rom); c.run(5); c.run(400)
    for i in range(14): c.tap(m(START),3,60)
    c.run(300)
    if core=='bsnes':
        streak=0
        for i in range(90):
            c.run(1); pc=cpu(c)['pc']; streak=streak+1 if ((pc>>16)&0x7F)==8 and (pc&0xFFFF) in (0x8200,0x8203,0x8204,0x8205) else 0
        res.append('STALL' if streak>=60 else 'ok')
    else:
        a=c.w(0x460); c.run(60); b=c.w(0x460)
        res.append('ok' if (a!=b or c.b(0x401)!=0) else 'STALL?')
print(core,rom,res.count('STALL')+res.count('STALL?'),'of',n,res,flush=True)

import sys,ctypes; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from loadst import *
from lr import Core
def go(rom,choice):
    c=Core(S+'s9x_tw3.so',S+'rom/'+rom); c.run(10); loadst(c,'u_ending')
    before=c.sram(0x400,0x100)
    d=LEFT if choice=='NO' else RIGHT
    seq=[]; last=None
    for i in range(12000):
        pad=m(d) if i in range(30,40) else (m(Y) if i in range(60,64) else 0)
        c.run(1,pad=pad)
        sc=c.b(0x401)
        if sc!=last: seq.append(hex(sc)); last=sc
        if sc==2 and i>1500: c.run(400); break
    after=c.sram(0x400,0x100)
    rows=[]
    for k in range(10):
        e=after[k*16:k*16+16]
        rows.append((e[:6].decode('ascii','replace'),''.join(str(x) for x in e[6:13]),hex(e[13]),hex(e[14]),e[15]))
    new=[r for k,r in enumerate(rows) if after[k*16:k*16+16] not in [before[j*16:j*16+16] for j in range(10)]]
    snap(c).save(S+'shots/end2_%s_%s.png'%(rom[3:7],choice))
    return seq,new
for rom in ('ms_v110.sfc','ms_v111.sfc'):
    for ch in ('NO','YES'):
        s,n=go(rom,ch); print(rom,ch,'scenes',s,'new entry (name,score,floor,ally,level):',n)

# does WRAM $7E:FA00 (floor list) stay equal to the ROM list (flags stripped, shuffle aside) during play on every floor?
import sys,random; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
P=0x8500
rom=open(S+'rom/ms_v119.sfc','rb').read()
def off(a): return ((a>>16)&0x7F)*0x8000+(a&0x7FFF)
def romlist(fl):
    o=off(0x00B98A)+3*fl; a=rom[o]|rom[o+1]<<8|rom[o+2]<<16; p=off(a); L=[]
    while True:
        r=bytearray(rom[p:p+22]); w=r[0]|r[1]<<8
        if w==0xFFFF: return L
        L.append(r); p+=22
def norm(L):  # positions (word 0 without flags, bytes 2-5) in order + multiset of bytes 6-21
    pos=[((r[0]|r[1]<<8)&0x3FFF,bytes(r[2:6])) for r in L]; rest=sorted(bytes(r[6:]) for r in L); return pos,rest
fls=[int(x) for x in sys.argv[1:]] or list(range(1,51))
bad=[]
for fl in fls:
    c=Core(S+'s9x_tw3.so',S+'rom/ms_v119.sfc'); c.run(10)
    c.load(open(S+'states/f7_trig.raw','rb').read()); c.run(1)
    if fl!=7: c.poke(P+0xAE,(fl-1)&0xFF)
    for i in range(1500):
        pad=m(RIGHT) if c.w(P+4)>100 else (m(UP) if (i//4)%2 else 0)
        c.poke(0x431,160); c.run(1,pad=pad)
    R=romlist(fl); n=len(R)
    rnd=random.Random(fl); stuck=0; last=-1; res=[]
    for i in range(3000):
        c.poke(0x431,160)
        s=c.w(0x1328)
        if s==last: stuck+=1
        else: stuck=0; last=s
        F,Bk=(LEFT,RIGHT) if c.b(0x403) in (10,20) else (RIGHT,LEFT)
        pad=[m(F,B),m(F,B,Y),m(Bk,B),m(UP,B),m(F,B),m(DOWN)][(i//30)%6] if stuck>240 else [m(F),m(F,Y),m(F),m(F,B),m(F,B,Y),m(F)][(i//24)%6]
        c.run(1,pad=pad)
        if i%500==499:
            if c.b(0x403)!=fl: res.append('left'); break
            w=c.ram(0xFA00,22*n+2)
            W=[bytearray(w[k*22:k*22+22]) for k in range(n)]
            end=w[22*n]|w[22*n+1]<<8
            ok=norm(W)==norm(R)
            res.append('ok' if ok else 'DIFF')
    print(fl,n,res,flush=True)
    if 'DIFF' in res: bad.append(fl)
print('bad',bad)

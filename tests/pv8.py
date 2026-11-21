# all floors: reach each floor through the floor-7 door, walk, and at two points compare a plain pause with
# pause -> Thief's Log view -> back (screen, VRAM, WRAM outside the backup area, PPU/DMA/register state); save the view's picture.
import sys,ctypes,random; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
import numpy as np
from pvsec import secdiff
ROM=S+'rom/ms_v99.sfc'
P=0x8500
floors=[int(x) for x in sys.argv[1:]] or list(range(1,56))
def logall(c):
    sp=c.l.retro_get_memory_data(0)
    rec=bytes([0x7A]+[0xFF]*7); s=sum(rec[1:8])&0xFF
    ctypes.memmove(sp+0x500,rec+bytes([s^0xA5,0xFF]),10)
def bases(fl):
    c=Core(S+'s9x_tw3.so',ROM); c.run(10)
    c.load(open(S+'states/f7_trig.raw','rb').read()); c.run(1)
    logall(c)
    c.poke(P+0xAE,(fl-1)&0xFF)
    for i in range(1500):
        pad=m(RIGHT) if c.w(P+4)>100 else (m(UP) if (i//4)%2 else 0)
        c.poke(0x431,160); c.run(1,pad=pad)
    out=[]
    rnd=random.Random(fl); stuck=0; last=-1
    for i in range(3000):
        c.poke(0x431,160)
        s=c.w(0x1328)
        if s==last: stuck+=1
        else: stuck=0; last=s
        F,Bk=(LEFT,RIGHT) if c.b(0x403) in (10,20,52,53,54,55) else (RIGHT,LEFT)
        if stuck>240: pad=[m(F,B),m(F,B,Y),m(Bk,B),m(UP,B),m(F,B),m(DOWN)][(i//30)%6]
        else: pad=[m(F),m(F,Y),m(F),m(F,B),m(F,B,Y),m(F)][(i//24)%6]
        c.run(1,pad=pad)
        if i in (400,1100,1800,2500,2990): out.append((c.save(),c.b(0x403),c.w(0x132C),c.b(0x430)))
    return out
def grab(c): return dict(img=np.array(snap(c).convert('RGB')), ram=c.mem(2,0,0x20000), vram=c.mem(3,0,0x10000), st=c.save())
def run(view,st):
    c=Core(S+'s9x_tw3.so',ROM); c.run(10); c.load(st); c.run(1)
    c.tap(m(START),3,30)
    shot=None; pz=c.b(0x1298)
    if view:
        c.tap(m(SEL),3,30); shot=snap(c)
        c.tap(m(DOWN),3,10); c.tap(m(UP),3,10); c.tap(m(RIGHT),3,10); c.tap(m(SEL),3,30)
    return grab(c),shot,pz
bad=0
for fl in floors:
    npz=0
    for k,(st,f,cam,b430) in enumerate(bases(fl)):
        a,_,pz=run(False,st)
        if not pz:
            print('target',fl,'pt',k,'floor',f,'not pausable here'); continue
        npz+=1
        b,shot,_=run(True,st)
        d=[i for i in range(0x20000) if a['ram'][i]!=b['ram'][i] and not (0x2600<=i<0x5A60) and not (0x1C0<=i<0x200) and i!=0x460]
        vd=sum(a['vram'][i]!=b['vram'][i] for i in range(0x10000))
        px=int((a['img']!=b['img']).any(axis=2).sum())
        sd=secdiff(a['st'],b['st'])
        ok = px==0 and vd==0 and not d and not sd
        if not ok: bad+=1
        print('target',fl,'pt',k,'floor',f,'cam',cam,'paused',pz,'pixels',px,'vram',vd,'wram',[hex(x) for x in d[:8]],sd[:6],'OK' if ok else 'DIFF',flush=True)
        if shot: shot.save(S+'shots/pvf_%02d_%d.png'%(fl,k))
        from PIL import Image
        Image.fromarray(a['img']).save(S+'shots/pvg_%02d_%d.png'%(fl,k))
    print('target',fl,'paused points checked',npz,flush=True)
print('floors with differences:',bad)

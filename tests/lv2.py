# every floor 1-50: open the pause view after arriving; v119 vs v120 picture, and v120's live-list mark
import sys,ctypes; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
import numpy as np
P=0x8500
SH={2,3,15,17,18,27,35,39,42,45,48}
def view(rom,fl):
    c=Core(S+'s9x_tw3.so',S+'rom/'+rom); c.run(10)
    c.load(open(S+'states/f7_trig.raw','rb').read()); c.run(1)
    sp=c.l.retro_get_memory_data(0)
    rec=bytes([0x7A]+[0xFF]*7); s=sum(rec[1:8])&0xFF
    ctypes.memmove(sp+0x500,rec+bytes([s^0xA5,0xFF]),10)
    if fl!=7: c.poke(P+0xAE,(fl-1)&0xFF)
    for i in range(1500):
        pad=m(RIGHT) if c.w(P+4)>100 else (m(UP) if (i//4)%2 else 0)
        c.poke(0x431,160); c.run(1,pad=pad)
    for i in range(200): c.poke(0x431,160); c.run(1,pad=m(LEFT if fl in (10,20) else RIGHT))
    c.tap(m(START),3,40); c.tap(m(SEL),3,60)
    return np.array(snap(c).convert('RGB')), c.ram(0x5FF0,2), c.b(0x403)
res=[]
for fl in [int(x) for x in sys.argv[1:]] or range(1,51):
    a,_,f0=view('ms_v119.sfc',fl); b,mk,f1=view('ms120.sfc',fl)
    px=int((a!=b).any(axis=2).sum())
    tag='same' if px==0 else ('moved (shuffled floor)' if fl in SH else 'DIFFERENT')
    print(fl,'on',f0,f1,'mark',mk.hex(),'pixels',px,tag,flush=True)
    if px: snap  # keep
    if px:
        from PIL import Image; Image.fromarray(np.vstack([a,b])).save(S+'shots/lv2_%02d.png'%fl)

import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
from loadst import *
from PIL import Image, ImageChops
def shot(rom,f):
    c=Core(S+'s9x_tw.so',S+rom); c.run(10); loadst(c,'stairs')
    a=0xCA78+3*f; c.poke(0x1CE0,a&255); c.poke(0x1CE1,a>>8)
    for _ in range(500):
        c.run(1)
        if c.b(0x6F4)==1: break
    c.run(3)
    return snap(c).crop((150,20,256,200)).convert('RGB')
old='rom/ms_v64.sfc'; new='rom/ms_v66.sfc'
chg=[]
for f in range(52):
    a=shot(old,f); b=shot(new,f)
    if ImageChops.difference(a,b).getbbox(): chg.append(f)
    if False:
        b.resize((b.width*3,b.height*3),Image.NEAREST).save(S+'shots/v65_f%d.png'%f)
print('floors that differ v64 vs v65:',chg)

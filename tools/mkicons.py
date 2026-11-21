import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
from sprlayer import rgb, tile8
from PIL import Image
import pickle
names=['Amazon','BigMan','Wizard','Knight','Lizard','Ninja','Thief','Priest','Fairy']
hc=pickle.load(open(S+'heads_conv.pkl','rb')); g=pickle.load(open(S+'heads_raw.pkl','rb'))[0]['cg']
def enc_tile(px):  # px: 64 indices -> 32 bytes
    b=bytearray(32)
    for y in range(8):
        for x in range(8):
            v=px[y*8+x]; s=7-x
            b[y*2]|=(v&1)<<s; b[y*2+1]|=((v>>1)&1)<<s; b[16+y*2]|=((v>>2)&1)<<s; b[16+y*2+1]|=((v>>3)&1)<<s
    return bytes(b)
def enc16(idx):  # idx 16x16 list of lists -> 128 bytes: top row (TL,TR) then bottom row (BL,BR)
    out=b''
    for ty in (0,8):
        for tx in (0,8): out+=enc_tile([idx[ty+y][tx+x] for y in range(8) for x in range(8)])
    return out
blob=b''; pals=[]
for t in range(8):
    im=hc['conv'][t]; p=hc['choice'][t]; pal=[rgb(g[128+p*16+i]) for i in range(16)]
    idx=[[0]*16 for _ in range(16)]
    for y in range(16):
        for x in range(16):
            px=im.getpixel((x,y))
            if px[3]: idx[y][x]=pal.index(px[:3],1)
    blob+=enc16(idx); pals.append(p)
# fairy: copy its 16x16 graphic from VRAM (tile $2A, palette 1)
base=open(S+'states/door1_base.bin','rb').read()
c=Core(S+'s9x_tw2.so',ROM); c.run(10); c.load(base); c.run(1); c.poke(0x8B00+0xAB,0xF0)
c.run(28,pad=m(RIGHT)); c.run(2,pad=0); c.run(3,pad=m(UP)); c.run(380,pad=0)
from sprlayer import render
while True:   # pick a frame where both fairy halves ($2A top, $44 legs) are in VRAM
    c.run(1,pad=0); ts={e[3] for e in render(c)[1] if 0<=e[1]<256 and e[2]<110}
    if 0x2A in ts and 0x44 in ts: break
v=c.mem(3,0,0x10000)
def blk16(T): return b''.join(v[0xC000+tt*32:0xC000+tt*32+32] for tt in (T,T+1,T+16,T+17))
fairy=blk16(0x2A)+blk16(0x44)
blob+=fairy; pals.append(1)
open(S+'asm/icons.bin','wb').write(blob); print('icons.bin',len(blob),'bytes; palettes',pals)
pickle.dump(pals,open(S+'icons_pals.pkl','wb'))
# decode back for a check
gg=pickle.load(open(S+'fairy_cg.pkl','rb'))
im=Image.new('RGBA',(9*20,20),(60,52,70,255))
for k in range(9):
    pal=[rgb((g if k<8 else gg)[128+pals[k]*16+i]) for i in range(16)]
    chunk=blob[k*128:(k+1)*128]
    for r in range(2):
        for tx in range(2):
            px=tile8(chunk[r*64:(r+1)*64],tx,0,0)
            for n,ci in enumerate(px):
                if ci: im.putpixel((k*20+2+tx*8+n%8,2+r*8+n//8),pal[ci]+(255,))
im.resize((im.width*6,im.height*6),Image.NEAREST).save(S+'shots/icons_check.png')

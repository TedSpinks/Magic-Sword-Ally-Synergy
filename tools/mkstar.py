import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from PIL import Image
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
exec(open(S+'scripts/mkicons.py').read().split("names=")[0].split("from common")[0])
def enc_tile(px):
    b=bytearray(32)
    for y in range(8):
        for x in range(8):
            v=px[y*8+x]; s=7-x
            b[y*2]|=(v&1)<<s; b[y*2+1]|=((v>>1)&1)<<s; b[16+y*2]|=((v>>2)&1)<<s; b[16+y*2+1]|=((v>>3)&1)<<s
    return bytes(b)
def enc16(idx):
    out=b''
    for ty in (0,8):
        for tx in (0,8): out+=enc_tile([idx[ty+y][tx+x] for y in range(8) for x in range(8)])
    return out
post=Image.open(S+'shots/h17_post.png').convert('RGB')
m={(197,198,197):10,(139,182,197):11,(106,174,180):12,(90,121,156):13,(49,89,123):14,(16,32,57):15,(0,0,32):1,(8,0,0):9}
idx=[[m.get(post.getpixel((160+x,81+y)),0) for x in range(16)] for y in range(16)]
for r in idx: print(''.join('.123456789ABCDEF'[v] if v else '.' for v in r))
open(S+'asm/star.bin','wb').write(enc16(idx))
# palette-0 fallback (silver), same pixels
m0={10:10,11:9,12:8,13:7,14:7,15:1,1:1,9:1}
idx0=[[m0.get(v,0) for v in r] for r in idx]
open(S+'asm/star0.bin','wb').write(enc16(idx0))

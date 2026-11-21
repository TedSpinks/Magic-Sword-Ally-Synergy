import random
# 4bpp tiles: 0 blank, 1 TL, 2 T, 3 TR, 4 L, 5 R, 6 BL, 7 B, 8 BR, 9 fill, 10-15 stars (palette 7, colours 1-3)
def px(kind,x,y):
    top = kind in ('TL','T','TR'); bot = kind in ('BL','B','BR')
    left = kind in ('TL','L','BL'); right = kind in ('TR','R','BR')
    if kind=='fill': return 2
    if kind=='blank': return 0
    if (top and y<3) or (bot and y>4) or (left and x<3) or (right and x>4): return 0
    if (top and y==3) or (bot and y==4) or (left and x==3) or (right and x==4): return 1
    return 2
def tile(f):
    b=bytearray(32)
    for y in range(8):
        for x in range(8):
            c=f(x,y); bit=7-x
            for p in range(4):
                if c>>p&1: b[(y*2+(p&1))+(16 if p>=2 else 0)]|=1<<bit
    return b
out=bytearray()
for k in ['blank','TL','T','TR','L','R','BL','B','BR','fill']: out+=tile(lambda x,y,k=k: px(k,x,y))
# stars: (x,y,colour,shape) shape 0 = dot, 1 = plus
stars=[(2,5,1,0),(5,2,2,0),(3,3,3,1),(6,6,1,0),(1,1,2,1),(4,6,3,0)]
for sx,sy,c,sh in stars:
    pts={(sx,sy)}
    if sh: pts|={(sx-1,sy),(sx+1,sy),(sx,sy-1),(sx,sy+1)}
    out+=tile(lambda x,y: (c if (x,y)==(sx,sy) else (1 if (x,y) in pts else 0)))
with open('asm/boxgfx.inc','w') as f:
    for i in range(0,len(out),16): f.write('    db '+','.join('$%02X'%v for v in out[i:i+16])+'\n')
# star positions: cells outside the boxes and text rows
random.seed(7)
boxrows=set(range(4,9))|set(range(10,15))|set(range(16,21))
textrows={1,2,22,23,24,26}
cells=[]
for r in range(28):
    for c in range(32):
        if r in textrows: continue
        if r in boxrows and 1<=c<=30: continue
        cells.append((r,c))
pick=random.sample(cells,30)
with open('asm/stars.inc','w') as f:
    f.write('StarMap:   ; word offset into the BG1 map, tile|palette 7\n')
    for r,c in sorted(pick):
        t=10+random.randrange(6)
        f.write('    dw $%04X, $%04X\n'%((r*32+c)*2, t|(7<<10)))
    f.write('StarMapEnd:\n')
print(len(out), len(pick))

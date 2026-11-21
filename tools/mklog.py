# Thief's Log graphics: sprite icons, BG1 strip tiles, palettes -> asm/log_obj.bin, asm/log_bg.bin, asm/log_pal.bin
import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from loadst import *
from lr import Core
import math
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
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
def bgr(c): r,g,b=c; return (r>>3)|((g>>3)<<5)|((b>>3)<<10)
def palbytes(cols):
    out=b''
    for c in cols+[(0,0,0)]*(16-len(cols)): v=bgr(c); out+=bytes([v&0xFF,v>>8])
    return out
# ---- sprite icons: 8 heads (icons.bin), star, chest, door, start
icons=open(S+'asm/icons.bin','rb').read()
obj=icons[:8*128]+open(S+'asm/star.bin','rb').read()
def art(rows,key):
    return [[key.get(ch,0) for ch in row] for row in rows]
chest=art([
"................",
"................",
"................",
"..############..",
".#yyyyyyyyyyyy#.",
".#yoooooooooooy#",
".#yyyyyyyyyyyy#.",
".##############.",
".#yoooo##ooooy#.",
".#yoooo#w#oooy#.",
".#yoooo##ooooy#.",
".#yyyyyyyyyyyy#.",
".##############.",
"................",
"................",
"................"],{'#':1,'y':2,'o':3,'w':4})
door=art([
"................",
".....######.....",
"....#gggggg#....",
"...#gg....gg#...",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#g........g#..",
"..#gggggggggg#..",
"..############..",
"................"],{'#':1,'g':5,'w':4})
start=art([
"................",
"................",
"................",
"................",
"......#.........",
"......##........",
"..#####v#.......",
"..#vvvvvv#......",
"..#vvvvvv#......",
"..#####v#.......",
"......##........",
"......#.........",
"................",
"................",
"................",
"................"],{'#':1,'v':6})
# v99: the pause view's screen box: a 16x16 corner (top-left) and a 16x16 top edge, 2 px gold lines
corner=[[2 if (y<2 or x<2) else 0 for x in range(16)] for y in range(16)]
edge=[[2 if y<2 else 0 for x in range(16)] for y in range(16)]
for a in (chest,door,start,corner,edge): obj+=enc16(a)
open(S+'asm/log_obj.bin','wb').write(obj)
# ---- palettes: OBJ 0-2 from the game (WRAM copy), OBJ 3 ours, OBJ 7 the door's; BG 4 strip, BG 5 dim strip
c=Core(S+'s9x_tw.so',S+'rom/ms_v88.sfc'); c.run(10); loadst(c,'h17_pre')
obj012=c.ram(0x0D00,0x60)
rom=open(S+'rom/ms_v88.sfc','rb').read()
o=0x1F*0x8000; w=rom[o+0x1FA]|rom[o+0x1FB]<<8; src=o+0x350+((w<<5)&0xFFFF); door7=rom[src:src+32]
p3=palbytes([(0,0,0),(40,24,8),(240,200,40),(176,96,24),(255,255,255),(232,176,48),(120,220,120)])
LC={'A':[(232,176,48),(40,170,60),(190,255,170)],'B':[(0,0,0),(96,224,96),(0,0,0)],'C':[(0,0,0),(96,224,96),(0,0,0)]}[__import__('os').environ.get('LOOPV','A')]
bg4=palbytes([(0,0,0),(184,184,200),(96,96,120),(20,12,40),(220,60,30),(232,176,48),(255,208,128)]+LC)
bg5=palbytes([(0,0,0),(88,88,104),(56,56,72),(12,8,24),(104,40,24),(120,96,40),(136,112,72)])
bg6=palbytes([(0,0,0),(128,128,152),(72,72,96),(20,12,40),(176,52,28),(184,140,44),(216,176,112)]+[(r*3//4,g*3//4,b*3//4) for r,g,b in LC])
open(S+'asm/log_pal.bin','wb').write(obj012+p3+door7+bg4+bg5+bg6)
# ---- BG1 strip tiles: 0 blank, 1 top, 2 fill, 3 bottom, 4-7 left cap rows, 8-11 right cap rows
def col(kind,loop=None):                  # v97: a 3-row strip (24 px): its middle row lines up with a text row
    H=24
    img=[[0]*8 for _ in range(H)]
    for y in range(H):
        for x in range(8):
            v=3
            if y in (0,H-1): v=1
            elif y in (1,H-2): v=2
            if kind=='L':
                if x<4: v=0
                elif x==4: v=1
                elif x==5 and v==3: v=2
            if kind=='R':
                if x>3: v=0
                elif x==3: v=1
                elif x==2 and v==3: v=2
            if kind in 'LR' and loop=='ORB':
                cx=4.0
                d=math.hypot(x+0.5-cx,y+0.5-12.0)
                if d<=3.9: v=7
                if d<=2.8: v=8
                if d<=1.4 and x+0.5<cx and y<12: v=9
            if kind in 'LR' and not loop:
                cx=4.0
                d=math.hypot(x+0.5-cx,y+0.5-12.0)
                if d<=3.9: v=5
                if d<=2.8: v=4
                if d<=1.4 and x+0.5<cx and y<12: v=6
            img[y][x]=v
    if loop and loop!='ORB':
        k={'a':7,'b':8,'c':9}
        y0=12-len(loop)//2
        for yy,row in enumerate(loop):
            for xx,ch in enumerate(row):
                if ch in k: img[y0+yy][xx]=k[ch]
    return img
def tiles(img): return [enc_tile([img[r*8+y][x] for y in range(8) for x in range(8)]) for r in range(3)]
M=tiles(col('M')); L=tiles(col('L')); R=tiles(col('R'))
import os
V=os.environ.get('LOOPV','A')
EMB={'A':[".aaaa...",  # green orb (same shape as the red one)
          "aabbaa..",
          "abccbba.",
          "abcbbba.",
          "abbbbba.",
          "aabbbaa.",
          ".aaaaa..",
          "........"],
     'B':["..bbbb.b",  # ring arrow
          ".b....bb",
          "b....bbb",
          "b.......",
          "b......b",
          "b......b",
          ".b....b.",
          "..bbbb.."],
     'C':["..b.....",  # two arrows, right and left
          ".bb.....",
          "bbbbbbb.",
          ".bb.....",
          "..b.....",
          ".....b..",
          ".....bb.",
          ".bbbbbbb",
          ".....bb.",
          ".....b.."]}
E=EMB[V]
if V=='A': E=[r[:7].rjust(8,'.') if False else r for r in E]
if V=='A': E='ORB'
LL=tiles(col('L',E)); RR=tiles(col('R',E))
bg=bytes(32)+b''.join(M)+b''.join(L)+b''.join(R)+b''.join(LL)+b''.join(RR)   # 10-12 loop left cap, 13-15 loop right cap   # tiles 0 blank, 1-3 middle, 4-6 left cap, 7-9 right cap
open(S+'asm/log_bg.bin','wb').write(bg)
print('obj',len(obj),'bg',len(bg))

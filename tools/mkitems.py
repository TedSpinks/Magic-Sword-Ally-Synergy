# v112: the magic items page text, rebuilt as one draw list (entries: VRAM word address, tile, attribute) at $8B:E000
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
r=open(S+'rom/ms_fast.sfc','rb').read()
def ents(a,n):
    o=0x38000+(a-0x8000); return [[r[o+i]|r[o+i+1]<<8, r[o+i+2], r[o+i+3]] for i in range(0,n,4)]
L=ents(0xBA07,0x12C)+ents(0xBB2F,0x270)
NEW={10:"HEALS",11:"YOUR ALLY.",13:"FINDS TREASURE",14:"CHESTS.",19:"MAGIC BAR FILLS",20:"TWICE AS FAST.",
     22:"BRIBES THE",23:"LIZARDMAN.",25:"ENEMIES DROP",26:"MORE TREASURE."}
COL=15
def tile(ch):
    if ch.isalnum(): return ord(ch)+0x71
    return {"'":0x98,',':0x9D,'.':0x9F,'?':0xB0}[ch]
out=[]; attr={}
for ad,t,a in L:
    row,col=(ad-0x5C00)//32,(ad-0x5C00)%32
    if row in NEW and col>=COL:
        attr[row]=a; continue
    out.append((ad,t,a))
for row,txt in NEW.items():
    assert len(txt)<=17, txt
    a=attr.get(row, attr.get(row-1, attr.get(row+1)))
    for i,ch in enumerate(txt):
        if ch!=' ': out.append((0x5C00+row*32+COL+i, tile(ch), a))
b=b''.join(bytes([ad&0xFF,ad>>8,t,a]) for ad,t,a in out)
open(S+'asm/items.bin','wb').write(b)
print(len(out),'entries',len(b),'bytes',{k:hex(v) for k,v in attr.items()})

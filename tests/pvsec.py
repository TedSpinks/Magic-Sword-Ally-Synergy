import re
def sections(s):
    names=[(m_.start(),m_.group()) for m_ in re.finditer(rb'[A-Z]{3}:[0-9]{6}:',s)]
    out={}
    for k,(p,nm) in enumerate(names):
        end=names[k+1][0] if k+1<len(names) else len(s)
        out[nm[:3].decode()]=(p,s[p:end])
    return out
FILHDR=11
IGN_FIL={0x2116,0x2117,0x2121,0x2102,0x2103,0x2139,0x213a,0x213b}|set(range(0x4202,0x4218))|set(range(0x4370,0x4380))|{0x420b,0x213f,0x2137}
def secdiff(s0,s1):
    a=sections(s0); b=sections(s1); rep=[]
    for k in a:
        if k in ('RAM','SND','CPU','REG','TIM','VRA','SRA','FIL2'): continue
        x=a[k][1]; y=b[k][1]
        for i in range(min(len(x),len(y))):
            if x[i]!=y[i]:
                if k=='FIL':
                    r=i-FILHDR
                    if r in IGN_FIL: continue
                    rep.append('FIL $%04X %02X->%02X'%(r,x[i],y[i]))
                elif k=='PPU' and i in (13,14,73,74,2659,2660,2661,2662):   # VRAM/CGRAM address, open bus
                    continue
                elif k=='DMA' and i>=140: continue   # channel 7 (ours)
                else: rep.append('%s +%d %d->%d'%(k,i,x[i],y[i]))
    return rep

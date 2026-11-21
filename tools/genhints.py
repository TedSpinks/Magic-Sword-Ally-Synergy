import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from hintdata import *
n=new_msgs()
# table entries at $00:CA78, 3 bytes each, 52 entries
TAB=0x00CA78; cnt=52
ent=[]
for k in range(cnt):
    o=off(TAB)+3*k; a=r[o]|r[o+1]<<8|r[o+2]<<16; ent.append(a)
amap={a:i for i,a in enumerate(origaddr)}
for k,a in enumerate(ent):
    assert a in amap,(k,hex(a))
out=['lorom','; Between-level hint messages (v58): hyphen/translation fixes, repacked in place at $07:C421.','; Each line is at most 12 characters (the dialog width), at most 7 lines.','org $07C421']
for i,m in enumerate(n):
    parts=m.split(b'\x00')
    s=' : db $00 : '.join('db "%s"'%p.decode('latin1').replace('"','') for p in parts)
    out.append('Hint%d: %s : db $FF'%(i,s))
used=sum(len(m)+1 for m in n); pad=(END-START)-used
out.append('    ; leftover bytes of the old block'); out.append('    '+'db '+','.join(['$FF']*pad) if pad else '')
out.append('')
out.append('org $00CA78            ; floor -> message table, one 3-byte pointer per floor')
for k,a in enumerate(ent):
    out.append('    dl Hint%d'%amap[a])
open(S+'asm/hints.asm','w').write('\n'.join(out)+'\n')
print(len(ent),'entries; pad',pad)

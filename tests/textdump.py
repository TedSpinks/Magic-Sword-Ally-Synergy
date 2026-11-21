import json
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
O=open(S+'rom/ms_fast.sfc','rb').read(); N=open(S+'rom/ms_v115.sfc','rb').read()
def off(a): return ((a>>16)&0x7F)*0x8000+(a&0x7FFF)
def rd(r,a,stop=0xFF):
    o=off(a); lines=[]; cur=b''
    while r[o]!=stop:
        if r[o]==0: lines.append(cur.decode('latin1')); cur=b''
        else: cur+=bytes([r[o]])
        o+=1
    lines.append(cur.decode('latin1')); return lines
def join(lines):
    s=''
    for l in lines:
        l=l.strip()
        if not l: continue
        if s.endswith('-'): s+=l
        else: s+=(' ' if s else '')+l
    return ' '.join(s.split())
def ptr(r,a): o=off(a); return r[o]|r[o+1]<<8|r[o+2]<<16
out={'allies':[],'floors':[]}
names={0xD816:'Big Man',0xD81C:'Knight',0xD822:'Ninja',0xD828:'Cleric',0xD82E:'Amazon',0xD834:'Wizard',0xD83A:'Lizardman',0xD840:'Thief'}
for a,n in names.items():
    o=join(rd(O,ptr(O,a))); nw=join(rd(N,ptr(N,a)))
    out['allies'].append((n,o,nw))
for f in range(52):
    o=join(rd(O,ptr(O,0xCA78+3*f))); nw=join(rd(N,ptr(N,0xCA78+3*f)))
    out['floors'].append((f,o,nw))
json.dump(out,open(S+'texts.json','w'),indent=0)
for n,o,nw in out['allies']: print(n,'|',o,'|',nw,'|','SAME' if o==nw else '')
for f,o,nw in out['floors']:
    if o!=nw: print(f,'|',o,'|',nw)

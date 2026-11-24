#!/usr/bin/env python3
"""Find assembled blocks that overlap each other (asar does not warn when one `org` block runs into another).

Usage: python3 tools/overlap_check.py ASAR BASE_ROM [src_dir]
  ASAR      path to the asar executable
  BASE_ROM  the ROM the build patches (clean ROM with the FastROM patch applied)
Copies src/ to a temp folder, makes every `org` print where the block before it ended, assembles the files in build order
and reports every pair of blocks whose address ranges overlap. Exit status 1 if there is one.
Found the v109 bug (the CODEX ally-order code overwrote the last byte of the demo's START exit).
"""
import sys,re,os,glob,shutil,subprocess,tempfile
ORDER='hack_opt recruit bigregen priest wizard mfix2 ninja text options save slot hints bosswarn thieflog items'.split()
asar,base=sys.argv[1],sys.argv[2]; src=sys.argv[3] if len(sys.argv)>3 else os.path.join(os.path.dirname(__file__),'..','src')
tmp=tempfile.mkdtemp(); shutil.copytree(src,tmp+'/s'); rom=tmp+'/rom.sfc'; shutil.copy(base,rom)
for f in glob.glob(tmp+'/s/*.asm'):
    out=[]
    for ln in open(f).read().split('\n'):
        if re.match(r'^\s*org\s+[^;\s]+',ln): out+=['print "END ",hex(pc())',ln,'print "BEGIN %s ",hex(pc())'%os.path.basename(f)]
        else: out.append(ln)
    out.append('print "END ",hex(pc())'); open(f,'w').write('\n'.join(out))
blocks=[]
for n in ORDER:
    r=subprocess.run([asar,'--no-title-check',n+'.asm',rom],cwd=tmp+'/s',capture_output=True,text=True)
    cur=None
    for ln in (r.stdout+r.stderr).split('\n'):
        p=ln.split()
        if len(p)>=2 and p[0]=='BEGIN': cur=(p[1],int(p[2],16))
        elif len(p)>=2 and p[0]=='END' and cur and p[1]!='FFFFFFFFFFFFFFFF':
            e=int(p[1],16)
            if e>cur[1]: blocks.append((cur[1],e,cur[0]))
            cur=None
blocks.sort(); bad=0
for i,a in enumerate(blocks):
    for b in blocks[i+1:]:
        if b[0]>=a[1]: break
        print('OVERLAP $%06X-$%06X (%s) and $%06X-$%06X (%s)'%(a[0],a[1]-1,a[2],b[0],b[1]-1,b[2])); bad+=1
print('%d blocks, %d overlaps'%(len(blocks),bad)); shutil.rmtree(tmp); sys.exit(1 if bad else 0)

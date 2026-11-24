import sys,os; sys.path.insert(0,'.')
from xlib import *
rom=sys.argv[1]; seeds=range(int(sys.argv[2]),int(sys.argv[3]))
os.environ['SETV']='bsnes_entropy=High'; os.environ['MS_WRAM_JUNK']='0-20000'
out=[]
for sd in seeds:
    os.environ['MS_SEED']=str(sd)
    c=Core(CORES['bsnes'],S+'rom/'+rom); c.run(1)
    C.memmove(c.l.retro_get_memory_data(0),bytes(make_sram(7)),0x800)
    c.run(500); resume(c); out.append((sd,'ok' if c.b(0x403)==7 else 'STALL'))
print(rom,'stalls',sum(1 for s,r in out if r!='ok'),'of',len(out),[s for s,r in out if r!='ok'],flush=True)

import sys,os; sys.path.insert(0,'.')
from xlib import *
lo,hi=sys.argv[1],sys.argv[2]
os.environ['SETV']='bsnes_entropy=High'; os.environ['MS_WRAM_JUNK']=lo if hi=='x' else '%s-%s'%(lo,hi)
c=Core(CORES['bsnes'],S+'rom/ms123.sfc'); c.run(1)
C.memmove(c.l.retro_get_memory_data(0),bytes(make_sram(7)),0x800)
c.run(500); resume(c)
print(lo,hi,'STALL' if c.b(0x403)!=7 else 'ok',flush=True)

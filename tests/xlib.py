# portable test helpers: reach any floor on any libretro core (Snes9x, bsnes, Mesen-S) from power-on, using a crafted SRAM slot + RESUME
import sys,os,ctypes as C; sys.path.insert(0,'/tmp/claude-0/-home-claude/181827fb-c294-5f1d-b175-1f7ed57890c2/scratchpad/scripts')
from common import *
FIX=S+'xfix/'
SO9=S+'s9x_tw3.so'
CORES={'s9x':SO9,'bsnes':'/home/claude/xcores/bsnes_libretro.so','mesen':'/home/claude/xcores/mesen-s_libretro.so'}
OPT=list(range(0x61,0x66))
def base_run():
    p=FIX+'base_run.bin'
    if not os.path.exists(p):
        c=Core(SO9,S+'rom/ms123.sfc'); c.run(10); c.load(open(S+'states/f7_trig.raw','rb').read()); c.run(1)
        d=bytearray(c.ram(0x403,0x8F))
        for y in OPT: d[y]=0
        open(p,'wb').write(d)
    return bytearray(open(p,'rb').read())
def make_sram(floor,ally=None,log=True,life=None):
    sr=bytearray([0]*0x800)
    d=base_run(); d[0]=floor
    if ally is not None: d[0x424-0x403]=ally
    b=0x100; sr[b]=0xA6; sr[b+1:b+7]=b'TESTER'[:6]
    sr[b+0x10:b+0x10+0x8F]=d
    sr[b+0xE:b+0x10]=(sum(d)&0xFFFF).to_bytes(2,'little')
    if log:
        bits=bytes([0xFF]*7); sr[0x500:0x50A]=bytes([0x7A])+bits+bytes([(sum(bits)&0xFF)^0xA5,0xFF])
    return sr
def enter(core,rom,floor,ally=None,sram=None):
    c=Core(core,rom); c.run(5)
    sr=sram or make_sram(floor,ally)
    n=c.l.retro_get_memory_size(0); assert n>=0x800,n
    C.memmove(c.l.retro_get_memory_data(0),bytes(sr),0x800)
    c.run(500); c.tap(m(START)); c.run(270); c.tap(m(START)); c.run(150)
    c.tap(m(Y)); c.run(20); c.tap(m(Y)); c.run(600)
    return c
def cpu(c):
    c.l.ms_cpu.argtypes=[C.POINTER(C.c_uint)]; o=(C.c_uint*8)(); c.l.ms_cpu(o); return dict(zip('pc a x y s d b p'.split(),list(o)))
def resume(c):
    c.tap(m(START)); c.run(270); c.tap(m(START)); c.run(150); c.tap(m(Y)); c.run(20); c.tap(m(Y)); c.run(600)
def ring(c,n=60):
    c.l.ms_ring.restype=C.POINTER(C.c_uint); c.l.ms_ringpos.restype=C.c_uint
    p=c.l.ms_ring(); pos=c.l.ms_ringpos()
    return [p[(pos-n+i)&0xFFFF] for i in range(n)]
def resume2(c,floor,maxf=6000):
    """adaptive: START until the slot screen (scene 4), then Y, Y; True when the floor is running"""
    f=0; tries=0
    while f<maxf:
        sc=(c.b(0x401),c.b(0x402))
        if sc==(0,2) and c.b(0x403)==floor and c.w(0x460)>20: return True
        if sc[0]==4 and tries<3:
            c.run(60); f+=60
            c.tap(m(Y),3,25); c.tap(m(Y),3,25); f+=56; tries+=1
            c.run(400); f+=400
        elif sc[0] in (2,10,16,4):
            c.tap(m(START),3,60); f+=63
        else:
            c.run(30); f+=30
    return False

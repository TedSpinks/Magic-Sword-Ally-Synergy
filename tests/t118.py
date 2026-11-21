import sys,ctypes; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
P=0x8500
rom=sys.argv[1]
def floors(d): return [f for f in range(56) if d[1+(f>>3)]>>(f&7)&1]
for fl in (7,49,50,51,52,53,54,55):
    c=Core(S+'s9x_tw3.so',S+'rom/'+rom); c.run(10)
    c.load(open(S+'states/f7_trig.raw','rb').read()); c.run(1)
    sp=c.l.retro_get_memory_data(0)
    rec=bytes([0x7A]+[0]*7); ctypes.memmove(sp+0x500,rec+bytes([0xA5,0xFF]),10)
    if fl!=7: c.poke(P+0xAE,(fl-1)&0xFF)
    for i in range(1500):
        pad=m(RIGHT) if c.w(P+4)>100 else (m(UP) if (i//4)%2 else 0)
        c.poke(0x431,160); c.run(1,pad=pad)
    F=LEFT if fl>=52 else RIGHT
    for i in range(1200):
        c.poke(0x431,160); c.poke(0x424,0x15); c.poke(0x42E,0)
        c.run(1,pad=[m(F),m(F,Y),m(F,B)][(i//24)%3])
    d=c.sram(0x500,10)
    ok=d[0]==0x7A and ((sum(d[1:8])&0xFF)^0xA5)==d[8]
    print(fl,'on',c.b(0x403),'log',floors(d),'valid',ok)

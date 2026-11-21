import sys,ctypes; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
c=Core(S+'s9x_tw3.so',S+'rom/ms_v115.sfc'); c.run(5)
sp=c.l.retro_get_memory_data(0)
def setsram():
    rec=bytes([0x7A]+[0xFF]*7); s=sum(rec[1:8])&0xFF
    ctypes.memmove(sp+0x500,rec+bytes([s^0xA5,0xFF]),10)
c.run(600)
setsram()
# get a "played" table: write a marker byte into entry 1's name, keep checksum? use RESET first to get defaults then compare
def logfl(): d=c.sram(0x500,10); return sum(bin(x).count('1') for x in d[1:8]) if d[0]==0x7A else -1, d.hex()
def tab(): return c.sram(0x400,0xB0)
def tap(b,n=10): c.tap(m(*b) if isinstance(b,tuple) else m(b),3,n)
c.tap(m(START)); c.run(120); c.tap(m(DOWN)); c.run(20); c.tap(m(START)); c.run(120)
for k in range(7): tap(DOWN,8)
print('cursor',c.b(0x13A1)); shots=[snap(c)]
def combo():
    for i in range(6): c.run(1,pad=m(A,B,X,Y))
    for i in range(4): c.run(1,pad=m(A,B,X,Y,START))
    for i in range(4): c.run(1,pad=m(A,B,X,Y))
    c.run(10)
t0=tab(); l0=logfl()
combo(); print('CHOOSE + combo: log',logfl()[0],'table same',tab()==t0,'mode',c.mem(2,0x1E7A2,1).hex()); shots.append(snap(c))
seq=[]
for b in (RIGHT,RIGHT,RIGHT,RIGHT,LEFT):
    tap(b,8); seq.append(c.mem(2,0x1E7A9,1)[0]); shots.append(snap(c))
print('RIGHTx4, LEFT ->',seq)
tap(RIGHT,8); tap(RIGHT,8); print('sel',c.mem(2,0x1E7A9,1)[0])  # EVERYTHING(3)->CHOOSE(0)->HALL(1)?
# go to THIEF'S LOG
while c.mem(2,0x1E7A9,1)[0]!=2: tap(RIGHT,8)
combo(); print("THIEF'S LOG reset: log",logfl(),'table same',tab()==t0,'mode',c.mem(2,0x1E7A2,1).hex()); shots.append(snap(c))
tap(RIGHT,8); print('after DONE, RIGHT -> sel',c.mem(2,0x1E7A9,1)[0],'mode',c.mem(2,0x1E7A2,1).hex()); shots.append(snap(c))
setsram()
combo(); print('HALL reset: log',logfl()[0],'table changed',tab()!=t0)
t1=tab()
setsram(); tap(LEFT,8); tap(LEFT,8); tap(LEFT,8); print('sel',c.mem(2,0x1E7A9,1)[0])   # DONE->CHOOSE via LEFT -> EVERY? 
while c.mem(2,0x1E7A9,1)[0]!=3: tap(RIGHT,8)
combo(); print('EVERYTHING: log',logfl()[0],'table',tab()==t1,'mode',c.mem(2,0x1E7A2,1).hex()); shots.append(snap(c))
# leave and come back
tap(DOWN,8); print('cursor',c.b(0x13A1)); tap(START,200); c.tap(m(DOWN)); c.run(20); c.tap(m(START)); c.run(120)
for k in range(7): tap(DOWN,8)
print('re-enter sel',c.mem(2,0x1E7A9,1)[0]); shots.append(snap(c))
sheet(shots,S+'shots/rs115.png',4)

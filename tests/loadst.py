import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
import struct
def mem(name):
    d=open(S+'states/%s.bin'%name,'rb').read()
    assert d[:7]==b'RASTATE' and d[8:12]==b'MEM '
    n=struct.unpack_from('<I',d,12)[0]; return d[16:16+n]
def loadst(c,name):
    c.load(mem(name)); c.run(2)
if __name__=='__main__':
    c=boot(); c.run(10)
    print('my serialize size',c.l.retro_serialize_size())
    fr=[]
    for n in ('door1','door2','ninja','priest','wizard'):
        d=mem(n)
        try:
            loadst(c,n)
            print(n,'loaded; floor',c.b(0x403),'ally',hex(c.b(0x424)),'lvl0',c.b(0x412),'life',c.b(0x423),'keys?')
            fr.append(snap(c)); open(S+'states/%s.s9x'%n,'wb').write(d)
        except AssertionError as e:
            print(n,'LOAD FAILED len',len(d))
    sheet(fr,S+'shots/states.png',3)

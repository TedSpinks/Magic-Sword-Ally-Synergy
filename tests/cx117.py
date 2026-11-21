import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from common import *
c=Core(S+'s9x_tw2.so',S+'rom/ms117.sfc'); c.run(5)
c.run(900); c.tap(m(DOWN)); c.run(10); c.tap(m(DOWN)); c.run(10); c.tap(m(START)); c.run(300)
fr=[]
for k in range(3): c.tap(m(L),3,250)
c.tap(m(A),3,60); fr.append(snap(c))
c.tap(m(R),3,250); c.tap(m(A),3,60); fr.append(snap(c))  # Knight: unchanged check
sheet(fr,S+'shots/cx117.png',2)

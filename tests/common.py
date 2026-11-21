import sys; sys.path.insert(0,__import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from lr import *
from PIL import Image
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
ROM=S+'rom/Magic Sword (USA).sfc'
def boot():
    return Core(S+'s9x_tw.so',ROM)
def start_game(c):
    c.run(500); c.tap(m(START)); c.run(270); c.tap(m(START)); c.run(200); c.tap(m(UP)); c.run(30); c.tap(m(START)); c.run(250)
def to_select(c):
    c.run(500); c.tap(m(START)); c.run(270); c.tap(m(START)); c.run(120)
def sheet(frames,path,cols=4,scale=1):
    w,h=frames[0].size
    rows=(len(frames)+cols-1)//cols
    mm=Image.new('RGB',(w*cols,h*rows))
    for i,im in enumerate(frames): mm.paste(im,((i%cols)*w,(i//cols)*h))
    if scale!=1: mm=mm.resize((mm.width*scale,mm.height*scale))
    mm.save(path)
def snap(c):
    c.shot(S+'shots/_t.png'); return Image.open(S+'shots/_t.png').copy()

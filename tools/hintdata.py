import sys
S=__import__('os').environ.get('MS_WORK','work')+'/'   # work folder: rom/, states/, shots/, the libretro core (see tests/README.md)
r=open(S+'rom/Magic Sword (USA).sfc','rb').read()
def off(a): return ((a>>16)&0x7F)*0x8000+(a&0x7FFF)
START=0x07C421
# NEW keys use the chat numbering, which is the file numbering + 1
# original messages 1..51 from START: split on $FF
msgs=[];a=START
while len(msgs)<51:
    o=off(a); e=r.index(b'\xff',o)
    msgs.append((a,r[o:e])); a+=e-o+1
END=a   # first byte after the last message
orig=[m for _,m in msgs]
origaddr=[x for x,_ in msgs]
def lines(b): return b.decode('latin1').split('\x00')
NEW={ 6:"THE CLERIC/CAN DEFEAT/UNDEAD/CREATURES.",
 7:"IF YOU HAVE/A DIAMOND/RING, THE/LIZARDMAN/MAY JOIN/YOU.",
 12:"WE FINALLY/DESTROYED/THE CHIMERA./LET'S MOVE/ON.",
 13:"THE THIEF/SPOTS TRAPS/AND MAPS/EVERY FLOOR/HE REACHES.",
 16:"THE GOLDEN/BOOK TURNS/FAKE GOLD/COINS INTO/REAL ONES.",
 18:"THIS BLAZE/FEELS LIKE/IT'S/STRAIGHT/FROM THE/DEMON PITS.",
 19:"THE WIZARD/REPLENISHES/YOUR MAGIC/BAR.",
 31:"NO ONE HAS/BEEN ABLE/TO DEFEAT/THE/TWO-HEADED/DRAGON.",
 42:"THE BLACKORB/IS THE ROOT/OF DROKMAR'S/POWER.",
 44:"HE WHO/HOLDS THE/BLACKORB/CAN BECOME/KING OF/EVIL.",
 45:"THOSE WHO/ATTAIN THE/BLACKORB/WILL OBTAIN/DROKMAR'S/POWER.",
 47:"WE MUST/RESTORE/LIGHT TO THE/SUFFERING/PEOPLE OF/THE WORLD.",
 50:"OPEN/DROKMAR'S/DOOR WITH/THE KEY."}
def new_msgs():
    out=[]
    for i,m in enumerate(orig,1):
        out.append(NEW[i+1].replace('/','\x00').encode('latin1') if (i+1) in NEW else m)
    return out
if __name__=='__main__':
    print('orig span %06X-%06X = %d bytes'%(START,END,END-START))
    n=new_msgs(); print('new total',sum(len(x)+1 for x in n))
    for i,m in enumerate(n,1):
        L=lines(m); bad=[l for l in L if len(l)>12]
        if bad or len(L)>7: print('TOO BIG',i,L)
    print(r[off(END):off(END)+8].hex())

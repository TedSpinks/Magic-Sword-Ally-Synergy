# tiny 65816 subset interpreter for RecruitBonus (8-bit A/X, the opcodes it uses)
def run(rom,pc,A,Y,mem):
    def off(a): return ((a>>16)&0x7F)*0x8000+(a&0x7FFF)
    X=0;Z=N=C=0
    def flags(v):
        nonlocal Z,N; Z=int(v&0xFF==0); N=int(v&0x80!=0)
    for _ in range(200):
        op=rom[off(pc)]; b1=rom[off(pc)+1]; w=b1|rom[off(pc)+2]<<8
        if op==0xE2: pc+=2
        elif op==0xBB: X=Y; flags(X); pc+=1
        elif op==0x8D: mem[w]=A; pc+=3
        elif op==0xAD: A=mem.get(w,0); flags(A); pc+=3
        elif op==0xC9: C=int(A>=b1); flags((A-b1)&0xFF); pc+=2
        elif op==0xCD: v=mem.get(w,0); C=int(A>=v); flags((A-v)&0xFF); pc+=3
        elif op==0xE0: C=int(X>=b1); flags((X-b1)&0xFF); pc+=2
        elif op==0x1A: A=(A+1)&0xFF; flags(A); pc+=1
        elif op==0xA9: A=b1; flags(A); pc+=2
        elif op in (0xD0,0xF0,0x90,0xB0,0x80):
            t={0xD0:not Z,0xF0:Z,0x90:not C,0xB0:C,0x80:True}[op]
            pc+=2+((b1^0x80)-0x80 if t else 0)
        elif op==0x5C:
            return A,X,(w|rom[off(pc)+3]<<16)
        else: raise Exception('op %02X at %06X'%(op,pc))
    raise Exception('loop')

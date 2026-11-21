# minimal 65816 disassembler: python3 dis.py rom.sfc BB:AAAA count [m x]
import sys
M="""BRK s|ORA dxi|COP s|ORA sr|TSB d|ORA d|ASL d|ORA dil|PHP|ORA #m|ASL|PHD|TSB a|ORA a|ASL a|ORA al|
BPL r|ORA diy|ORA di|ORA sry|TRB d|ORA dx|ASL dx|ORA dily|CLC|ORA ay|INC|TCS|TRB a|ORA ax|ASL ax|ORA alx|
JSR a|AND dxi|JSL al|AND sr|BIT d|AND d|ROL d|AND dil|PLP|AND #m|ROL|PLD|BIT a|AND a|ROL a|AND al|
BMI r|AND diy|AND di|AND sry|BIT dx|AND dx|ROL dx|AND dily|SEC|AND ay|DEC|TSC|BIT ax|AND ax|ROL ax|AND alx|
RTI|EOR dxi|WDM s|EOR sr|MVP mv|EOR d|LSR d|EOR dil|PHA|EOR #m|LSR|PHK|JMP a|EOR a|LSR a|EOR al|
BVC r|EOR diy|EOR di|EOR sry|MVN mv|EOR dx|LSR dx|EOR dily|CLI|EOR ay|PHY|TCD|JML al|EOR ax|LSR ax|EOR alx|
RTS|ADC dxi|PER rl|ADC sr|STZ d|ADC d|ROR d|ADC dil|PLA|ADC #m|ROR|RTL|JMP ai|ADC a|ROR a|ADC al|
BVS r|ADC diy|ADC di|ADC sry|STZ dx|ADC dx|ROR dx|ADC dily|SEI|ADC ay|PLY|TDC|JMP axi|ADC ax|ROR ax|ADC alx|
BRA r|STA dxi|BRL rl|STA sr|STY d|STA d|STX d|STA dil|DEY|BIT #m|TXA|PHB|STY a|STA a|STX a|STA al|
BCC r|STA diy|STA di|STA sry|STY dx|STA dx|STX dy|STA dily|TYA|STA ay|TXS|TXY|STZ a|STA ax|STZ ax|STA alx|
LDY #x|LDA dxi|LDX #x|LDA sr|LDY d|LDA d|LDX d|LDA dil|TAY|LDA #m|TAX|PLB|LDY a|LDA a|LDX a|LDA al|
BCS r|LDA diy|LDA di|LDA sry|LDY dx|LDA dx|LDX dy|LDA dily|CLV|LDA ay|TSX|TYX|LDY ax|LDA ax|LDX ay|LDA alx|
CPY #x|CMP dxi|REP #b|CMP sr|CPY d|CMP d|DEC d|CMP dil|INY|CMP #m|DEX|WAI|CPY a|CMP a|DEC a|CMP al|
BNE r|CMP diy|CMP di|CMP sry|PEI d|CMP dx|DEC dx|CMP dily|CLD|CMP ay|PHX|STP|JML ail|CMP ax|DEC ax|CMP alx|
CPX #x|SBC dxi|SEP #b|SBC sr|CPX d|SBC d|INC d|SBC dil|INX|SBC #m|NOP|XBA|CPX a|SBC a|INC a|SBC al|
BEQ r|SBC diy|SBC di|SBC sry|PEA a|SBC dx|INC dx|SBC dily|SED|SBC ay|PLX|XCE|JSR axi|SBC ax|INC ax|SBC alx"""
ops=[x.strip() for x in M.replace('\n','').split('|')]
assert len(ops)==256,len(ops)
F={'d':'$%02X','dx':'$%02X,x','dy':'$%02X,y','dxi':'($%02X,x)','diy':'($%02X),y','di':'($%02X)','dil':'[$%02X]','dily':'[$%02X],y','sr':'$%02X,s','sry':'($%02X,s),y','a':'$%04X','ax':'$%04X,x','ay':'$%04X,y','ai':'($%04X)','axi':'($%04X,x)','ail':'[$%04X]','al':'$%06X','alx':'$%06X,x','s':'#$%02X','#b':'#$%02X'}
L={'d':1,'dx':1,'dy':1,'dxi':1,'diy':1,'di':1,'dil':1,'dily':1,'sr':1,'sry':1,'a':2,'ax':2,'ay':2,'ai':2,'axi':2,'ail':2,'al':3,'alx':3,'s':1,'#b':1,'r':1,'rl':2,'mv':2}
def dis(rom,pc,n,m=1,x=1):
    off=lambda a:((a>>16)&0x7F)*0x8000+(a&0x7FFF)
    out=[]
    for _ in range(n):
        o=off(pc); op=rom[o]; t=ops[op].split(' '); mn=t[0]; md=t[1] if len(t)>1 else ''
        if md=='#m': ln=1 if m else 2
        elif md=='#x': ln=1 if x else 2
        else: ln=L.get(md,0)
        b=rom[o+1:o+1+ln]; v=int.from_bytes(b,'little') if ln else 0
        if md in('#m','#x'): s='#$%0*X'%(ln*2,v)
        elif md=='r': s='$%04X'%((pc+2+((v^0x80)-0x80))&0xFFFF)
        elif md=='rl': s='$%04X'%((pc+3+((v^0x8000)-0x8000))&0xFFFF)
        elif md=='mv': s='$%02X,$%02X'%(b[1],b[0])
        elif md: s=F[md]%v
        else: s=''
        if mn=='REP': m=0 if v&0x20 else m; x=0 if v&0x10 else x
        if mn=='SEP': m=1 if v&0x20 else m; x=1 if v&0x10 else x
        out.append('%02X:%04X  %-12s %s %s'%(pc>>16,pc&0xFFFF,rom[o:o+1+ln].hex(),mn,s))
        pc+=1+ln
    return out
if __name__=='__main__':
    rom=open(sys.argv[1],'rb').read(); a=int(sys.argv[2].replace(':',''),16)
    m=int(sys.argv[4]) if len(sys.argv)>4 else 1; x=int(sys.argv[5]) if len(sys.argv)>5 else 1
    print('\n'.join(dis(rom,a,int(sys.argv[3]),m,x)))

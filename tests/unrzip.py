import struct,zlib,sys
def unrzip(d):
    assert d[:5]==b'#RZIP'
    chunk=struct.unpack_from('<I',d,8)[0]; tot=struct.unpack_from('<Q',d,12)[0]
    p=20; out=b''
    while p<len(d) and len(out)<tot:
        n=struct.unpack_from('<I',d,p)[0]; p+=4
        out+=zlib.decompress(d[p:p+n]); p+=n
    return out
if __name__=='__main__':
    A='/mnt/user-data/attachments/181827fb-c294-5f1d-b175-1f7ed57890c2/'
    S='work/states/'
    for src,dst in (('0cec7b02-Before_a_trapped_door.state','trapdoor'),('dd676df9-Trapped_chest_on_the_far_right.state','trapchest')):
        o=unrzip(open(A+src,'rb').read()); open(S+dst+'.bin','wb').write(o); print(dst,len(o),o[:12])

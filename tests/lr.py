"""Headless libretro driver (from the ZAMN project) + write/read/exec watch API for the patched snes9x core.
Core(so, rom).run(frames, pad=0); .ram(addr,n) WRAM; .shot(path); .save()/.load(bytes)
Watch (patched core only): c.watch(mode, lo, hi) mode bit1=writes bit2=reads bit4=exec trace; c.log() -> [(frame,kind,wram_addr,val,pc)]; c.pcs() -> list of op addresses
"""
import ctypes as C, sys, os
from ctypes import *
class Info(Structure): _fields_=[("path",c_char_p),("data",c_void_p),("size",c_size_t),("meta",c_char_p)]
class Tim(Structure): _fields_=[("fps",c_double),("sr",c_double)]
ENV=C.CFUNCTYPE(c_bool,c_uint,c_void_p); VID=C.CFUNCTYPE(None,c_void_p,c_uint,c_uint,c_size_t)
AUD=C.CFUNCTYPE(None,c_int16,c_int16); AUDB=C.CFUNCTYPE(c_size_t,c_void_p,c_size_t)
POLL=C.CFUNCTYPE(None); INP=C.CFUNCTYPE(c_int16,c_uint,c_uint,c_uint,c_uint)
B,Y,SEL,START,UP,DOWN,LEFT,RIGHT,A,X,L,R=range(12)
def m(*ids):
    v=0
    for i in ids: v|=1<<i
    return v
class Core:
    def __init__(s,so,rom):
        s.l=CDLL(so); s.pad=[0,0]; s.fb=None; s.fmt=2; s.vars={}
        s._env=ENV(s.env); s._vid=VID(s.vid); s._aud=AUD(lambda a,b:None); s._audb=AUDB(lambda d,n:n)
        s._poll=POLL(lambda:None); s._inp=INP(s.inp)
        s.l.retro_set_environment(s._env)
        s.l.retro_set_video_refresh(s._vid); s.l.retro_set_audio_sample(s._aud); s.l.retro_set_audio_sample_batch(s._audb)
        s.l.retro_set_input_poll(s._poll); s.l.retro_set_input_state(s._inp)
        s.l.retro_init()
        s.data=open(rom,'rb').read(); s.buf=C.create_string_buffer(s.data,len(s.data))
        i=Info(rom.encode(),cast(s.buf,c_void_p),len(s.data),None); assert s.l.retro_load_game(byref(i))
        s.l.retro_get_memory_data.restype=c_void_p; s.l.retro_get_memory_size.restype=c_size_t
        s.l.tw_data.restype=c_void_p; s.l.tw_pdata.restype=c_void_p
        s.l.tw_count.restype=c_uint; s.l.tw_pcount.restype=c_uint
        s.l.tw_set.argtypes=[c_int,c_uint,c_uint]
    def env(s,cmd,p):
        if cmd==10: s.fmt=cast(p,POINTER(c_uint))[0]; return True
        if cmd==3: cast(p,POINTER(c_bool))[0]=True; return True
        if cmd in(9,31): cast(p,POINTER(c_char_p))[0]=b'/tmp'; return True
        return False
    def vid(s,d,w,h,pitch):
        if d: s.fb=(w,h,pitch,string_at(d,h*pitch))
    def inp(s,port,dev,idx,id_):
        if dev!=1 or port>1: return 0
        return 1 if (s.pad[port]>>id_)&1 else 0
    def run(s,n,pad=None):
        if pad is not None: s.pad[0]=pad
        for _ in range(n): s.l.retro_run()
    def mem(s,kind,addr,n):
        p=s.l.retro_get_memory_data(kind); return string_at(p+addr,n)
    def ram(s,a,n=1): return s.mem(2,a,n)
    def sram(s,a,n=1): return s.mem(0,a,n)
    def poke(s,a,data):
        p=s.l.retro_get_memory_data(2); C.memmove(p+a,bytes(data) if not isinstance(data,int) else bytes([data]),1 if isinstance(data,int) else len(data))
    def b(s,a): return s.ram(a,1)[0]
    def w(s,a): d=s.ram(a,2); return d[0]|d[1]<<8
    def shot(s,path,scale=1):
        from PIL import Image
        w,h,p,d=s.fb; im=Image.frombuffer('RGB',(w,h),b'',) if False else Image.new('RGB',(w,h)); px=im.load()
        for y in range(h):
            row=d[y*p:(y+1)*p]
            for x in range(w):
                if s.fmt==2: v=row[2*x]|row[2*x+1]<<8; px[x,y]=((v>>11&31)*255//31,(v>>5&63)*255//63,(v&31)*255//31)
                elif s.fmt==0: v=row[2*x]|row[2*x+1]<<8; px[x,y]=((v>>10&31)*255//31,(v>>5&31)*255//31,(v&31)*255//31)
                else: px[x,y]=(row[4*x+2],row[4*x+1],row[4*x])
        if scale!=1: im=im.resize((w*scale,h*scale),Image.NEAREST)
        im.save(path)
    def save(s):
        n=s.l.retro_serialize_size(); b=C.create_string_buffer(n); assert s.l.retro_serialize(b,n); return b.raw
    def load(s,data):
        b=C.create_string_buffer(data,len(data)); assert s.l.retro_unserialize(b,len(data))
    def tap(s,mask,hold=3,wait=20): s.run(hold,pad=mask); s.run(wait,pad=0)
    # --- watch API
    def watch(s,mode,lo=0,hi=0): s.l.tw_set(mode,lo,hi)
    def clear(s): s.l.tw_clear()
    def log(s):
        n=s.l.tw_count(); p=s.l.tw_data()
        if not n: return []
        d=string_at(p,n*20); import struct
        return [struct.unpack_from('<5I',d,i*20) for i in range(n)]
    def pcs(s):
        n=s.l.tw_pcount(); p=s.l.tw_pdata()
        if not n: return []
        import struct
        return list(struct.unpack('<%dI'%n,string_at(p,n*4)))

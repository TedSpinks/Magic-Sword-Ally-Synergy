#!/usr/bin/env python3
"""Builds Magic Sword: Ally Synergy from a clean ROM.

    python3 build.py "/path/to/Magic Sword (USA).sfc" [outdir]

Checks the clean ROM, applies kandowontu's FastROM patch (inputs/third_party/fastrom.ips), assembles the source files in
src/ with asar in the order below, then writes MagicSword_AllySynergy.ips (the difference from the clean ROM), checks
that the IPS reproduces the build byte for byte, and packs the release zip (IPS, README.md, SECRETS.txt, CHECKSUMS.txt).
Output goes to out/ by default (not committed).  Needs asar 1.9x (tools/asar or on PATH) and Python 3.
"""
import sys, os, shutil, subprocess, tempfile, zipfile, zlib, hashlib

HERE = os.path.dirname(os.path.abspath(__file__))
VERSION = '1.0.2'
NAME = 'MagicSword_AllySynergy'
CLEAN_CRC32 = 0x27325E4D                       # Magic Sword (USA), 1 MB, no header
CLEAN_SHA1 = '0d64ef4149b71d13d287122f58eca9c580fa7d0f'
FASTROM = os.path.join(HERE, 'inputs', 'third_party', 'fastrom.ips')
# Order matters: later files hook code or use free space that earlier ones leave alone (asserts in the sources guard
# the block ends).  slot.asm includes hiscore.asm and logpage.asm.
SOURCES = ['hack_opt', 'recruit', 'bigregen', 'priest', 'wizard', 'mfix2', 'ninja', 'text', 'options', 'save',
           'slot', 'hints', 'bosswarn', 'thieflog', 'items']

def find_asar():
    for p in (os.path.join(HERE, 'tools', 'asar'), os.path.join(HERE, 'tools', 'asar.exe'), shutil.which('asar')):
        if p and os.path.exists(p): return p
    raise SystemExit('asar not found: put it in tools/ or on PATH (https://github.com/RPGHacker/asar)')

def ips_apply(rom, patch):
    r = bytearray(rom); p = patch; assert p[:5] == b'PATCH'; i = 5
    while p[i:i + 3] != b'EOF':
        o = int.from_bytes(p[i:i + 3], 'big'); n = int.from_bytes(p[i + 3:i + 5], 'big'); i += 5
        if n == 0:                                   # RLE record
            n = int.from_bytes(p[i:i + 2], 'big'); data = bytes([p[i + 2]]) * n; i += 3
        else:
            data = p[i:i + n]; i += n
        if o + n > len(r): r += b'\0' * (o + n - len(r))
        r[o:o + n] = data
    return bytes(r)

def ips_make(base, new):
    """IPS of the bytes where new differs from base (same size).  Short equal runs inside a change are kept in the
    record to save headers; records never start at offset $454F46 ('EOF')."""
    assert len(base) == len(new)
    out = bytearray(b'PATCH'); i = 0; n = len(base)
    while i < n:
        if base[i] == new[i]: i += 1; continue
        s = i
        while True:
            while i < n and base[i] != new[i] and i - s < 0xFFF0: i += 1
            j = i; g = 0
            while j < n and base[j] == new[j] and g < 6: j += 1; g += 1
            if j < n and base[j] != new[j] and i - s < 0xF000: i = j
            else: break
        if s == 0x454F46: s -= 1
        d = new[s:i]; out += s.to_bytes(3, 'big') + len(d).to_bytes(2, 'big') + d
    return bytes(out + b'EOF')

def build(cleanpath, outdir):
    clean = open(cleanpath, 'rb').read()
    if zlib.crc32(clean) != CLEAN_CRC32 or hashlib.sha1(clean).hexdigest() != CLEAN_SHA1:
        raise SystemExit('not the clean Magic Sword (USA) ROM: 1 MB, no header, CRC32 %08X expected (got %08X, %d bytes)'
                         % (CLEAN_CRC32, zlib.crc32(clean), len(clean)))
    asar = find_asar()
    os.makedirs(outdir, exist_ok=True)
    tmp = tempfile.mkdtemp(prefix='ms_build_')
    work = os.path.join(tmp, 'work.sfc')
    open(work, 'wb').write(ips_apply(clean, open(FASTROM, 'rb').read()))
    for s in SOURCES:
        p = subprocess.run([asar, '--no-title-check', os.path.join(HERE, 'src', s + '.asm'), work],
                           capture_output=True, text=True)
        if p.returncode or 'error' in (p.stdout + p.stderr).lower():
            raise SystemExit('asar failed on %s.asm:\n%s%s' % (s, p.stdout, p.stderr))
    rom = open(work, 'rb').read()
    patch = ips_make(clean, rom)
    assert ips_apply(clean, patch) == rom, 'the IPS does not reproduce the build'
    ips = os.path.join(outdir, NAME + '.ips'); open(ips, 'wb').write(patch)
    crc = '%08X' % zlib.crc32(rom)
    sums = ('Apply %s.ips to Magic Sword (USA): 1 MB, no header, CRC32 %08X, SHA-1 %s.\n'
            'Patched ROM: CRC32 %s, SHA-1 %s.\n' % (NAME, CLEAN_CRC32, CLEAN_SHA1, crc, hashlib.sha1(rom).hexdigest()))
    zpath = os.path.join(outdir, '%s-v%s.zip' % (NAME, VERSION))
    with zipfile.ZipFile(zpath, 'w', zipfile.ZIP_DEFLATED) as z:
        z.write(ips, NAME + '.ips')
        z.write(os.path.join(HERE, 'README.md'), 'README.md')
        z.write(os.path.join(HERE, 'SECRETS.txt'), 'SECRETS.txt')
        z.writestr('CHECKSUMS.txt', sums)
    shutil.copy(work, os.path.join(tmp, NAME + '.sfc'))
    print('%s.ips  %d bytes   patched ROM CRC32 %s' % (NAME, len(patch), crc))
    print('release zip:', zpath)
    print('patched ROM for testing:', os.path.join(tmp, NAME + '.sfc'))

if __name__ == '__main__':
    if len(sys.argv) < 2: raise SystemExit(__doc__)
    build(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else os.path.join(HERE, 'out'))

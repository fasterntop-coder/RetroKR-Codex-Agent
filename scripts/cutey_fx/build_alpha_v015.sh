#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
src=Path('scripts/cutey_fx/build_alpha_v013.sh').read_text(encoding='utf-8')
# Correct the verified occurrence count for 変身しない.
old="    assert len(hits)==2,(jp,hits);prog.append((jp,kr,2,';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
new="    expected=4 if jp=='変身しない' else 2\n    assert len(hits)==expected,(jp,hits);prog.append((jp,kr,len(hits),';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
if old not in src: raise SystemExit('transform assertion pattern not found')
src=src.replace(old,new,1)
# Patch both verified full-width EXIT occurrences instead of only the boot copy.
needle="exact_at(0x1824D,'ＥＸＩＴ','종료')"
repl="""\ndef all_exact(jp,kr,expected):
    old=jp.encode('shift_jis');new=enc(kr);pad=len(old)-len(new)
    assert pad>=0 and pad%2==0,(jp,kr,len(old),len(new))
    new+=b'\\x81\\x40'*(pad//2);hits=[];p=0
    while True:
        q=L.find(old,p)
        if q<0:break
        hits.append(q);L[q:q+len(old)]=new;p=q+len(old)
    assert len(hits)==expected,(jp,hits)
    prog.append((jp,kr,len(hits),';'.join(f'LOGICAL 0x{x:X}' for x in hits)))
all_exact('ＥＸＩＴ','종료',2)"""
if needle not in src: raise SystemExit('EXIT exact-at pattern not found')
src=src.replace(needle,repl,1)
src=src.replace('KR ALPHA v0.13','KR ALPHA v0.15')
src=src.replace('v0.13','v0.15')
src=src.replace('KR13','KR15')
src=src.replace('CuteyHoneyFX_KR_ALPHA_v0.13.zip','CuteyHoneyFX_KR_ALPHA_v0.15.zip')
# Make the README accurately state that all verified EXIT copies are patched.
src=src.replace('System UI + all 6 transformation choices localized.','System UI (including both EXIT copies) + all 6 transformation choices localized.')
Path('/tmp/build_alpha_v015_inner.sh').write_text(src,encoding='utf-8')
PY
bash /tmp/build_alpha_v015_inner.sh

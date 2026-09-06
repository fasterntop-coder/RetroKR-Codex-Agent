#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
src=Path('scripts/cutey_fx/build_alpha_v013.sh').read_text(encoding='utf-8')

# 1) Expand Hangul proxy glyph set for every verified control-block translation.
old="chars=list(dict.fromkeys('이전으로타이틀돌아가기종료저장불러오큐티하니변신키사라커맨드판지나트레슬안함'))"
new="chars=list(dict.fromkeys('이전으로타이틀돌아가기종료저장불러오큐티하니변신키사라커맨드판지나트레슬안함섬을떠나라저는무사해요경고무시됐유리코…'))"
if old not in src: raise SystemExit('proxy char-set pattern not found')
src=src.replace(old,new,1)

# 2) Correct verified occurrence count for 変身しない.
old="    assert len(hits)==2,(jp,hits);prog.append((jp,kr,2,';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
new="    expected=4 if jp=='変身しない' else 2\n    assert len(hits)==expected,(jp,hits);prog.append((jp,kr,len(hits),';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
if old not in src: raise SystemExit('transform assertion pattern not found')
src=src.replace(old,new,1)

# 3) Replace the single boot EXIT call with a verified global exact replacer.
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

# 4) Localize every remaining verified control-block story string.
anchor="for jp,kr in [('キューティーハニーに変身！','큐티하니로 변신！')"
story="""# Verified control-block story strings (v0.15 inventory: 10/10/10/4 occurrences).
all_exact('この島から去れ。','이 섬을 떠나라',10)
all_exact('私は無事です。','저는 무사해요',10)
all_exact('警告は無視された。','경고는 무시됐다',10)
all_exact('ゆり子・・・','유리코……',4)

"""
if anchor not in src: raise SystemExit('transform-loop anchor not found')
src=src.replace(anchor,story+anchor,1)

# 5) Version/package/status labels.
src=src.replace('KR ALPHA v0.13','KR ALPHA v0.16')
src=src.replace('v0.13','v0.16')
src=src.replace('KR13','KR16')
src=src.replace('CuteyHoneyFX_KR_ALPHA_v0.13.zip','CuteyHoneyFX_KR_ALPHA_v0.16.zip')
src=src.replace('System UI + all 6 transformation choices localized.','System UI + transformation choices + all 51 verified control-block occurrences localized.')
src=src.replace('POC01/POC02 = HW PASS LOCK. v0.16 = STATIC BUILD PASS / PRE-HW until user test.','POC01/POC02 = HW PASS LOCK. v0.16 = STATIC BUILD PASS / PRE-HW until user test.')
Path('/tmp/build_alpha_v016_inner.sh').write_text(src,encoding='utf-8')
PY
bash /tmp/build_alpha_v016_inner.sh

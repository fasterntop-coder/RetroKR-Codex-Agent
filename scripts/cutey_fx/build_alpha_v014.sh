#!/usr/bin/env bash
set -euo pipefail
python3 - <<'PY'
from pathlib import Path
src=Path('scripts/cutey_fx/build_alpha_v013.sh').read_text(encoding='utf-8')
old="    assert len(hits)==2,(jp,hits);prog.append((jp,kr,2,';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
new="    expected=4 if jp=='変身しない' else 2\n    assert len(hits)==expected,(jp,hits);prog.append((jp,kr,len(hits),';'.join(f'LOGICAL 0x{x:X}' for x in hits)))"
if old not in src:
    raise SystemExit('v0.13 assertion pattern not found')
src=src.replace(old,new,1)
src=src.replace('KR ALPHA v0.13','KR ALPHA v0.14')
src=src.replace('v0.13','v0.14')
src=src.replace('KR13','KR14')
src=src.replace("CuteyHoneyFX_KR_ALPHA_v0.13.zip","CuteyHoneyFX_KR_ALPHA_v0.14.zip")
Path('/tmp/build_alpha_v014_inner.sh').write_text(src,encoding='utf-8')
PY
bash /tmp/build_alpha_v014_inner.sh

#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update -qq
sudo apt-get install -y -qq p7zip-full curl python3
mkdir -p /tmp/g analysis/cutey_full
curl -L --retry 3 --fail -o /tmp/c.7z 'https://archive.org/download/noaen-redump-nec-pc-fx-pc-fxga/Cutey%20Honey%20FX%20%28Japan%29.7z'
7z x -y /tmp/c.7z -o/tmp/g >/dev/null
T2=$(find /tmp/g -maxdepth 1 -name '*Track 2*.bin' | head -1)
echo '1dd574364e40cb90dd0ff25940fe8df9e6793edf  '"$T2" | sha1sum -c -
python3 - "$T2" <<'PY'
from pathlib import Path
import sys,re,csv,json,hashlib
from collections import Counter,defaultdict
R=Path(sys.argv[1]).read_bytes(); BASE=0x81330
n=(len(R)-BASE)//2352
L=bytearray(n*2048)
for s in range(n):
    ro=BASE+s*2352
    L[s*2048:(s+1)*2048]=R[ro+16:ro+2064]
L=bytes(L); assert L.startswith(b'PC-FX:Hu_CD-ROM')

def raw_of(lo):
    sec,ins=divmod(lo,2048); return BASE+sec*2352+16+ins

def quality(t):
    if not t or any(ord(c)<0x20 and c not in '\t\r\n' for c in t): return None
    jp=sum(1 for c in t if (0x3040<=ord(c)<=0x30ff) or (0x3400<=ord(c)<=0x9fff) or (0xff00<=ord(c)<=0xffef))
    vis=sum(1 for c in t if not c.isspace())
    if jp<2 or vis<2 or jp/vis<0.45: return None
    return jp,vis,jp/vis

def pair_codes(b):
    out=set(); i=0
    while i<len(b):
        a=b[i]
        if ((0x81<=a<=0x9f) or (0xe0<=a<=0xef)) and i+1<len(b):
            z=b[i+1]
            if (0x40<=z<=0x7e) or (0x80<=z<=0xfc): out.add((a<<8)|z); i+=2; continue
        i+=1
    return out

# C-level regex locates NUL-terminated byte runs; Python only validates candidates.
pat=re.compile(rb'([^\x00]{4,512})\x00')
rows=[]; used=set()
for m in pat.finditer(L):
    b=m.group(1); st=m.start(1)
    try: t=b.decode('shift_jis')
    except UnicodeDecodeError: continue
    q=quality(t)
    if q is None: continue
    jp,vis,ratio=q
    punct=any(c in t for c in '。！？!?…「」『』（）()・ー')
    kind='script_like' if punct or len(t)>=8 else ('name_like' if len(t)<=12 else 'other')
    sec,ins=divmod(st,2048)
    rows.append((st,raw_of(st),sec,ins,len(b),len(t),jp,ratio,kind,t,b.hex()))
    used |= pair_codes(b)

# Merge exact ESC<..ESC> text spans too, so safe proxy allocation covers verified control strings.
ctrl=re.compile(rb'\x1b\x3c..\x1b\x3e',re.S)
for m in ctrl.finditer(L):
    st=m.end(); e=st
    while e<len(L) and e-st<512 and L[e] not in (0,10,0x1b): e+=1
    b=L[st:e]
    try:t=b.decode('shift_jis')
    except UnicodeDecodeError:continue
    q=quality(t)
    if q is None:continue
    used |= pair_codes(b)
    if not any(r[0]==st and r[9]==t for r in rows):
        jp,vis,ratio=q; sec,ins=divmod(st,2048)
        rows.append((st,raw_of(st),sec,ins,len(b),len(t),jp,ratio,'control_block',t,b.hex()))

rows.sort(key=lambda r:r[0])
C=Counter(r[9] for r in rows); pos=defaultdict(list)
for r in rows:pos[r[9]].append(r[0])
out=Path('analysis/cutey_full')
with (out/'SJIS_FAST_CORPUS.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['id','logical_offset','track2_raw_offset','sector','in_payload','byte_len','char_len','jp_chars','jp_ratio','kind','jp_text','hex'])
    for i,r in enumerate(rows,1):w.writerow([i,f'0x{r[0]:X}',f'0x{r[1]:X}',r[2],f'0x{r[3]:X}',r[4],r[5],r[6],f'{r[7]:.3f}',r[8],r[9],r[10]])
with (out/'SJIS_FAST_UNIQUE.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['jp_text','occurrences','kind_example','first_logical_offset'])
    for text,c in sorted(C.items(),key=lambda kv:(-kv[1],kv[0])):
        ex=next(r for r in rows if r[9]==text);w.writerow([text,c,ex[8],f'0x{pos[text][0]:X}'])
rank=[]
for text,c in C.items():
    ex=next(r for r in rows if r[9]==text)
    pri=0 if ex[8] in ('control_block','script_like') else 1
    rank.append((pri,-len(text),-c,text,ex[8],pos[text][0]))
rank.sort()
with (out/'SJIS_FAST_TRANSLATION_QUEUE.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['priority','jp_text','occurrences','kind','first_logical_offset','kr_text','status'])
    for i,(_,_,_,text,kind,off) in enumerate(rank,1):w.writerow([i,text,C[text],kind,f'0x{off:X}','','UNTRANSLATED'])

pool=[]
for lead in [0xeb,0xec,0xed,0xee,0xef,0x87,0x9f,0x86,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e]:
    for tr in list(range(0x40,0x7f))+list(range(0x80,0xfd)):
        v=(lead<<8)|tr
        if v not in used:pool.append(v)
        if len(pool)>=512:break
    if len(pool)>=512:break
with (out/'SAFE_PROXY_POOL.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['rank','sjis_code','lead','trail'])
    for i,v in enumerate(pool,1):w.writerow([i,f'0x{v:04X}',f'0x{v>>8:02X}',f'0x{v&255:02X}'])
summary={'parent_track2_sha1':hashlib.sha1(R).hexdigest(),'logical_bytes':len(L),'accepted_occurrences':len(rows),'unique_strings':len(C),'used_sjis_pairs':len(used),'safe_proxy_pool':len(pool),'script_like_occurrences':sum(1 for r in rows if r[8]=='script_like'),'control_block_occurrences':sum(1 for r in rows if r[8]=='control_block'),'top_repeated':[{'text':t,'count':c} for t,c in C.most_common(30)],'longest':[{'text':r[9],'chars':r[5],'off':f'0x{r[0]:X}','kind':r[8]} for r in sorted(rows,key=lambda x:x[5],reverse=True)[:30]]}
(out/'SJIS_FAST_SUMMARY.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
PY

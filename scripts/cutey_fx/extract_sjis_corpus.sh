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
import sys,csv,json,hashlib,re
from collections import Counter,defaultdict
R=Path(sys.argv[1]).read_bytes(); BASE=0x81330
n=(len(R)-BASE)//2352
L=bytearray(n*2048)
for s in range(n):
    ro=BASE+s*2352
    L[s*2048:(s+1)*2048]=R[ro+16:ro+2064]
L=bytes(L)
assert L.startswith(b'PC-FX:Hu_CD-ROM')

def raw_of(lo):
    sec,ins=divmod(lo,2048)
    return BASE+sec*2352+16+ins

def sjis_char_len(buf,i):
    b=buf[i]
    if 0x20 <= b <= 0x7e or 0xa1 <= b <= 0xdf:
        return 1
    if ((0x81<=b<=0x9f) or (0xe0<=b<=0xef)) and i+1<len(buf):
        t=buf[i+1]
        if (0x40<=t<=0x7e) or (0x80<=t<=0xfc):
            return 2
    return 0

def japanese_score(t):
    jp=sum(1 for c in t if (0x3040<=ord(c)<=0x30ff) or (0x3400<=ord(c)<=0x9fff) or (0xff00<=ord(c)<=0xffef))
    vis=sum(1 for c in t if not c.isspace())
    return jp,vis,(jp/vis if vis else 0.0)

rows=[]; i=0; N=len(L)
while i<N:
    # Start only at bytes that can begin a printable SJIS character.
    if not sjis_char_len(L,i): i+=1; continue
    st=i; p=i; chars=0
    while p<N:
        k=sjis_char_len(L,p)
        if not k: break
        p+=k; chars+=1
        if p-st>512: break
    # Require NUL-terminated candidate and enough bytes.
    if p<N and L[p]==0 and p-st>=4 and chars>=2:
        b=L[st:p]
        try: t=b.decode('shift_jis')
        except UnicodeDecodeError:
            i=max(i+1,p+1); continue
        jp,vis,ratio=japanese_score(t)
        # Strong filter against binary false positives.
        if jp>=2 and vis>=2 and ratio>=0.45 and not any(ord(c)<0x20 for c in t):
            punct=any(c in t for c in '。！？!?…「」『』（）()・ー')
            kind='script_like' if punct or len(t)>=8 else ('name_like' if len(t)<=12 else 'other')
            sec,ins=divmod(st,2048)
            rows.append((st,raw_of(st),sec,ins,len(b),len(t),jp,ratio,kind,t,b.hex()))
        i=p+1
    else:
        i=st+1

# Deduplicate exact same start/text in case scanner behavior changes.
seen=set(); clean=[]
for r in rows:
    k=(r[0],r[9])
    if k not in seen: seen.add(k); clean.append(r)
rows=clean
C=Counter(r[9] for r in rows)
pos=defaultdict(list)
for r in rows: pos[r[9]].append(r[0])

out=Path('analysis/cutey_full')
with (out/'SJIS_NULL_CORPUS.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['id','logical_offset','track2_raw_offset','sector','in_payload','byte_len','char_len','jp_chars','jp_ratio','kind','jp_text','hex'])
    for idx,r in enumerate(rows,1):
        w.writerow([idx,f'0x{r[0]:X}',f'0x{r[1]:X}',r[2],f'0x{r[3]:X}',r[4],r[5],r[6],f'{r[7]:.3f}',r[8],r[9],r[10]])
with (out/'SJIS_NULL_UNIQUE.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['jp_text','occurrences','kind_example','first_logical_offset'])
    for text,c in sorted(C.items(),key=lambda kv:(-kv[1],kv[0])):
        ex=next(r for r in rows if r[9]==text)
        w.writerow([text,c,ex[8],f'0x{pos[text][0]:X}'])
# Translation queue: script-like first, then longer text, then occurrence count.
uniq=[]
for text,c in C.items():
    ex=next(r for r in rows if r[9]==text)
    uniq.append((0 if ex[8]=='script_like' else 1,-len(text),-c,text,ex[8],pos[text][0]))
uniq.sort()
with (out/'SJIS_TRANSLATION_QUEUE.csv').open('w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['priority','jp_text','occurrences','kind','first_logical_offset','kr_text','status'])
    for idx,(_,_,_,text,kind,off) in enumerate(uniq,1):
        w.writerow([idx,text,C[text],kind,f'0x{off:X}','','UNTRANSLATED'])
summary={
 'parent_track2_sha1':hashlib.sha1(R).hexdigest(),
 'logical_bytes':len(L),
 'null_terminated_candidates':len(rows),
 'unique_strings':len(C),
 'script_like_occurrences':sum(1 for r in rows if r[8]=='script_like'),
 'script_like_unique':len({r[9] for r in rows if r[8]=='script_like'}),
 'name_like_occurrences':sum(1 for r in rows if r[8]=='name_like'),
 'longest':[{'text':r[9],'chars':r[5],'off':f'0x{r[0]:X}'} for r in sorted(rows,key=lambda x:x[5],reverse=True)[:20]]
}
(out/'SJIS_CORPUS_SUMMARY.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
PY

#!/usr/bin/env bash
set -euxo pipefail
sudo apt-get update -qq
sudo apt-get install -y -qq p7zip-full unzip curl python3 python3-pil fonts-nanum golang-go
curl -L --retry 3 --fail -o /tmp/v.zip https://github.com/jbrandwood/v810-gcc/releases/download/latest/v810-gcc-Linux-x86_64.zip
mkdir -p /tmp/v /tmp/g /tmp/b /tmp/pkg analysis/cutey_full
unzip -q /tmp/v.zip -d /tmp/v
B=$(find /tmp/v -name v810-gcc -type f | head -1)
ROOT=$(dirname "$(dirname "$B")")
export PATH="$ROOT/bin:$PATH"
curl -L --retry 3 --fail -o /tmp/c.7z 'https://archive.org/download/noaen-redump-nec-pc-fx-pc-fxga/Cutey%20Honey%20FX%20%28Japan%29.7z'
7z x -y /tmp/c.7z -o/tmp/g >/dev/null
T1=$(find /tmp/g -maxdepth 1 -name '*Track 1*.bin' | head -1)
T2=$(find /tmp/g -maxdepth 1 -name '*Track 2*.bin' | head -1)
echo 'ffae85763f581d312abb6b5096f6f7d62e771aae  '"$T1" | sha1sum -c -
echo '1dd574364e40cb90dd0ff25940fe8df9e6793edf  '"$T2" | sha1sum -c -
cp "$T1" /tmp/g/t1.bin
cp "$T2" /tmp/g/t2.bin

python3 - <<'PY'
from pathlib import Path
import re,csv,json,hashlib
from collections import Counter
R=Path('/tmp/g/t2.bin').read_bytes();base=0x81330;n=(len(R)-base)//2352
L=bytearray(n*2048)
for s in range(n):
    ro=base+s*2352;L[s*2048:(s+1)*2048]=R[ro+16:ro+2064]
L=bytes(L);assert L.startswith(b'PC-FX:Hu_CD-ROM')
rows=[];used=set();mark=re.compile(rb'\x1b\x3c..\x1b\x3e',re.S)
for m in mark.finditer(L):
    p=m.end();e=p
    while e<len(L) and e-p<512 and L[e] not in (0,10,0x1b): e+=1
    b=L[p:e]
    try:t=b.decode('shift_jis')
    except UnicodeDecodeError:continue
    if not t:continue
    if not any((0x3040<=ord(c)<=0x30ff) or (0x3400<=ord(c)<=0x9fff) or (0xff00<=ord(c)<=0xffef) for c in t):continue
    sec=p//2048;ins=p%2048;rows.append((p,base+sec*2352+16+ins,sec,ins,len(b),t))
    i=0
    while i+1<len(b):
        a,z=b[i],b[i+1]
        if ((0x81<=a<=0x9f) or (0xe0<=a<=0xef)) and ((0x40<=z<=0x7e) or (0x80<=z<=0xfc)):
            used.add((a<<8)|z);i+=2
        else:i+=1
with open('/tmp/pkg/TEXT_CONTROL_INVENTORY.csv','w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['id','logical_offset','track2_raw_offset','sector','in_payload','byte_len','jp_text'])
    for i,r in enumerate(rows,1):w.writerow([i,f'0x{r[0]:X}',f'0x{r[1]:X}',r[2],f'0x{r[3]:X}',r[4],r[5]])
C=Counter(r[5] for r in rows)
with open('/tmp/pkg/TEXT_CONTROL_UNIQUE.csv','w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['jp_text','occurrences']);w.writerows(sorted(C.items(),key=lambda x:(-x[1],x[0])))
chars=list(dict.fromkeys('이전으로타이틀돌아가기종료저장불러오큐티하니변신키사라커맨드판지나트레슬안함'))
pool=[]
for lead in [0xeb,0xec,0xed,0xee,0xef,0x87,0x9f]:
    for tr in list(range(0x40,0x7f))+list(range(0x80,0xfd)):
        v=(lead<<8)|tr
        if v not in used:pool.append(v)
        if len(pool)>=len(chars):break
    if len(pool)>=len(chars):break
assert len(pool)>=len(chars)
M=dict(zip(chars,pool[:len(chars)]))
Path('/tmp/b/map.json').write_text(json.dumps(M,ensure_ascii=False),encoding='utf-8');Path('/tmp/b/L.bin').write_bytes(L)
known=['直前に戻る','タイトル画面に戻る','ＥＸＩＴ','セーブする','ロードする','キューティーハニーに変身！','如月ハニーに変身！','コマンドハニーに変身！','ファンタジーナイトハニーに変身！','レスラーハニーに変身！','変身しない']
S={'parent_track2_sha1':hashlib.sha1(R).hexdigest(),'control_occurrences':len(rows),'control_unique':len(C),'proxy_chars':len(chars),'known_counts':{x:L.count(x.encode('shift_jis')) for x in known}}
Path('/tmp/pkg/EXTRACTION_SUMMARY.json').write_text(json.dumps(S,ensure_ascii=False,indent=2),encoding='utf-8')
Path('/tmp/pkg/HANGUL_PROXY_MAP.json').write_text(json.dumps({k:f'0x{v:04X}' for k,v in M.items()},ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(S,ensure_ascii=False,indent=2))
PY

python3 - <<'PY'
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json
M=json.loads(Path('/tmp/b/map.json').read_text());chs=list(M);font='/usr/share/fonts/truetype/nanum/NanumGothicBold.ttf'
def img(c,n,fs):
    im=Image.new('1',(n,n),0);d=ImageDraw.Draw(im);f=ImageFont.truetype(font,fs);b=d.textbbox((0,0),c,font=f)
    d.text(((n-(b[2]-b[0]))//2-b[0],(n-(b[3]-b[1]))//2-b[1]),c,font=f,fill=1);return im
def a16(c):
    im=img(c,16,15);o=[]
    for y in range(16):
        r=0
        for x in range(16):
            if im.getpixel((x,y)):r|=1<<(15-x)
        o += [r>>8,r&255]
    return o
def a12(c):
    im=img(c,12,12);rr=[];o=[]
    for y in range(12):
        r=0
        for x in range(12):
            if im.getpixel((x,y)):r|=1<<(11-x)
        rr.append(r)
    for i in range(0,12,2):
        a,b=rr[i],rr[i+1];o += [a>>4,((a&15)<<4)|((b>>8)&15),b&255]
    return o
A=[a16(c) for c in chs];B=[a12(c) for c in chs]
def arr(n,a,w):return 'static const u8 %s[%d][%d] __attribute__((aligned(4)))={%s};'%(n,len(a),w,','.join('{'+','.join('0x%02X'%x for x in z)+'}' for z in a))
cond=[]
for i,c in enumerate(chs):
    v=int(M[c]);sw=((v&255)<<8)|(v>>8);cond.append(('if' if i==0 else 'else if')+f'(sjis==0x{v:04X}u||sjis==0x{sw:04X}u)idx={i}u;')
src='typedef unsigned int u32;typedef unsigned char u8;'+arr('g16',A,32)+arr('g12',B,18)+'__attribute__((noinline,section(".text.hook"))) u8* hook(u32 sjis,u32 type){unsigned idx=999u;' + ''.join(cond)+f'if(idx<{len(chs)}u){{if(type==0u)return (u8*)g16[idx];if(type==1u)return (u8*)g12[idx];}}return ((u8*(*)(u32,u32))0xFFF0000Cu)(sjis,type);}}'
Path('/tmp/b/h.c').write_text(src)
PY
v810-gcc -Os -ffreestanding -fno-builtin -fno-jump-tables -c /tmp/b/h.c -o /tmp/b/h.o
cat >/tmp/b/h.ld <<'EOF'
ENTRY(_hook)
SECTIONS { . = 0x6C800; .text : { *(.text.hook) *(.text*) } .rodata : { *(.rodata*) } .data : { *(.data*) } .bss : { *(.bss*) *(COMMON) } }
EOF
v810-ld -T /tmp/b/h.ld -o /tmp/b/h.elf /tmp/b/h.o
v810-objcopy -O binary /tmp/b/h.elf /tmp/b/h.bin
SZ=$(stat -c%s /tmp/b/h.bin);test $((0x6C800+SZ)) -le $((0x80000));echo HOOK_SIZE=$SZ >/tmp/pkg/HOOK_INFO.txt

python3 - <<'PY'
from pathlib import Path
import json,struct,hashlib,csv
R=Path('/tmp/g/t2.bin').read_bytes();L=bytearray(Path('/tmp/b/L.bin').read_bytes());H=Path('/tmp/b/h.bin').read_bytes();M=json.loads(Path('/tmp/b/map.json').read_text());base=0x81330;first=2;load=0x8000
def enc(s):
    z=bytearray()
    for c in s:
        if c in M:v=int(M[c]);z+=bytes([v>>8,v&255])
        elif c==' ':z+=b'\x81\x40'
        elif c=='！':z+=b'\x81\x49'
        else:raise ValueError(c)
    return bytes(z)
prog=[]
def exact_at(addr,jp,kr):
    o=first*2048+addr-load;old=jp.encode('shift_jis');new=enc(kr)
    assert L[o:o+len(old)]==old,(hex(addr),L[o:o+len(old)].hex(),old.hex())
    pad=len(old)-len(new);assert pad>=0 and pad%2==0,(jp,kr,len(old),len(new))
    L[o:o+len(old)]=new+b'\x81\x40'*(pad//2);prog.append((jp,kr,1,f'RAM 0x{addr:X}'))
exact_at(0x18222,'直前に戻る','이전으로')
exact_at(0x18233,'タイトル画面に戻る','타이틀로 돌아가기')
exact_at(0x1824D,'ＥＸＩＴ','종료')
exact_at(0x1825C,'セーブする','저장하기')
exact_at(0x1826D,'ロードする','불러오기')
for jp,kr in [('キューティーハニーに変身！','큐티하니로 변신！'),('如月ハニーに変身！','키사라기 변신！'),('コマンドハニーに変身！','커맨드하니 변신！'),('ファンタジーナイトハニーに変身！','판타지나이트 변신！'),('レスラーハニーに変身！','레슬러하니 변신！'),('変身しない','변신 안함')]:
    old=jp.encode('shift_jis');new=enc(kr);pad=len(old)-len(new);assert pad>=0 and pad%2==0,(jp,len(old),len(new));new+=b'\x81\x40'*(pad//2);hits=[];p=0
    while True:
        q=L.find(old,p)
        if q<0:break
        hits.append(q);L[q:q+len(old)]=new;p=q+len(old)
    assert len(hits)==2,(jp,hits);prog.append((jp,kr,2,';'.join(f'LOGICAL 0x{x:X}' for x in hits)))
def pay(n):return R[base+n*2352+16:base+n*2352+2064]
b0=b''.join(pay(n) for n in range(2,242));ho=0x6C800-load;assert all(x==0 for x in b0[ho:ho+len(H)]);L[first*2048+ho:first*2048+ho+len(H)]=H
def jal(pc,t):
    d=(t-pc)&0x03ffffff;return struct.pack('<HH',0xac00|((d>>16)&0x3ff),d&0xffff)
for pc,old in [(0x34944,b'\xec\xaf\xc8\xb6'),(0x34b46,b'\xec\xaf\xc6\xb4')]:
    o=pc-load;assert b0[o:o+4]==old;L[first*2048+o:first*2048+o+4]=jal(pc,0x6C800)
ed=[0]*256;ef=[0]*256;eb=[0]*256
for i in range(256):
    e=i;j=i<<1
    if j&0x100:j^=0x11d
    ef[i]=j;eb[i^j]=i
    for _ in range(8):e=(e>>1)^(0xd8018001 if e&1 else 0)
    ed[i]=e&0xffffffff
def E(a):
    e=0
    for b in a:e=(e>>8)^ed[(e^b)&255]
    return e&0xffffffff
def C(a,ma,mi,mul,inc):
    size=ma*mi;o=bytearray(ma*2)
    for m in range(ma):
        ix=(m>>1)*mul+(m&1);x=y=0
        for _ in range(mi):v=a[ix];ix=(ix+inc)%size;x^=v;y^=v;x=ef[x]
        x=eb[ef[x]^y];o[m]=x;o[m+ma]=x^y
    return o
def fix(s):
    s[0x810:0x814]=struct.pack('<I',E(s[:0x810]));s[0x814:0x81c]=b'\0'*8;s[0x81c:0x8c8]=C(s[0x0c:0x81c],86,24,2,86);s[0x8c8:0x930]=C(s[0x0c:0x8c8],52,43,86,88);return s
n=(len(R)-base)//2352;P=bytearray(R);rec=[]
for s in range(n):
    ro=base+s*2352;v=L[s*2048:(s+1)*2048]
    if v!=R[ro+16:ro+2064]:
        q=bytearray(R[ro:ro+2352]);assert q[15]==1;q[16:2064]=v;q=fix(q);P[ro:ro+2352]=q;rec.append((ro,bytes(q)))
blob=bytearray(b'KR13')+struct.pack('<I',len(rec))
for ro,q in rec:blob+=struct.pack('<Q',ro)+q
Path('/tmp/pkg/records.bin').write_bytes(blob)
info={'version':'KR ALPHA v0.13','parent_track2_sha1':hashlib.sha1(R).hexdigest(),'output_track2_sha256':hashlib.sha256(P).hexdigest(),'hook_size':len(H),'changed_raw_sectors':len(rec),'translations':prog}
Path('/tmp/pkg/BUILD_INFO.json').write_text(json.dumps(info,ensure_ascii=False,indent=2),encoding='utf-8')
with open('/tmp/pkg/TRANSLATION_PROGRESS.csv','w',encoding='utf-8-sig',newline='') as f:
    w=csv.writer(f);w.writerow(['jp','kr','occurrences','location']);w.writerows(prog)
print(json.dumps(info,ensure_ascii=False,indent=2))
PY

mkdir -p /tmp/go
cp /tmp/pkg/records.bin /tmp/go/records.bin
cat >/tmp/go/go.mod <<'EOF'
module cutey13
go 1.20
EOF
cat >/tmp/go/main.go <<'EOF'
package main
import("bufio";"crypto/sha1";_ "embed";"encoding/binary";"encoding/hex";"fmt";"io";"os";"path/filepath";"strings")
//go:embed records.bin
var r []byte
const s1 int64=9807840
const s2 int64=656549040
const h1="ffae85763f581d312abb6b5096f6f7d62e771aae"
const h2="1dd574364e40cb90dd0ff25940fe8df9e6793edf"
func pause(){fmt.Print("\nPress Enter to close...");bufio.NewReader(os.Stdin).ReadString('\n')}
func hs(p string)string{f,e:=os.Open(p);if e!=nil{return ""};defer f.Close();h:=sha1.New();io.Copy(h,f);return hex.EncodeToString(h.Sum(nil))}
func pick(d string,n int64)[]string{es,_:=os.ReadDir(d);a:=[]string{};for _,x:=range es{if x.IsDir()||!strings.EqualFold(filepath.Ext(x.Name()),".bin"){continue};q,_:=x.Info();if q!=nil&&q.Size()==n{a=append(a,filepath.Join(d,x.Name()))}};return a}
func main(){fmt.Println("Cutey Honey FX KR ALPHA v0.13");fmt.Println("================================");e,_:=os.Executable();d:=filepath.Dir(e);a:=pick(d,s2);if len(a)!=1{fmt.Println("[ERROR] CLEAN Track2 must be the only 656549040-byte BIN.");pause();return};t2:=a[0];if hs(t2)!=h2{fmt.Println("[ERROR] Track2 CLEAN mismatch");pause();return};a=pick(d,s1);if len(a)!=1||hs(a[0])!=h1{fmt.Println("[ERROR] Track1 CLEAN mismatch/not unique");pause();return};t1:=a[0];dst:=filepath.Join(d,"Cutey Honey FX (Japan) (Track 2) [KR ALPHA v0.13].bin");i,_:=os.Open(t2);o,_:=os.Create(dst);fmt.Println("[1/3] Copying Track2...");io.Copy(o,i);i.Close();if len(r)<8||string(r[:4])!="KR13"{o.Close();fmt.Println("[ERROR] internal patch");pause();return};n:=binary.LittleEndian.Uint32(r[4:8]);p:=8;fmt.Printf("[2/3] Applying %d MODE1 sectors...\n",n);for z:=uint32(0);z<n;z++{off:=binary.LittleEndian.Uint64(r[p:p+8]);p+=8;o.Seek(int64(off),0);o.Write(r[p:p+2352]);p+=2352};o.Close();cue:=fmt.Sprintf("FILE \"%s\" BINARY\r\n  TRACK 01 AUDIO\r\n    INDEX 01 00:00:00\r\nFILE \"%s\" BINARY\r\n  TRACK 02 MODE1/2352\r\n    INDEX 00 00:00:00\r\n    INDEX 01 00:03:00\r\n",filepath.Base(t1),filepath.Base(dst));cp:=filepath.Join(d,"Cutey Honey FX (Japan) [KR ALPHA v0.13].cue");os.WriteFile(cp,[]byte(cue),0644);fmt.Println("[3/3] [PASS]",cp);fmt.Println("System UI + all 6 transformation choices localized.");fmt.Println("STATUS: PRE-HW");pause()}
EOF
(cd /tmp/go && GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags='-s -w' -o /tmp/pkg/CuteyHoneyFX_KR_ALPHA_v0.13_Patcher.exe .)
cat >/tmp/pkg/README_KO.txt <<'EOF'
큐티하니 FX KR ALPHA v0.13
===========================
CLEAN Redump split Track1/Track2 only.

반영:
直前に戻る -> 이전으로
タイトル画面に戻る -> 타이틀로 돌아가기
ＥＸＩＴ -> 종료
セーブする -> 저장하기
ロードする -> 불러오기

변신 선택 6종 전체:
큐티하니로 변신！ / 키사라기 변신！ / 커맨드하니 변신！
판타지나이트 변신！ / 레슬러하니 변신！ / 변신 안함

TEXT_CONTROL_INVENTORY.csv = 실제 ESC<...ESC> 텍스트 제어블록 기반 일본어 문자열 후보 목록.
POC01/POC02 = HW PASS LOCK. v0.13 = STATIC BUILD PASS / PRE-HW until user test.
EOF
printf 'POC01 HW PASS LOCK\nPOC02 save/load HW PASS LOCK\nALPHA v0.13 STATIC BUILD PASS / PRE-HW\n' >/tmp/pkg/STATUS.txt
(cd /tmp/pkg && sha256sum * > SHA256SUMS.txt && zip -9 -r /tmp/CuteyHoneyFX_KR_ALPHA_v0.13.zip . >/dev/null)

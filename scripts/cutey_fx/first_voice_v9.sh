#!/usr/bin/env bash
set -euxo pipefail

EMUCAP_COMMIT=3887f9e9de7525087c30ca4434d9cb8c3ff15103
PORT=47800
OUT=/tmp/v9
rm -rf "$OUT" /tmp/emucap /tmp/game /tmp/whisper
mkdir -p "$OUT" /tmp/game analysis/cutey_full/first_voice_v9

git clone -q https://github.com/mcpads/emucap.git /tmp/emucap
cd /tmp/emucap
git checkout -q "$EMUCAP_COMMIT"
adapters/mednafen/build.sh
python3 - <<'PY'
p='/tmp/emucap/adapters/mednafen/launch.sh'
s=open(p).read()
needle='ARGS=(-sound "${MEDNAFEN_SOUND:-0}")'
assert needle in s
s=s.replace(needle, needle+'\nARGS+=(-soundrecord "/tmp/v9/full.wav")',1)
open(p,'w').write(s)
PY
cd "$GITHUB_WORKSPACE"

curl -L --retry 3 --fail -o /tmp/cutey.7z 'https://archive.org/download/noaen-redump-nec-pc-fx-pc-fxga/Cutey%20Honey%20FX%20%28Japan%29.7z'
7z x -y /tmp/cutey.7z -o/tmp/game >/dev/null
T1=$(find /tmp/game -maxdepth 1 -type f -name '*Track 1*.bin' | head -1)
T2=$(find /tmp/game -maxdepth 1 -type f -name '*Track 2*.bin' | head -1)
echo 'ffae85763f581d312abb6b5096f6f7d62e771aae  '"$T1" | sha1sum -c -
echo '1dd574364e40cb90dd0ff25940fe8df9e6793edf  '"$T2" | sha1sum -c -
B1=$(basename "$T1"); B2=$(basename "$T2")
printf 'FILE "%s" BINARY\n  TRACK 01 AUDIO\n    INDEX 01 00:00:00\nFILE "%s" BINARY\n  TRACK 02 MODE1/2352\n    INDEX 00 00:00:00\n    INDEX 01 00:03:00\n' "$B1" "$B2" >/tmp/game/game.cue
curl -L --retry 3 --fail -o /tmp/pcfx.rom https://raw.githubusercontent.com/Abdess/retrobios/master/bios/NEC/PC-FX/pcfx.rom
echo '4b44ccf5d84cc83daa2e6a2bee00fdafa14eb58bdf5859e96d8861a891675417  /tmp/pcfx.rom' | sha256sum -c -

cat >"$OUT/cap.py" <<'PY'
import socket,subprocess,os,json,time,signal
root='/tmp/emucap'; cue='/tmp/game/game.cue'; port=47800
srv=socket.socket(); srv.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1); srv.bind(('127.0.0.1',port)); srv.listen(1); srv.settimeout(120)
env=os.environ.copy(); env.update({'EMUCAP_PCFX_BIOS':'/tmp/pcfx.rom','MEDNAFEN_FORCE_MODULE':'pcfx','MEDNAFEN_SOUND':'1','EMUCAP_HEADLESS':'1','EMUCAP_START_FROZEN':'1','SDL_VIDEODRIVER':'dummy','SDL_AUDIODRIVER':'dummy'})
log=open('/tmp/v9/launcher.log','w')
launcher=subprocess.Popen([root+'/adapters/mednafen/launch.sh',cue,str(port)],cwd=root+'/adapters/mednafen',env=env,stdout=log,stderr=subprocess.STDOUT)
meta={'launcher_pid':launcher.pid}
c=None
emu_pid=None
try:
    c,_=srv.accept(); c.settimeout(90); f=c.makefile('rwb',buffering=0); rid=[0]
    def req(m,pa=None):
        rid[0]+=1; i=rid[0]
        f.write((json.dumps({'v':1,'id':i,'method':m,'params':pa or {}},separators=(',',':'))+'\n').encode())
        while True:
            line=f.readline()
            if not line: raise RuntimeError('emucap socket closed')
            v=json.loads(line)
            if v.get('id')!=i: continue
            if not v.get('ok'): raise RuntimeError(json.dumps(v))
            return v.get('result')
    def wait():
        for _ in range(1000):
            s=req('status',{})
            if str(s.get('state','')).lower() in ('frozen','paused','stopped'): return s
            time.sleep(.01)
        raise RuntimeError('guest did not freeze')
    def step(n): req('step',{'frames':n}); return wait()
    h=req('hello',{}); meta['build']=h.get('build')
    pidfile=os.path.expanduser(f'~/.local/share/emucap/mednafen/{port}/mednafen.pid')
    for _ in range(100):
        if os.path.exists(pidfile):
            try:
                emu_pid=int(open(pidfile).read().strip()); break
            except: pass
        time.sleep(.05)
    if not emu_pid: raise RuntimeError('Mednafen PID file unavailable')
    meta['emulator_pid']=emu_pid
    step(720); meta['run_press_abs_frame']=req('status',{}).get('frame')
    req('set_input',{'port':0,'buttons':['run']}); step(3); req('set_input',{'port':0,'buttons':[]}); step(2)
    step(1200); meta['end_frame']=req('status',{}).get('frame')
finally:
    open('/tmp/v9/CAPTURE_META.json','w').write(json.dumps(meta,indent=2))
    try:
        if c: c.close()
    except: pass
    try: srv.close()
    except: pass
    # launch.sh returns after spawning the actual emulator.  Signal the PID from
    # emucap's PID file so Mednafen can flush/close -soundrecord cleanly.
    if emu_pid:
        try: os.kill(emu_pid,signal.SIGINT)
        except ProcessLookupError: pass
        deadline=time.time()+20
        while time.time()<deadline:
            try: os.kill(emu_pid,0)
            except ProcessLookupError: break
            time.sleep(.1)
        else:
            try: os.kill(emu_pid,signal.SIGTERM)
            except ProcessLookupError: pass
            time.sleep(2)
            try: os.kill(emu_pid,signal.SIGKILL)
            except ProcessLookupError: pass
    try: launcher.wait(timeout=5)
    except: pass
    log.close()
PY
python3 "$OUT/cap.py"
ls -l "$OUT/full.wav"
test $(stat -c %s "$OUT/full.wav") -gt 44
ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT/full.wav" | tee "$OUT/WAV_DURATION.txt"

# Keep the first-pass ASR deterministic and Japanese-only.  It is evidence, not
# an insertion source until aligned to verified runtime timing/text structures.
git clone -q --depth 1 https://github.com/ggerganov/whisper.cpp.git /tmp/whisper
cmake -S /tmp/whisper -B /tmp/whisper/build -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=ON >/dev/null
cmake --build /tmp/whisper/build -j2 >/dev/null
bash /tmp/whisper/models/download-ggml-model.sh base /tmp/whisper/models >/dev/null
ffmpeg -y -loglevel error -i "$OUT/full.wav" -ar 16000 -ac 1 "$OUT/mono.wav"
/tmp/whisper/build/bin/whisper-cli -m /tmp/whisper/models/ggml-base.bin -f "$OUT/mono.wav" -l ja -otxt -osrt -of "$OUT/FIRST_VOICE" 2>&1 | tee "$OUT/WHISPER_LOG.txt"

cp "$OUT/CAPTURE_META.json" "$OUT/WAV_DURATION.txt" "$OUT/FIRST_VOICE.txt" "$OUT/FIRST_VOICE.srt" "$OUT/WHISPER_LOG.txt" analysis/cutey_full/first_voice_v9/
tail -200 "$OUT/launcher.log" > analysis/cutey_full/first_voice_v9/MEDNAFEN_LAUNCHER_LOG.txt || true

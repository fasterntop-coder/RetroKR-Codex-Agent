#!/usr/bin/env bash
set -euxo pipefail

EMUCAP_COMMIT=3887f9e9de7525087c30ca4434d9cb8c3ff15103
PORT=47800
OUT=/tmp/v10
ANALYSIS="$GITHUB_WORKSPACE/analysis/cutey_full/first_voice_v10"
rm -rf "$OUT" /tmp/emucap /tmp/game /tmp/whisper
mkdir -p "$OUT" /tmp/game "$ANALYSIS"

collect_diag() {
  set +e
  cp "$OUT/CAPTURE_META.json" "$ANALYSIS/" 2>/dev/null
  cp "$OUT/WAV_SIZE_TRACE.txt" "$ANALYSIS/" 2>/dev/null
  cp "$OUT/WAV_DURATION.txt" "$ANALYSIS/" 2>/dev/null
  cp "$OUT/FIRST_VOICE.txt" "$OUT/FIRST_VOICE.srt" "$OUT/WHISPER_LOG.txt" "$ANALYSIS/" 2>/dev/null
  tail -300 "$OUT/launcher.log" > "$ANALYSIS/LAUNCHER_WRAPPER_LOG.txt" 2>/dev/null
  RUNDIR="${HOME}/.local/share/emucap/mednafen/${PORT}"
  tail -400 "$RUNDIR/mednafen.log" > "$ANALYSIS/MEDNAFEN_LOG.txt" 2>/dev/null
  if [ -f "$OUT/full.wav" ]; then
    stat -c '%s' "$OUT/full.wav" > "$ANALYSIS/FULL_WAV_BYTES.txt" 2>/dev/null
  fi
}
trap collect_diag EXIT

git clone -q https://github.com/mcpads/emucap.git /tmp/emucap
cd /tmp/emucap
git checkout -q "$EMUCAP_COMMIT"
adapters/mednafen/build.sh
python3 - <<'PY'
p='/tmp/emucap/adapters/mednafen/launch.sh'
s=open(p).read()
needle='ARGS=(-sound "${MEDNAFEN_SOUND:-0}")'
assert needle in s
s=s.replace(needle, needle+'\nARGS+=(-soundrecord "/tmp/v10/full.wav")',1)
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
root='/tmp/emucap'; cue='/tmp/game/game.cue'; port=47800; out='/tmp/v10'
srv=socket.socket(); srv.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1); srv.bind(('127.0.0.1',port)); srv.listen(1); srv.settimeout(120)
env=os.environ.copy(); env.update({'EMUCAP_PCFX_BIOS':'/tmp/pcfx.rom','MEDNAFEN_FORCE_MODULE':'pcfx','MEDNAFEN_SOUND':'1','EMUCAP_HEADLESS':'1','EMUCAP_START_FROZEN':'1','SDL_VIDEODRIVER':'dummy','SDL_AUDIODRIVER':'dummy'})
log=open(out+'/launcher.log','w')
launcher=subprocess.Popen([root+'/adapters/mednafen/launch.sh',cue,str(port)],cwd=root+'/adapters/mednafen',env=env,stdout=log,stderr=subprocess.STDOUT)
meta={'launcher_pid':launcher.pid,'shutdown_order':'signal emulator while emucap socket remains open; close socket only after emulator exits'}
c=None; f=None; emu_pid=None

def proc_state(pid):
    try:
        with open(f'/proc/{pid}/stat') as h:
            return h.read().split()[2]
    except Exception:
        return None

def alive_non_zombie(pid):
    st=proc_state(pid)
    return st is not None and st != 'Z'

def wav_size():
    try: return os.path.getsize(out+'/full.wav')
    except OSError: return -1

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
    for _ in range(200):
        if os.path.exists(pidfile):
            try:
                emu_pid=int(open(pidfile).read().strip())
                if alive_non_zombie(emu_pid): break
                emu_pid=None
            except Exception: emu_pid=None
        time.sleep(.05)
    if not emu_pid: raise RuntimeError('Mednafen PID file unavailable/live process missing')
    meta['emulator_pid']=emu_pid
    step(720); meta['run_press_abs_frame']=req('status',{}).get('frame')
    req('set_input',{'port':0,'buttons':['run']}); step(3); req('set_input',{'port':0,'buttons':[]}); step(2)
    step(1200); meta['end_frame']=req('status',{}).get('frame')
    meta['wav_bytes_before_shutdown']=wav_size()

    # v9 closed the emucap socket first. v10 keeps it open while Mednafen receives
    # a graceful interrupt, so -soundrecord can run its normal close/flush path.
    os.kill(emu_pid,signal.SIGINT)
    meta['signal']='SIGINT'
    deadline=time.time()+30
    trace=[]
    while time.time()<deadline:
        trace.append({'t':round(time.time(),3),'proc_state':proc_state(emu_pid),'wav_bytes':wav_size()})
        if not alive_non_zombie(emu_pid): break
        time.sleep(.25)
    meta['exited_after_sigint']=not alive_non_zombie(emu_pid)
    if alive_non_zombie(emu_pid):
        os.kill(emu_pid,signal.SIGTERM); meta['signal_fallback']='SIGTERM'
        deadline=time.time()+10
        while time.time()<deadline and alive_non_zombie(emu_pid):
            trace.append({'t':round(time.time(),3),'proc_state':proc_state(emu_pid),'wav_bytes':wav_size()})
            time.sleep(.25)
    if alive_non_zombie(emu_pid):
        os.kill(emu_pid,signal.SIGKILL); meta['signal_fallback2']='SIGKILL'; time.sleep(1)
    open(out+'/WAV_SIZE_TRACE.txt','w').write('\n'.join(json.dumps(x,sort_keys=True) for x in trace)+'\n')
    # Wait for file metadata to settle after process exit.
    sizes=[]
    for _ in range(20):
        sizes.append(wav_size()); time.sleep(.1)
    meta['wav_sizes_post_exit']=sizes
finally:
    meta['wav_bytes_final']=wav_size()
    open(out+'/CAPTURE_META.json','w').write(json.dumps(meta,indent=2,sort_keys=True))
    # Only now close the protocol stream/server.
    try:
        if f: f.close()
    except Exception: pass
    try:
        if c: c.close()
    except Exception: pass
    try: srv.close()
    except Exception: pass
    try: launcher.wait(timeout=5)
    except Exception: pass
    log.close()
PY
python3 "$OUT/cap.py"
ls -l "$OUT/full.wav"
test "$(stat -c %s "$OUT/full.wav")" -gt 44
ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 "$OUT/full.wav" | tee "$OUT/WAV_DURATION.txt"

git clone -q --depth 1 https://github.com/ggerganov/whisper.cpp.git /tmp/whisper
cmake -S /tmp/whisper -B /tmp/whisper/build -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=ON >/dev/null
cmake --build /tmp/whisper/build -j2 >/dev/null
bash /tmp/whisper/models/download-ggml-model.sh base /tmp/whisper/models >/dev/null
ffmpeg -y -loglevel error -i "$OUT/full.wav" -ar 16000 -ac 1 "$OUT/mono.wav"
/tmp/whisper/build/bin/whisper-cli -m /tmp/whisper/models/ggml-base.bin -f "$OUT/mono.wav" -l ja -otxt -osrt -of "$OUT/FIRST_VOICE" 2>&1 | tee "$OUT/WHISPER_LOG.txt"

cp "$OUT/CAPTURE_META.json" "$OUT/WAV_SIZE_TRACE.txt" "$OUT/WAV_DURATION.txt" "$OUT/FIRST_VOICE.txt" "$OUT/FIRST_VOICE.srt" "$OUT/WHISPER_LOG.txt" "$ANALYSIS/"

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""ARC THE LAD III REBUILD V2 — RC001 CURRENT-CLEAN PREHW

Reproduces the previously recorded RC001 build from the exact canonical
ARC3_REBUILD_V2_BASELINE_001 Disc 1 image.

Scope:
  DATA.BIN + 0xE7226 : むむ…。 -> 으음…
  No font, renderer, HUD, SCPS, DATA2.BIN, or DATA3.BIN writes.

The patcher is fail-closed:
  * exact whole-disc SHA-256 guard
  * exact source bytes guard
  * MODE2/Form1 guard
  * EDC/ECC rebuild
  * readback guard
  * exact final BIN SHA-256 guard

Runtime status remains PREHW / USER_RUNTIME_PENDING until the user tests
this exact output hash on hardware/emulator.
"""
from __future__ import annotations

import hashlib
import os
import shutil
import struct
import sys
from pathlib import Path

SECTOR_SIZE = 2352
USER_OFFSET = 24
USER_SIZE = 2048

BASELINE_SIZE = 638_678_544
BASELINE_SHA256 = "6f3ec9a3e1193f49376fcae4f54f912dbfac7b773e1dc1c6d6bbe980d1ca124c"
EXPECTED_OUTPUT_SHA256 = "aea23b69b19a8302092726a56e331d882f60262abb4e8cd9f5ee0e5e22156750"

DATA_BIN_LBA = 1106
DATA_BIN_OFFSET = 0xE7226
TARGET_LBA = 1568
TARGET_USER_OFFSET = 550
OLD_BYTES = bytes.fromhex("b280b28012800280ffff")
NEW_BYTES = bytes.fromhex("2984d584128000e0ffff")

OUTPUT_NAME = "ARC3_REBUILD_V2_RC001_CURRENT_CLEAN_PREHW.bin"
CUE_NAME = "ARC3_REBUILD_V2_RC001_CURRENT_CLEAN_PREHW.cue"

EDC_LUT = [0] * 256
ECC_F = [0] * 256
ECC_B = [0] * 256
for i in range(256):
    edc = i
    for _ in range(8):
        edc = (edc >> 1) ^ (0xD8018001 if edc & 1 else 0)
    EDC_LUT[i] = edc & 0xFFFFFFFF

    j = i << 1
    if j & 0x100:
        j ^= 0x11D
    ECC_F[i] = j
    ECC_B[i ^ j] = i


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(8 * 1024 * 1024), b""):
            h.update(block)
    return h.hexdigest()


def edc_compute(src: bytes, edc: int = 0) -> int:
    for value in src:
        edc = (edc >> 8) ^ EDC_LUT[(edc ^ value) & 0xFF]
    return edc & 0xFFFFFFFF


def ecc_compute(src: bytes, major_count: int, minor_count: int,
                major_mult: int, minor_inc: int) -> bytes:
    size = major_count * minor_count
    out = bytearray(major_count * 2)
    for major in range(major_count):
        index = (major >> 1) * major_mult + (major & 1)
        a = b = 0
        for _ in range(minor_count):
            temp = src[index]
            index += minor_inc
            if index >= size:
                index -= size
            a ^= temp
            b ^= temp
            a = ECC_F[a]
        a = ECC_B[ECC_F[a] ^ b]
        out[major] = a
        out[major + major_count] = a ^ b
    return bytes(out)


def rebuild_mode2_form1(sec: bytearray) -> None:
    if len(sec) != SECTOR_SIZE:
        raise RuntimeError("수정 대상 섹터 길이가 2352바이트가 아닙니다.")
    if sec[15] != 2 or (sec[18] & 0x20):
        raise RuntimeError("수정 대상 섹터가 MODE2/Form1이 아닙니다.")
    if sec[16:20] != sec[20:24]:
        raise RuntimeError("MODE2 subheader duplicate가 일치하지 않습니다.")

    struct.pack_into("<I", sec, 2072, edc_compute(sec[16:2072]))

    work = bytearray(sec)
    work[12:16] = b"\0" * 4
    sec[2076:2248] = ecc_compute(work[12:2076], 86, 24, 2, 86)

    work = bytearray(sec)
    work[12:16] = b"\0" * 4
    sec[2248:2352] = ecc_compute(work[12:2248], 52, 43, 86, 88)


def patch_one_sector(output_bin: Path) -> None:
    calc_sector, calc_user = divmod(DATA_BIN_OFFSET, USER_SIZE)
    calc_lba = DATA_BIN_LBA + calc_sector
    if (calc_lba, calc_user) != (TARGET_LBA, TARGET_USER_OFFSET):
        raise RuntimeError(
            f"내부 주소 계약 실패: 계산=({calc_lba},{calc_user}) "
            f"고정=({TARGET_LBA},{TARGET_USER_OFFSET})"
        )

    raw = TARGET_LBA * SECTOR_SIZE
    with output_bin.open("r+b") as f:
        f.seek(raw)
        sec = bytearray(f.read(SECTOR_SIZE))
        if len(sec) != SECTOR_SIZE:
            raise RuntimeError("대상 raw sector 읽기 실패")

        pos = USER_OFFSET + TARGET_USER_OFFSET
        got = bytes(sec[pos:pos + len(OLD_BYTES)])
        if got != OLD_BYTES:
            raise RuntimeError(
                "원문 바이트 가드 실패\n"
                f"DATA.BIN+0x{DATA_BIN_OFFSET:X}\n"
                f"expected={OLD_BYTES.hex()}\n"
                f"actual  ={got.hex()}"
            )

        sec[pos:pos + len(NEW_BYTES)] = NEW_BYTES
        rebuild_mode2_form1(sec)
        f.seek(raw)
        f.write(sec)

    with output_bin.open("rb") as f:
        f.seek(raw + USER_OFFSET + TARGET_USER_OFFSET)
        reread = f.read(len(NEW_BYTES))
    if reread != NEW_BYTES:
        raise RuntimeError("패치 후 readback 바이트가 일치하지 않습니다.")


def write_cue(path: Path, bin_name: str) -> None:
    text = (
        f'FILE "{bin_name}" BINARY\r\n'
        '  TRACK 01 MODE2/2352\r\n'
        '    INDEX 01 00:00:00\r\n'
    )
    path.write_bytes(text.encode("ascii"))


def main() -> int:
    if len(sys.argv) != 2:
        print("[사용법] CLEAN ARC3.bin을 00_APPLY...cmd 위로 드래그하세요.")
        print(f"[필수 SHA-256] {BASELINE_SHA256}")
        return 2

    source = Path(sys.argv[1]).expanduser().resolve()
    if not source.is_file():
        raise FileNotFoundError(source)
    if source.stat().st_size != BASELINE_SIZE:
        raise RuntimeError(
            f"CLEAN 크기 불일치: {source.stat().st_size} != {BASELINE_SIZE}"
        )

    print("[1/6] CLEAN SHA-256 확인 중...")
    source_sha = sha256_file(source)
    if source_sha != BASELINE_SHA256:
        raise RuntimeError(
            "지원하지 않는 원본입니다.\n"
            f"expected={BASELINE_SHA256}\nactual  ={source_sha}"
        )

    out_dir = Path(__file__).resolve().parent / "OUTPUT_RC001_CURRENT_CLEAN_PREHW"
    out_dir.mkdir(parents=True, exist_ok=True)
    output = out_dir / OUTPUT_NAME
    cue = out_dir / CUE_NAME
    output.unlink(missing_ok=True)
    cue.unlink(missing_ok=True)

    print("[2/6] CLEAN을 새 출력 BIN으로 복사 중...")
    shutil.copyfile(source, output)

    try:
        print("[3/6] DATA.BIN+0xE7226 guarded patch 적용 중...")
        patch_one_sector(output)

        print("[4/6] MODE2 EDC/ECC + readback 완료")
        print("[5/6] 최종 BIN SHA-256 검증 중...")
        final_sha = sha256_file(output)
        if final_sha != EXPECTED_OUTPUT_SHA256:
            raise RuntimeError(
                "최종 RC001 해시가 과거 검증값과 다릅니다. 출력물을 폐기합니다.\n"
                f"expected={EXPECTED_OUTPUT_SHA256}\nactual  ={final_sha}"
            )

        write_cue(cue, output.name)
        print("[6/6] PASS")
        print("===============================================")
        print("ARC3 REBUILD V2 RC001 CURRENT-CLEAN PREHW")
        print("むむ…。 -> 으음…")
        print(f"BIN: {output}")
        print(f"SHA-256: {final_sha}")
        print(f"CUE: {cue}")
        print("RUNTIME: USER TEST PENDING")
        print("===============================================")
        try:
            os.startfile(out_dir)  # type: ignore[attr-defined]
        except Exception:
            pass
        return 0
    except Exception:
        output.unlink(missing_ok=True)
        cue.unlink(missing_ok=True)
        raise


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"\n[FAIL] {exc}")
        raise SystemExit(1)

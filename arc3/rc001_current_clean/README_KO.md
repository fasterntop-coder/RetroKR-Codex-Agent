# ARC3 REBUILD V2 RC001 CURRENT-CLEAN PREHW

이 브랜치는 과거 ARC3 V2 RC001에서 기록된 **현재 canonical CLEAN 기준의 단일 대사 패치**를 재현하기 위한 fail-closed 원샷 패처입니다.

## 지원 원본

- 파일: `ARC3.bin`
- 크기: `638,678,544` bytes
- SHA-256: `6f3ec9a3e1193f49376fcae4f54f912dbfac7b773e1dc1c6d6bbe980d1ca124c`
- 형식: MODE2/2352

다른 원본은 패치를 시작하지 않습니다.

## 실제 변경

- 자산: `DATA.BIN`
- 자산 오프셋: `0xE7226`
- raw LBA: `1568`
- user-data offset: `550`
- 일본어: `むむ…。`
- 한국어: `으음…`
- old bytes: `b280b28012800280ffff`
- new bytes: `2984d584128000e0ffff`
- 기존 글리프 재사용: `으=0x429`, `음=0x4D5`, `…=0x012`
- 신규 글리프: 0
- SCPS/렌더러/HUD/폰트 변경: 0
- 수정 raw sector: LBA 1568 한 곳

패치 뒤 해당 MODE2/Form1 sector의 EDC, ECC P, ECC Q를 다시 계산합니다.

## 기대 결과

출력 BIN:
`ARC3_REBUILD_V2_RC001_CURRENT_CLEAN_PREHW.bin`

기대 SHA-256:
`aea23b69b19a8302092726a56e331d882f60262abb4e8cd9f5ee0e5e22156750`

이 해시가 과거 RC001 기록과 일치하지 않으면 패처가 출력물을 삭제하고 실패합니다.

## 사용법

1. 이 폴더의 두 실행 파일을 같은 위치에 둡니다.
2. 정확한 CLEAN `ARC3.bin`을 `00_APPLY_ARC3_REBUILD_V2_RC001_CURRENT_CLEAN.cmd` 위로 드래그합니다.
3. `OUTPUT_RC001_CURRENT_CLEAN_PREHW` 폴더가 생성됩니다.
4. 생성된 CUE를 DuckStation/실기 환경에서 실행합니다.

## 첫 검수 지점

- 새 게임 시작 및 타이틀/오프닝 회귀 여부
- 도둑 사건 Q06 #36의 `むむ…。` 위치에서 `으음…` 출력
- 직전/직후 대사 진행
- 글자 깨짐/겹침/프리징 없음
- 다음 메시지/이벤트로 정상 진행

## 판정

- SOURCE_QA: PASS (기존 기록)
- TRANSLATION_QA: PASS (기존 기록)
- STATIC_BINARY_QA: PASS (기존 기록)
- RC_BUILD / RC_READBACK: 과거 동일 출력 SHA로 PASS 기록
- RUNTIME: **USER_RUNTIME_PENDING**

이 브랜치는 100% 완성판이나 EXT 엔진 자체가 아닙니다. 현재 CLEAN에서 바이트 재현성이 증명된 안전 기준점입니다. ARC2 v0.90식 ARC3 EXT 엔진은 이 기준점과 별도 브랜치에서 진행해야 하며, QA40/41의 `9ca005...` DATA.BIN 계보 바이트를 그대로 가져오지 않습니다.

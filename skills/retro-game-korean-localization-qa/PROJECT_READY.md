# Retro Game Korean Localization QA Skill v1.5 FINAL — Project/Chat Ready

이 문서를 해당 채팅/프로젝트의 공통 레트로게임 한글화 QA 규칙으로 적용한다. 프로젝트별 사실·해시·용어·제어코드·글리프·포인터·LBA·실기 결과는 실제 근거만 사용하고 규칙을 임의 수정하지 않는다.

## 1. 두 결과 영역을 분리한다

### TRANSLATION_QA
문장/항목 단위 품질 판정. 처리 순서:
`입력 분류 -> TERM_SOURCE -> 초벌 번역 -> LENGTH_QA -> VOICE_QA -> TRANSLATIONESE_QA -> SPACING_QA -> PUN_QA -> 유형별 QA -> 자연어 재독 -> FINAL_STATUS`.

TERM_SOURCE:
`GOLDEN_LOCK > PROJECT_GLOSSARY > OFFICIAL_KR > ESTABLISHED_FANDOM > GENERIC_LEXICAL > SOURCE_SEMANTIC > NO_EVIDENCE`.

근거 없는 고유명사/세계관 용어는 `NO_EVIDENCE -> TERM_PROPOSAL`. 동일 원문 반복은 PROVISIONAL_TERM을 재사용해 중복 경고만 줄이며 PASS로 자동 승격하지 않는다.

캐릭터 말투 우선순위:
1. 확립된 캐릭터 말투
2. 화자/청자 관계
3. 장면/감정
4. 성격
5. 나이/지위
6. 게임 전체 톤

번역투(`~하는 것이다`, `~을 하였다`, `~에 있다`, `~인 바이다`, `~라고 할 수 있다`)를 피하고 실제 한국어 대사처럼 다듬는다. 띄어쓰기는 프로젝트 예외가 없으면 국립국어원 원칙형을 우선한다. 말장난은 `PUN_EXACT | CREATIVE_PASS | PUN_INCOMPLETE | PUN_FAIL`로 번역 품질과 분리한다.

LENGTH_QA 근거 우선순위:
`실제 픽셀 폭 > 실제 byte/character limit > 실기 확인 > 조건부 0.7 fallback`.
0.7은 영어 표시 슬롯 추정치에만 제한적으로 쓰며 원문 글자 수에 기계 적용하지 않는다.

DISPLAY_LIMIT와 BYTE_LIMIT를 분리한다. DISPLAY에서 제어코드 폭은 0, BYTE에서는 실제 인코딩 바이트를 센다. 복합 LIMIT은 세그먼트별 검사한다. `<NL>`은 폭 0이지만 필수 경계다. 제어코드 변경/삭제/필수 순서 훼손은 `FAIL_CONTROL_CODE`.

번역 FAIL 우선순위:
`FAIL_CONTROL_CODE > FAIL_TRANSLATION > FAIL_VOICE > FAIL_LENGTH > FAIL_SPACING`.
대표 FINAL_STATUS는 하나만 두고 나머지는 SECONDARY_FAIL로 보존한다. FAIL이 없으면 `TERM_PROPOSAL > CONTEXT_NEEDED > TECH_PENDING > PUN_FAIL > PUN_INCOMPLETE > PASS`.

잠금 용어와 길이 제한이 충돌하면 잠금을 임의로 깨지 않고 `LENGTH_CONFLICT`를 기록한다. 의심스러운 원문은 조용히 복원하지 않고 `SOURCE_TEXT_SUSPECTED_CORRUPTION`으로 남긴다.

### BUILD_RUNTIME_QA
ROM/ISO/BIN/archive/font/graphics/RC/release 안전성 판정. 단계:
`SOURCE_QA -> STATIC_BINARY_QA -> RC_BUILD -> RC_READBACK_QA -> RUNTIME_SMOKE -> CANONICAL_PROMOTION -> PATCH_PACKAGE -> RELEASE`.
각 단계 상태는 `PASS | FAIL | PENDING | NOT_RUN | BLOCKED`.

번역 FINAL_STATUS와 빌드 단계 상태를 절대 한 필드로 합치지 않는다.

## 2. CR-013 Source identity
정확한 원본 리비전/디스크/지역, 파일 크기/형식/트랙 모드, SHA-256을 가능한 범위에서 고정한다. 깨끗한 원본을 보존한다. 지원 해시가 다르면 구조가 같다고 가정하지 않는다. 호환 근거가 없으면 SOURCE_QA FAIL/BLOCKED.

## 3. CR-014 Scoped PASS
`번역 PASS != 바이너리 PASS != 실기 PASS`. 빌드 성공은 readback PASS가 아니다. 정적 PASS는 런타임 PASS가 아니다. 런타임이 필요한 프로젝트에서 실기를 안 돌렸다면 RUNTIME_SMOKE는 NOT_RUN/PENDING이고 canonical/release는 통과시키지 않는다.

## 4. CR-015 Glyph/font
TTF에 글자가 존재하는지만 보지 않는다. 실제 code->glyph slot, 활성/주소 가능 슬롯 수, 물리 타일/텍스처, missing/blank slot, 화면별 subset, 공유 슬롯 소비자를 검사한다. missing glyph, 잘못된 매핑, 입증된 slot overflow/collision은 STATIC_BINARY_QA FAIL.

## 5. CR-016 Binary structure
encoded byte, terminator, header/footer, record/block capacity, alignment/padding, pointer/offset/size table, count, next-entry boundary, sentinel/checksum, 보호 영역을 실제 포맷에 맞춰 검사한다. 고정 용량을 1바이트라도 확인된 상태에서 넘으면 FAIL. relocation은 관련 포인터/크기 갱신 완료 근거가 있어야 한다.

## 6. CR-017 Compression/archive
압축 해제/재압축 round-trip, compressed/uncompressed descriptor, allocation span, entry order/name/hash/flag/alignment/count/header/footer, 비대상 엔트리를 검사한다. repack 도구가 성공했다는 사실만으로 안전 PASS하지 않는다. 입증되지 않은 allocation shrink도 안전하다고 가정하지 않는다.

## 7. CR-018 Physical layout
offset/size/LBA/FST/sector, overlap=0, out-of-range=0, 비대상 물리 변경, 보호 위치를 확인한다. Mode2/2352, XA/STR, mixed track 등은 sector form/subheader, file/channel, coding/interleave, EDC/ECC 등 실제 계약을 확인한다. ISO가 부팅된다는 사실만으로 스트리밍 안전을 확정하지 않는다.

## 8. CR-019 Readback
가능하면 temp/partial에 빌드하고 입력 해시/교체 전제 확인 후 직렬화한다. 최종 ROM/디스크/아카이브에서 변경 영역을 다시 읽어 의도한 bytes/hash와 비교하고 보호 영역도 다시 검증한다. 최종 output SHA를 기록한다. `script exit 0`은 RC_READBACK_QA PASS가 아니다.

## 9. CR-020 Runtime/canonical/release
실기/에뮬레이터 검수는 정확한 RC SHA에 귀속한다. 최근 수정 소비처와 부팅/타이틀/로드/메뉴/대사/컷신/전투 전후/맵 이동/저장로드/디스크 교체 등 프로젝트별 경계를 확인한다. 프리징 발생 시 exact LKG와 FKB를 기록하고 text/font/graphics/archive/hook/physical integration을 분리해 원인을 좁힌다. 원인 불명 상태에서 여러 계층을 한꺼번에 더 바꾸지 않는다.

프로젝트에서 요구한 runtime path를 통과한 정확한 RC만 canonical로 승격한다. 패치/배포본은 canonical로부터 만든다.

## 10. 기본 출력
문장 QA:
```text
원문:
분류:
번역:
TERM_SOURCE:
말장난 상태:
번역 품질:
최종 상태:
이슈:
```

빌드 QA를 함께 할 때:
```text
SOURCE_QA:
STATIC_BINARY_QA:
RC_BUILD:
RC_READBACK_QA:
RUNTIME_SMOKE:
CANONICAL_PROMOTION:
PATCH_PACKAGE:
RELEASE:
BUILD_FAIL_CODES:
PROTECTED_REGION_STATUS:
MISSING_GLYPHS:
OVERFLOW_COUNT:
POINTER_OFFSET_SIZE_MISMATCH_COUNT:
PHYSICAL_OVERLAP_COUNT:
PHYSICAL_OUT_OF_RANGE_COUNT:
LKG_ID:
FKB_ID:
RELEASE_STATE:
BUILD_ISSUES:
```
모르는 값을 0으로 만들어 쓰지 않는다.

## 11. v1.5 lock
v1.4의 CORE translation rules는 유지한다. CR-011/012는 여전히 DEFERRED. v1.5 신규 안전 레이어는 CR-013~020. 신규 검증 시나리오는 24/24 사양 시뮬레이션 PASS. 전체 Synthetic 100 원문 corpus가 패키지에 없으므로 존재하지 않는 100행을 꾸며 새 회귀를 했다고 주장하지 않는다.

## 적용 문구
`이 문서를 Retro Game Korean Localization QA Skill v1.5 FINAL로 적용하고, 기존 프로젝트의 더 엄격한 안전 기준/Golden Lock/실기 PASS 기준선은 유지해.`
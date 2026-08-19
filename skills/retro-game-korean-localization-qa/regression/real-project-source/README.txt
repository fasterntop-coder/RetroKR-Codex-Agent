ARC3 Real Project Test v1.0 SOURCE PACK — GitHub copy
====================================================

Source: ARC3_KR_QA45_QA44_ITIO_TOWN_SCREENFIX.zip
Policy: latest QA45 package only / no fabricated strings / no cross-game mixing.

Files
- 01_DIALOGUE_200.csv.gz: gzip-compressed exact copy of the 200-row dialogue CSV. Decompress to recover 01_DIALOGUE_200.csv.
- 02_UI_SYSTEM_DESCRIPTION_ACTUAL.csv: 28 actual UI/system/signage/location strings found inside the same latest package.
- 03_ITEM_TERM_CANDIDATES_NOT_COUNTED.csv: item-like terms occurring inside dialogue; not counted as standalone item-table records.
- 00_MANIFEST.json: counts and missing-category report.

Integrity
- 01_DIALOGUE_200.csv SHA-256: bccf6467bb2a84401612b717435dfe3601d89762640fb668d9241dbd39612456
- 01_DIALOGUE_200.csv.gz SHA-256: 4a02f537ca87eedfe8f66fd82fb017516d75ff54e7ecbd493294f17af9642c5a

Important
The latest QA45 package does NOT contain a standalone 50-60 item/skill table or 100 item descriptions. Those quotas are left missing rather than fabricated.

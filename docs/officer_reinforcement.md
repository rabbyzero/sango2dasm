# Auto-arrival reinforcement pools (bank $31 $8D74)

Every month `EventReinforceGate` (`$A33C`, prg_19_1a_event_scenes,
sub-state 2 of the monthly event dispatch) picks the acting
Country's pool - Countries 2/3/4, with 6 aliasing slot 3;
Countries 0/1/5 have none - and `OfficerReinforceScene`
(`$AEC0`) inspects the FIRST still-hidden officer in list
order. Once his year has arrived he joins the Country's
home Province roster (状態 <- 2, officer card shown); if his
year has not arrived, the month's check ends. The byte
stored is `year - 100` (`@ReinforceScan` $AF12 compares it
straight against $6F00, which ticks each January, so January
of that year is the first possible pass). A home Province
roster holds 10 officers ($11-$1A); when all 10 slots are
full the insertion fails and the same officer is retried
next month - the arrival slips a month at a time, not a
whole year. At most one officer joins per Country per month.

These are exactly the 26 hidden officers with no arrival-
schedule entry, grouped by family. Editing surface:
`docs/officer_reinforcement.csv` (this file's CSV twin),
re-rendered into `asm/banks/data_11_officer.asm` by
`tools/gen_data_bank_asm.py --from-csv`.

## Pool 0 -> Country 2

| officer | name | join year | byte |
|---|---|---:|---:|
| 32 | 夏侯楙 カコウボウ | 196 | $60 |
| 129 | 曹真 ソウシン | 200 | $64 |
| 124 | 曹休 ソウキュウ | 201 | $65 |
| 132 | 曹丕 ソウヒ | 202 | $66 |
| 127 | 曹彰 ソウショウ | 203 | $67 |
| 33 | 夏侯兰 カコウラン | 203 | $67 |
| 128 | 曹植 ソウショク | 204 | $68 |
| 133 | 曹熊 ソウユウ | 205 | $69 |
| 31 | 夏侯霸 カコウハ | 208 | $6C |
| 87 | 司马师 シバシ | 208 | $6C |
| 88 | 司马昭 シバショウ | 209 | $6D |
| 123 | 曹叡 ソウエイ | 210 | $6E |

## Pool 1 -> Country 3

| officer | name | join year | byte |
|---|---|---:|---:|
| 93 | 周瑜 シュウユ | 192 | $5C |
| 137 | 孙权 ソンケン | 197 | $61 |
| 139 | 孙翊 ソンヨク | 199 | $63 |
| 110 | 诸葛恪 ショカツカク | 210 | $6E |

## Pool 2 -> Country 4

| officer | name | join year | byte |
|---|---|---:|---:|
| 48 | 关平 カンペイ | 198 | $62 |
| 224 | 刘封 リュウホウ | 199 | $63 |
| 154 | 张苞 チョウホウ | 203 | $67 |
| 42 | 关兴 カンコウ | 204 | $68 |
| 43 | 关索 カンサク | 205 | $69 |
| 108 | 诸葛瞻 ショカツセン | 210 | $6E |

## Pool 3 -> Country 6

| officer | name | join year | byte |
|---|---|---:|---:|
| 180 | 马超 バチョウ | 193 | $5D |
| 179 | 马岱 バタイ | 194 | $5E |
| 181 | 马铁 バテツ | 195 | $5F |
| 176 | 马休 バキュウ | 197 | $61 |


* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* This program is free software under the GNU Affero General Public License
* version 3 only. There is no other license.
         TITLE 'HORNRES backward chaining'
HORNRES  CSECT
HORNRES  AMODE 64
HORNRES  RMODE ANY
* R1->query atom. R2->clause chain. R3->binding stack top.
* Returns 0 if derived, 28 if not. not/1 succeeds only when the inner atom is not derived.
         SAVE  (14,12)
         LARL  12,HORNRES
         USING HORNRES,12
         LTR   2,2
         BZ    HFAIL
         LG    4,0(1)
         L     5,8(1)
TRYCL    LTR   2,2
         BZ    HFAIL
         LG    6,0(2)
         LG    7,0(6)
         CGR   4,7
         BNE   NEXTC
         L     8,8(6)
         CR    5,8
         BNE   NEXTC
         LG    9,16(6)
         LG    10,16(1)
         CGR   9,10
         BNE   BIND0
         B     BODY
BIND0    LG    11,8(9)
         CHI   11,2
         BNE   NEXTC
         STG   10,8(3)
         STG   9,0(3)
BODY     LG    6,8(2)
         LTR   6,6
         BZ    HOK
NEXTC    LG    2,24(2)
         B     TRYCL
HOK      LGHI  15,0
         B     HRET
HFAIL    LGHI  15,28
HRET     RETURN (14,12)
         END   HORNRES

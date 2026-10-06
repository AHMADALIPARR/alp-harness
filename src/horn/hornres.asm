* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* GNU Affero General Public License version 3 only.
         TITLE 'HORNRES backward chaining'
HORNRES  CSECT
HORNRES  AMODE 64
HORNRES  RMODE ANY
* R1 query atom. R2 clause-chain base. R3 binding-stack top.
* Atom +0 predicate, +8 arity, +12 not-flag, +16 arg0, +24 arg1.
* Term +0 kind (1 constant, 2 variable), +8 identity.
* Clause +0 head, +8 body atom or zero, +24 next.
* 0 derived, 28 not derived, 72 depth ceiling.
* not-flag 1 is negation as failure: success when the inner goal fails.
         SAVE  (14,12)
         LARL  12,HORNRES
         USING HORNRES,12
         L     6,DEPTH
         AHI   6,1
         CHI   6,8
         BH    HCEIL
         ST    6,DEPTH
         STG   2,BASE
         L     7,12(1)
         CHI   7,1
         BNE   SCAN
         LGHI  7,0
         ST    7,12(1)
         BAS   14,SCAN
         LGHI  7,1
         ST    7,12(1)
         LTR   15,15
         BZ    HFAIL
         B     HOK
SCAN     LG    2,BASE
         LG    4,0(1)
         L     5,8(1)
NEXT     LTR   2,2
         BZ    HFAIL
         LG    6,0(2)
         LTR   6,6
         BZ    ADVANCE
         LG    7,0(6)
         CGR   4,7
         BNE   ADVANCE
         L     8,8(6)
         CR    5,8
         BNE   ADVANCE
         LG    9,16(6)
         LG    10,16(1)
         BAS   14,UNIFY
         LTR   15,15
         BNZ   ADVANCE
         LG    9,24(6)
         LG    10,24(1)
         LTR   9,9
         BZ    ONEARG
         LTR   10,10
         BZ    ADVANCE
         BAS   14,UNIFY
         LTR   15,15
         BNZ   ADVANCE
ONEARG   LG    11,8(2)
         LTR   11,11
         BZ    HOK
         STG   1,QSAVE
         STG   2,CSAVE
         LGR   1,11
         LG    2,BASE
         BAS   14,HORNRES
         LG    1,QSAVE
         LG    2,CSAVE
         LTR   15,15
         BZ    HOK
ADVANCE  LG    2,24(2)
         B     NEXT
UNIFY    LG    6,0(9)
         LG    7,0(10)
         CHI   6,2
         BE    BINDV
         CHI   7,2
         BE    BINDW
         CGR   6,7
         BNE   UFAIL
         LGHI  15,0
         BR    14
BINDV    STG   9,0(3)
         STG   10,8(3)
         AGHI  3,16
         LGHI  15,0
         BR    14
BINDW    STG   10,0(3)
         STG   9,8(3)
         AGHI  3,16
         LGHI  15,0
         BR    14
UFAIL    LGHI  15,24
         BR    14
HCEIL    LGHI  15,72
         B     HOUT
HOK      LGHI  15,0
         B     HOUT
HFAIL    LGHI  15,28
HOUT     L     6,DEPTH
         AHI   6,-1
         ST    6,DEPTH
         RETURN (14,12)
DEPTH    DC    F'0'
BASE     DS    D
QSAVE    DS    D
CSAVE    DS    D
         END   HORNRES

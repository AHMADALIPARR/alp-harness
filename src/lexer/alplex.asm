* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* This program is free software under the GNU Affero General Public License
* version 3 only. There is no other license.
         TITLE 'ALPLEX lexical scan'
ALPLEX   CSECT
ALPLEX   AMODE 64
ALPLEX   RMODE ANY
* Scan a source buffer into TOKEN records. R1->SRCBLK.
         SAVE  (14,12)
         LARL  12,ALPLEX
         USING ALPLEX,12
         LG    2,0(1)
         LG    3,8(1)
         LG    4,48(1)
         LG    5,56(1)
         LGHI  6,0
         LGHI  7,1
         LGHI  8,1
         LGHI  9,0
LEXLOOP  CGR   9,3
         BNL   LEXDONE
         LLC   10,0(2,9)
         CHI   10,C' '
         BE    LEXWS
         CHI   10,C':'
         BE    LEXRULE
         CHI   10,C'%'
         BE    LEXCMT
         LGHI  11,0
LEXID    CGR   9,3
         BNL   LEXIDEND
         LLC   10,0(2,9)
         CHI   10,C'A'
         BL    LEXIDEND
         CHI   10,C'z'
         BH    LEXIDEND
         AGHI  9,1
         AGHI  8,1
         AGHI  11,1
         B     LEXID
LEXIDEND CGR   6,5
         BNL   LEXFULL
         ST    11,20(4)
         STG   2,12(4)
         AGHI  6,1
         AGHI  4,32
         B     LEXLOOP
LEXWS    AGHI  9,1
         AGHI  8,1
         B     LEXLOOP
LEXRULE  AGHI  9,1
         LLC   10,0(2,9)
         CHI   10,C'-'
         BNE   LEXBAD
         AGHI  9,1
         AGHI  6,1
         B     LEXLOOP
LEXCMT   AGHI  9,1
         CGR   9,3
         BNL   LEXLOOP
         LLC   10,0(2,9)
         CHI   10,10
         BNE   LEXCMT
         AGHI  7,1
         LGHI  8,1
         B     LEXLOOP
LEXFULL  LGHI  15,68
         B     LEXRET
LEXBAD   LGHI  15,8
         B     LEXRET
LEXDONE  STG   6,64(1)
         LGHI  15,0
LEXRET   RETURN (14,12)
         END   ALPLEX

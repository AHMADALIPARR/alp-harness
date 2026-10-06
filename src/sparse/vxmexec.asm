* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* GNU Affero General Public License version 3 only.
         TITLE 'VXMEXEC semiring sparse product'
VXMEXEC  CSECT
VXMEXEC  AMODE 64
VXMEXEC  RMODE ANY
* R1 output vector, R2 input vector, R3 CSR matrix, R4 semiring.
* Semiring +8 is the additive identity. +0 and +16 are optional BAL
* routines (R0,R1 in, R0 out, R15 return code). Zero means min and add.
* CSR row pointers, column indices and values are doubleword arrays.
* Empty row stores the identity. RC 52 shape, 56 index, 60 overflow.
         SAVE  (14,12)
         LARL  12,VXMEXEC
         USING VXMEXEC,12
         STG   1,OUTV
         STG   2,INV
         STG   3,MATV
         STG   4,SEMV
         LG    5,0(3)
         LG    6,8(3)
         LG    7,0(2)
         CGR   6,7
         BNE   VBAD
         LG    8,32(3)
         LG    9,40(3)
         LG    10,48(3)
         LGHI  11,0
VROW     CGR   11,5
         BNL   VOK
         SLLG  0,11,3
         LG    2,0(8,0)
         LG    3,8(8,0)
         LG    4,SEMV
         LG    6,8(4)
VCOL     CGR   2,3
         BNL   VSTORE
         SLLG  0,2,3
         LG    7,0(9,0)
         LG    4,MATV
         LG    4,8(4)
         CGR   7,4
         BNL   VRANGE
         LG    0,0(10,0)
         LG    4,INV
         LG    1,16(4)
         SLLG  4,7,3
         LG    1,0(1,4)
         LG    4,SEMV
         LG    15,16(4)
         LTR   15,15
         BZ    MULADD
         BASR  14,15
         LTR   15,15
         BNZ   VRET
         B     ACCUM
MULADD   AGR   0,1
         BO    VOVER
ACCUM    LG    4,SEMV
         LG    15,0(4)
         LTR   15,15
         BZ    ACCMIN
         LGR   1,6
         BASR  14,15
         LTR   15,15
         BNZ   VRET
         LGR   6,0
         B     VNEXT
ACCMIN   CGR   0,6
         BNL   VNEXT
         LGR   6,0
VNEXT    AGHI  2,1
         B     VCOL
VSTORE   LG    4,OUTV
         LG    7,32(4)
         SLLG  0,11,3
         STG   6,0(7,0)
         AGHI  11,1
         B     VROW
VRANGE   LGHI  15,56
         B     VRET
VOVER    LGHI  15,60
         B     VRET
VBAD     LGHI  15,52
         B     VRET
VOK      LGHI  15,0
VRET     RETURN (14,12)
OUTV     DS    D
INV      DS    D
MATV     DS    D
SEMV     DS    D
         END   VXMEXEC

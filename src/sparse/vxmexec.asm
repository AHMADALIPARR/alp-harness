* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* This program is free software under the GNU Affero General Public License
* version 3 only. There is no other license.
         TITLE 'VXMEXEC semiring sparse product'
VXMEXEC  CSECT
VXMEXEC  AMODE 64
VXMEXEC  RMODE ANY
* R1->output vector, R2->input vector, R3->CSR matrix, R4->semiring.
* min-plus: combine is 64-bit add, accumulate is signed minimum.
         SAVE  (14,12)
         LARL  12,VXMEXEC
         USING VXMEXEC,12
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
         LG    0,0(8,11)
         LG    1,8(8,11)
         LG    13,8(4)
VCOL     CGR   0,1
         BNL   VSTORE
         LG    14,0(9,0)
         CGR   14,6
         BNL   VRANGE
         LG    15,0(10,0)
         LG    7,16(2)
         LG    7,0(7,14)
         AGR   15,7
         BO    VOVER
         CGR   15,13
         BNL   VSKIP
         LGR   13,15
VSKIP    AGHI  0,1
         B     VCOL
VSTORE   LG    7,32(1)
         STG   13,0(7,11)
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
         END   VXMEXEC

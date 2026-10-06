* SPDX-License-Identifier: AGPL-3.0-only
* Copyright (C) 2026 Ahmad Ali Parr
* GNU Affero General Public License version 3 only.
         TITLE 'REQVXM REQUIRE gate in front of VXM'
REQVXM   CSECT
REQVXM   AMODE 64
REQVXM   RMODE ANY
* R1 addresses the gate block:
*   +0  query atom
*   +8  clause-chain base
*   +16 binding-stack top
*   +24 output vector
*   +32 input vector
*   +40 CSR matrix
*   +48 semiring
* HORNRES must return 0 before VXMEXEC is entered.
* A resolution failure returns 32 and does not write the output vector.
         EXTRN HORNRES
         EXTRN VXMEXEC
         SAVE  (14,12)
         LARL  12,REQVXM
         USING REQVXM,12
         STG   1,BLOCK
         LG    2,0(1)
         LG    3,8(1)
         LG    4,16(1)
         LGR   1,2
         LGR   2,3
         LGR   3,4
         L     15,=V(HORNRES)
         BASR  14,15
         LTR   15,15
         BNZ   DENY
         LG    1,BLOCK
         LG    2,32(1)
         LG    3,40(1)
         LG    4,48(1)
         LG    1,24(1)
         L     15,=V(VXMEXEC)
         BASR  14,15
         B     ROUT
DENY     LGHI  15,32
ROUT     RETURN (14,12)
BLOCK    DS    D
         LTORG
         END   REQVXM

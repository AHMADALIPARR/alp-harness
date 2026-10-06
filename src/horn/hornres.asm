         TITLE 'HORNRES backward chaining'
HORNRES  CSECT
HORNRES  AMODE 64
HORNRES  RMODE ANY
* R1->query atom. R2->clause chain. R3->binding stack top.
* Returns 0 if the ground query is derived, 28 if it is not.
* not/1 succeeds only when the inner atom is not derived.
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
         LG    10,0(1)
         LG    10,16(10)
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
         LG    7,0(6)
         CHI   7,1
         BNE   RECUR
         LGHI  15,0
         BASR  14,15
         LTR   15,15
         BZ    NEXTC
         B     HOK
RECUR    LGHI  15,0
         BASR  14,15
         LTR   15,15
         BNZ   NEXTC
HOK      LGHI  15,0
         B     HRET
NEXTC    LG    2,24(2)
         B     TRYCL
HFAIL    LGHI  15,28
HRET     RETURN (14,12)
         END   HORNRES

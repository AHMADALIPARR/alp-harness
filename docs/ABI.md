# ABI

AMODE 64, z/Architecture. One convention.

On entry R1 addresses a doubleword parameter list, R13 addresses the caller save area, R14 is the return address, and R15 is the entry point. The callee stores R14-R12 at offset 8 of the caller save area, obtains a 144-byte area, chains it, and points R13 at it. R12 is the module base after entry. R6-R11 are preserved. R0 and R2-R5 are work registers. On return R15 is the repository return code.

Return codes: 0 success, 4 invalid argument, 8 lexical, 12 syntax, 16 malformed Horn, 20 malformed ALP, 24 unification failure, 28 resolution failure, 32 REQUIRE failure, 36 unknown operator, 40 unknown monoid, 44 unknown semiring, 48 bad vector, 52 bad matrix, 56 bounds, 60 overflow, 64 divide by zero, 68 storage, 72 step ceiling, 76 invariant.

Signed binary integers are 64 bits. A REQUIRE succeeds only when backward chaining derives the ground atom. `not` is negation as failure. A VXM result is the sparse vector written by the semiring kernel.

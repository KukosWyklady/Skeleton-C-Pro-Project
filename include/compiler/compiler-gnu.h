#ifndef COMPILER_GNU_H
#define COMPILER_GNU_H

#ifndef COMPILER_H
#error "Never include <compiler/compiler-gnu.h> directly, use <compiler/compiler.h> instead."
#endif

#define MIN(a, b) \
    __extension__ \
    ({ \
        __typeof__(a) __a = (a); \
        __typeof__(b) __b = (b); \
        (void)(&__a - &__b); \
       __a <= __b ? __a : __b; \
    })

#endif
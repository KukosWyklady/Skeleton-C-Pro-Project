#ifndef COMPILER_GCC_H
#define COMPILER_GCC_H

#ifndef COMPILER_H
#error "Never include <compiler/compiler-gcc.h> directly, use <compiler/compiler.h> instead."
#endif

#define EXPECT(cond, val) __builtin_expect(cond, val)

#endif

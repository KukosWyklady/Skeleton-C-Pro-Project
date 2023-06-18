#ifndef COMPILER_CLANG_H
#define COMPILER_CLANG_H

#ifndef COMPILER_H
#error "Never include <compiler/compiler-clang.h> directly, use <compiler/compiler.h> instead."
#endif

#define EXPECT(cond, val) __builtin_expect(cond, val)

#endif

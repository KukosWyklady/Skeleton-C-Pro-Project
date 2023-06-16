#ifndef COMPILER_UNKNOWN_H
#define COMPILER_UNKNOWN_H

#ifndef COMPILER_H
#error "Never include <compiler/compiler-unknown.h> directly, use <compiler/compiler.h> instead."
#endif

#define EXPECT(cond, val) ((cond) == (val))

#endif
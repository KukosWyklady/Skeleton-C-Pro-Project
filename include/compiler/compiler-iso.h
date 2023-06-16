#ifndef COMPILER_ISO_H
#define COMPILER_ISO_H

#ifndef COMPILER_H
#error "Never include <compiler/compiler-iso.h> directly, use <compiler/compiler.h> instead."
#endif

#define MIN(a, b) ((a) <= (b) ? (a) : (b))

#endif
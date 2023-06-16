#ifndef COMPILER_H
#define COMPILER_H

#include "compiler-detect.h"

/* include compiler dependend defines  */
#ifdef COMPILER_CLANG
#include "compiler-clang.h"
#elif defined(COMPILER_GCC)
#include "compiler-gcc.h"
#elif defined(COMPILER_UNKNOWN)
#include "compiler-unknown.h"
#endif

#ifdef COMPILER_GNUC
#include "compiler-gnu.h"
#else
#include "compiler-iso.h"
#endif

#endif
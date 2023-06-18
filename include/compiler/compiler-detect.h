#ifndef COMPILER_DETECT_H
#define COMPILER_DETECT_H

/* __GNUC__ is a gcc and gnuc define, so here order is important */
#ifdef __clang__

/* clang maybe with some gnu */
#define COMPILER_CLANG
#define COMPILER_MAJOR_VERSION __clang_major__
#define COMPILER_MINOR_VERSION __clang_minor__

#ifdef __GNUC__
#define COMPILER_GNUC
#endif /* #ifdef __GNUC__ */

#elif defined(__GNUC__)

/* gcc some for sure gnu */
#define COMPILER_GCC
#define COMPILER_GNUC
#define COMPILER_MAJOR_VERSION __GNUC__
#define COMPILER_MINOR_VERSION __GNUC_MINOR__

#else

/* unknown compiler maybe with gnu */
#define COMPILER_UNKNOWN
#define COMPILER_MAJOR_VERSION 0
#define COMPILER_MINOR_VERSION 0

#ifdef __GNUC__
#define COMPILER_GNUC
#endif /* #ifdef __GNUC__ */

#endif /* #ifdef __clang__ and #elif defined(__GNUC__) */

#endif /* include guard */

#ifndef FOO_H
#define FOO_H

#include <error.h>
#include <stddef.h>

error_t foo_alloc_buffer(size_t num_entries, int** out_allocated_buf);
error_t foo_init_buffer(int buf[], size_t num_entries, int start, int add_value);
error_t foo_dealloc_buffer(int buf[]);

#endif
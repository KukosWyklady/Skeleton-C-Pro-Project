#include <foo.h>
#include <logger.h>
#include <bar.h>

#include <stdlib.h>

static void foo_static_fill_buffer(int buf[const], const size_t num_entries, const int start_value, const int add_value)
{
    for (size_t i = 0; i < num_entries; ++i)
    {
        buf[i] = start_value + ((int)i * add_value);
    }
}

error_t foo_alloc_buffer(const size_t num_entries, int** const out_allocated_buf)
{
    if (num_entries == 0)
    {
        LOG_ERROR("num_entries shoule be >0, got %zu\n", num_entries);
        return ERROR_INVALID_ARGUMENT;
    }

    if (out_allocated_buf == NULL)
    {
        LOG_ERROR("out_allovated_buf should be not NULL, got %p\n", out_allocated_buf);
        return ERROR_INVALID_ARGUMENT;
    }

    *out_allocated_buf = malloc(sizeof(**out_allocated_buf) * num_entries);
    if (*out_allocated_buf == NULL)
    {
        LOG_ERROR("Malloc error on size %zu\n", sizeof(**out_allocated_buf) * num_entries);
        return ERROR_BAD_ALLOC;
    }

    return ERROR_NO_ERROR;
}


error_t foo_init_buffer(int buf[const], const size_t num_entries, const int start_value, const int add_value)
{
    if (buf == NULL)
    {
        LOG_ERROR("buf should be not NULL, got %p\n", buf);
        return ERROR_INVALID_ARGUMENT;
    }

    if (num_entries == 0)
    {
        LOG_ERROR("num_entries shoule be >0, got %zu\n", num_entries);
        return ERROR_INVALID_ARGUMENT;
    }

    register const int fill_start_value = start_value < 0 ? bar_magic_number() : start_value;
    foo_static_fill_buffer(buf, num_entries, fill_start_value, add_value);

    return ERROR_NO_ERROR;
}

error_t foo_dealloc_buffer(int buf[const])
{
    if (buf == NULL)
    {
        LOG_ERROR("buf should be not NULL, got %p\n", buf);
        return ERROR_INVALID_ARGUMENT;
    }

    free(buf);

    return ERROR_NO_ERROR;
}

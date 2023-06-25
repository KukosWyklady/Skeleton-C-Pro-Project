#include <criterion/criterion.h>

// MOCK ALL NEEDED FUNCTIONS

#include <bar.h>
#include <stdlib.h>

#include <foo.h>

static struct
{
    int magic_number;
} mock_bar_magic_params;

static inline int mock_bar_magic_number(void)
{
    return mock_bar_magic_params.magic_number;
}

#define bar_magic_number() mock_bar_magic_number()

static struct
{
    bool malloc_null;
} mock_malloc_params;

static inline void* mock_malloc(size_t size)
{
    void* mem = NULL;
    if (!mock_malloc_params.malloc_null)
        mem = malloc(size);

    return mem;
}

#define malloc(size) mock_malloc(size)

#include <foo.c>

Test(foo, bar_magic)
{
    {
        mock_bar_magic_params.magic_number = 11;
        register const size_t num_entries = 10;
        register const int start_value = -1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, num_entries, start_value, add_value) == ERROR_NO_ERROR);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == mock_bar_magic_params.magic_number + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }


    {
        mock_bar_magic_params.magic_number = 17;
        register const size_t num_entries = 10;
        register const int start_value = -1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, num_entries, start_value, add_value) == ERROR_NO_ERROR);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == mock_bar_magic_params.magic_number + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }

    {
        mock_bar_magic_params.magic_number = -5;
        register const size_t num_entries = 10;
        register const int start_value = -1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, num_entries, start_value, add_value) == ERROR_NO_ERROR);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == mock_bar_magic_params.magic_number + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }
}

Test(foo, alloc_buffer_with_malloc_error)
{
    {
        mock_malloc_params.malloc_null = true;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(10, &buf) == ERROR_BAD_ALLOC);
        cr_assert(buf == NULL);
    }
}
#include <criterion/criterion.h>

#include <foo.c>
#include <bar.h>

Test(foo, interface)
{
    {
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(10, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, 10, 1, 2) == ERROR_NO_ERROR);
        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }
}

Test(foo, alloc_buffer)
{
    {
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(0, &buf) == ERROR_INVALID_ARGUMENT);
        cr_assert(foo_alloc_buffer(10, NULL) == ERROR_INVALID_ARGUMENT);
        cr_assert(foo_alloc_buffer(0, NULL) == ERROR_INVALID_ARGUMENT);
    }

    {
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(10, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }
}

Test(foo, dealloc_buffer)
{
    {
        cr_assert(foo_dealloc_buffer(NULL) == ERROR_INVALID_ARGUMENT);
    }
}

Test(foo, static_fill_buffer)
{
    {
        register const size_t num_entries = 10;
        register const int start_value = 1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        foo_static_fill_buffer(buf, num_entries, start_value, add_value);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == start_value + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }
}

Test(foo, init_buffer)
{
    {
        int* const buf = NULL;
        cr_assert(foo_init_buffer(buf, 0, 1, 2) == ERROR_INVALID_ARGUMENT);
        cr_assert(foo_init_buffer(NULL, 10, 1, 2) == ERROR_INVALID_ARGUMENT);
        cr_assert(foo_init_buffer(NULL, 0, 1, 2) == ERROR_INVALID_ARGUMENT);
    }

    {
        register const size_t num_entries = 10;
        register const int start_value = 1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, num_entries, start_value, add_value) == ERROR_NO_ERROR);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == start_value + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }

    {
        register const size_t num_entries = 10;
        register const int start_value = -1;
        register const int add_value = 2;
        int* buf = NULL;
        cr_assert(foo_alloc_buffer(num_entries, &buf) == ERROR_NO_ERROR);
        cr_assert(buf != NULL);

        cr_assert(foo_init_buffer(buf, num_entries, start_value, add_value) == ERROR_NO_ERROR);
        for (size_t i = 0; i < num_entries; ++i)
            cr_assert(buf[i] == bar_magic_number() + (int)i * add_value);

        cr_assert(foo_dealloc_buffer(buf) == ERROR_NO_ERROR);
    }
}
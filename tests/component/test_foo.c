#include <criterion/criterion.h>

#include <foo.h>
#include <bar.h>

Test(foo, capacity)
{
    {
        register const size_t num_entries = 100 * 1000 * 1000;
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
        register const size_t num_entries = 100 * 1000 * 1000;
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
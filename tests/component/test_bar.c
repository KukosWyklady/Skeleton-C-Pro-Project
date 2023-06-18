#include <criterion/criterion.h>

#include <bar.h>

Test(bar, magic_number)
{
    {
        cr_assert(bar_magic_number() == 41);
    }
}

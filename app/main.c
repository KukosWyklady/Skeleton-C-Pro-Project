#include <stdio.h>

#include <compiler/compiler.h>
#include <error.h>
#include <logger.h>

#include <foo.h>


int main(void)
{
    printf("MAIN\n");

    logger_initConsoleLogger(stdout);

    remove("./log.txt");
    logger_initFileLogger("./log.txt", 0, 0);
    logger_setLevel(LogLevel_DEBUG);

    LOG_TRACE("trace %s", "");
    LOG_DEBUG("degug %s", "");
    LOG_INFO("info %s", "");
    LOG_WARN("warn %s", "");
    LOG_ERROR("error %s", "");
    LOG_FATAL("fatal %s", "");

    if (EXPECT(MIN(2, 3), 2))
    {
        printf("EXPECTED 2\n");
    }

    const error_t err = ERROR_INVALID_ARGUMENT;
    if (err == ERROR_INVALID_ARGUMENT)
    {
        printf("Invalid argument error test\n");
    }

    enum {buffer_size = 100};
    int* buf;
    if (foo_alloc_buffer(buffer_size, &buf) != ERROR_NO_ERROR)
    {
        printf("ERROR\n");
    }

    if (foo_init_buffer(buf, buffer_size, 1, 2) != ERROR_NO_ERROR)
    {
        printf("ERROR\n");
    }

    if (foo_dealloc_buffer(buf) != ERROR_NO_ERROR)
    {
        printf("ERROR\n");
    }

    return 0;
}

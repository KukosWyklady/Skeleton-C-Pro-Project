#include <stdio.h>

#include <compiler/compiler.h>
#include <logger.h>

int main(void)
{
    printf("MAIN\n");

    logger_initConsoleLogger(stdout);

    remove("./log.txt");
    logger_initFileLogger("./log.txt", 0, 0);
    logger_setLevel(LogLevel_DEBUG);

    LOG_TRACE("trace");
    LOG_DEBUG("degug");
    LOG_INFO("info");
    LOG_WARN("warn");
    LOG_ERROR("error");
    LOG_FATAL("fatal");

    if (EXPECT(MIN(2, 3), 2))
        printf("EXPECTED 2\n");

    return 0;
}
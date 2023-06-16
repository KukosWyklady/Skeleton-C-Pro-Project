#include <stdio.h>

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

    return 0;
}
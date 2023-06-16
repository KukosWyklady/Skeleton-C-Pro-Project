all:
	clang -L./libs/c-logger/lib/ -I./libs/c-logger/include/ ./app/*.c -llogger -Wl,-R./libs/c-logger/lib/
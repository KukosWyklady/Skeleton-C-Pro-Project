all:
	clang -L./libs/c-logger/lib/ -I./libs/c-logger/include/ -I./include/ ./app/*.c -llogger -Wl,-R./libs/c-logger/lib/ -o main.out
	clang -L./libs/criterion/usr/local/lib/x86_64-linux-gnu -I./libs/criterion/usr/local/include/ ./tests/unit/*.c -lcriterion -Wl,-R./libs/criterion/usr/local/lib/x86_64-linux-gnu -o unit_tests.out
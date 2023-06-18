all:
	clang -L./libs/c-logger/lib/ -I./libs/c-logger/include/ -I./include/ ./app/*.c ./src/*.c -llogger -Wl,-R./libs/c-logger/lib/ -o main.out
	clang -Wl,-allow-multiple-definition -L./libs/c-logger/lib/ -I./libs/c-logger/include/ -L./libs/criterion/usr/local/lib/x86_64-linux-gnu -I./libs/criterion/usr/local/include/ -I./include/ -I./src/ ./src/*.c ./tests/unit/*.c -llogger -Wl,-R./libs/c-logger/lib/ -lcriterion -Wl,-R./libs/criterion/usr/local/lib/x86_64-linux-gnu -o unit_tests.out
	clang --analyze -Xanalyzer -analyzer-output=text -I./libs/c-logger/include/ -I./include/ -I./libs/criterion/usr/local/include/ -I./src ./app/*.c ./src/*.c ./tests/unit/*.c

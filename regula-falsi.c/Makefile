src      = ./regula-falsi.c
bin      = ./regula-falsi.out
CFLAGS  := -g -Wall -O3
LDFLAGS := -lm

all: $(bin) test

$(bin): $(src)
	$(CC) $^ -o $@ $(LDFLAGS)

test:
	@$(bin)

clean:
	@$(RM) $(bin)

.PHONY: all clean test run

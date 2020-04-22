prefix ?= /usr/local
bindir = $(prefix)/bin
binary ?= spasibo
release_binary?=.build/release/Spasibo

build:
	swift build -c release --disable-sandbox

install: build
	mkdir -p $(bindir)
	cp -f $(release_binary) $(bindir)/$(binary)

uninstall:
	rm -rf "$(bindir)/$(binary)"

clean:
	rm -rf .build

.PHONY: build install uninstall clean
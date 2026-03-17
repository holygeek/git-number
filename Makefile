prefix = /usr/local
testdir = t/testoutput

BINARY = git-number

bindir = $(prefix)/bin

all: build test

build:
	go build -o $(BINARY)

install: build
	install -d -m 0755 $(bindir)
	install -m 0755 $(BINARY) $(bindir)

uninstall:
	$(RM) $(bindir)/$(BINARY)

test: build
	@prove t
	
clean:
	$(RM) -r $(testdir) $(BINARY)

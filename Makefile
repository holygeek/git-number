prefix = /usr/local
testdir = t/testoutput

BINARY = git-number

bindir = $(prefix)/bin

all: build tests

build:
	go build -o $(BINARY)

install: build
	install -d -m 0755 $(bindir)
	install -m 0755 $(BINARY) $(bindir)

uninstall:
	$(RM) $(bindir)/$(BINARY)

test: build
	@prove t
	
tests: build
	@prove tests

clean:
	$(RM) -r $(testdir) $(BINARY)

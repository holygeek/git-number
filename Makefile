prefix = /usr/local
testdir = t/testoutput

SCRIPTS = git-number git-id git-list

bindir = $(prefix)/bin

all: test clean

install:
	install -d -m 0755 $(bindir)
	install -m 0755 $(SCRIPTS) $(bindir)

test:
	@prove t
	
clean:
	$(RM) -r $(testdir)

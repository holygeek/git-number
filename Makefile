prefix = /usr/local
testdir = t/testoutput

SCRIPTS = git-number git-id git-list

bindir = $(prefix)/bin
mandir = $(prefix)/share/man/man1
MANPAGES = $(addsuffix .1,$(SCRIPTS))

all: test clean

install: install-man
	install -d -m 0755 $(bindir)
	install -m 0755 $(SCRIPTS) $(bindir)

git-number.1: git-number
	pod2man $< $@
git-id.1: git-number
	pod2man $< $@
git-list.1: git-number
	pod2man $< $@

install-man: $(MANPAGES)
	install -d -m 0755 $(mandir)
	for s in $(MANPAGES); do \
		install -m 0644 $$s $(mandir);\
	done

uninstall:
	cd $(prefix)/bin && $(RM) $(SCRIPTS)
	cd $(mandir) && $(RM) $(MANPAGES)

test:
	@prove t
	
clean:
	$(RM) -r $(testdir) $(MANPAGES)

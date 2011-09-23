testdir = t/testoutput

all: test clean

test:
	@prove t
	
clean:
	@$(RM) -r $(testdir)

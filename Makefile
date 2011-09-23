testdir = t/testoutput

test:
	prove t
	
clean:
	$(RM) -r $(testdir)

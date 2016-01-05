### git-number ###

git-number is a perl script that increases my command-line git productivity
(with some help from another two perl scripts).

## Usage Examples ##

Here's how it increase my productivity (it might increase yours too):

    $ alias gn='git number --column'
    # See item 4 in the Caveat section on --column
    $ alias ga='git number add'

    $ gn
    # On branch master
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #1      .README.swp
    #2      README
    $

Does the output look familiar? Notice the numbers before the filenames? Those
are their ids.

If you prefer the short status format then you can use the -s option.  This
will run ``git status`` with the ``--short`` option.

    $ git number -s
    1 ?? .README.swp
    2 ?? README


Now look at this:

    $ ga 2
    git add  README  # <- It does this in the background

    $ gn
    # On branch master
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #1      new file:   README
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #2      .README.swp

When run without arguments, 'git number' runs 'git status' and attach a unique
number for each line of filename printed by 'git status', and it will 'remember'
this number-to-filename association. When run with arguments, like this:

    $ git number <any git command> [one or more numbers or git options/args]

'git number' will run that &lt;any git command&gt; and subtitute all the numbers
to their equivalent filenames. Non-numeric argument are passed intact to git.

It accepts multiple args and ranges too:

    $ ga 2-4 6 10

Which is the same as writing

    $ ga 2 3 4 6 10

You can also ask git-number to run arbitrary command instead of git on the
given arguments using the -c option:

    $ gn -c rm 1

This will run the command "rm README"

The kind of fun that this gives you include the following:

    $ alias vn='git number -c vi'
    $ vn 1

This will run "vi README"

## What's included ##

1. git-number: Show or operate on files by their 'ids'
2. git-list: List filenames from given ids
3. git-id: Generate and show the file ids

    for example to show the second file run:

        $ git list 2

    or to show the first three files, and the  9th and 13th:

        $ git list 1-3 9 13

## What's not included ##

Batteries.

## How it works ##

'git-id' is a perl script that does two things:

1. Runs "git status" and inserts a number before each file reported by "git
   status"
2. Show and save a copy of the output to a file (.git/gitids.txt)

(If you're pedantic then it does four things)

'git-list' is a perl script that converts numbers and ranges to their
equivalent filenames from the previous run of 'git-id'.

'git-number' uses 'git-list' to convert all its numbers and ranges arguments to
filenames and passes them down to git.

## Caveat ##

1. <strike>For a file that is marked as conflicting, the ansi closing color escape
   sequence printed by git comes after the final newline, which breaks this
   script a little</strike>. This seems to be fixed in latest git.

2. git-number depends on the output of git-status, which is a porcelain. Caveat emptor.

3. It does not work for renames:

 <pre>
    $ git mv a.txt b.txt
    $ gn
    # On branch b
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #1      renamed:    a.txt -> b.txt
    #
    $ gn reset 1  # this will NOT do what you want it to do!
 </pre>

4.  Since git 1.8.4.1, git-status now defaults to showing the untracked files
    in columnar listing (git-number doesn't).  To choose the columnar listing,
    pass the --column argument to git-number.  git-number makes the assumption
    that the files do not have spaces in their names and assign numeric ids to
    the files by splitting the columnar output using one or more spaces as the
    delimiter.

    TLDR: git-number is not reliable in columnar untracked files
    listing if your files have spaces in their names.

5.  In --column=dense mode, there may be no spaces between the filenames from
    the previous column and the numbers for the files in the next column.  Do
    not be alarmed - the numbers work just fine.

I'm sure there are a few more. Send me a patch :)

## Installation ##

Copy (or make a symbolic link to) 'git-number', 'git-list', 'git-id' into your
$HOME/bin directory, or wherever you prefer to put them.

## Installation on Windows ##

Add folder where 'git-number', 'git-list', 'git-id' are located to your $PATH variable and restart git console.

## See also ##

[scm_breeze](https://github.com/ndbroadbent/scm_breeze) by Nathan Broadbent -  similar in spirit with git-number, has more features, requires either bash or zsh.

### git-number ###

`git-number` is a program that increases my command-line git productivity.
The original version was written in Perl. The Perl implementation has
been preserved in the `perl` branch and will no longer be updated.
The current version is written in Go.
## Usage Examples ##

Here's how it increases my productivity (and might increase yours, too):

Initial setup
```console
# set up `git id` and `git list` as shortcuts for `git number id` and `git number list`
git number --set-git-alias

# set shell aliases
alias g='git number --column'
alias ga='git number add'
alias gd='git number diff'
alias ge='git number -c'
# See item 4 in the Caveat section on --column
```

Use it
```
$ g
# On branch master

# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#1      .README.swp
#2      README
$
```

Does the output look familiar? Notice the numbers before the filenames? Those
are their ids.

If you prefer the short status format then you can use the `-s` option. This
will run `git status` with the `--short` option.

```console
$ git number -s
1 ?? .README.swp
2 ?? README
```

Now look at this:

```console
$ ga 2
git add README  # <- It does this in the background

$ g
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
```

When run without arguments, `git number` runs `git status` and attach a unique
number for each line of filename printed by `git status`, and it will 'remember'
this number-to-filename association. When run with arguments, like this:

```console
$ git number <any git command> [one or more numbers or git options/args]
```

`git number` will run that &lt;any git command&gt; and subtitute all the numbers
to their equivalent filenames. Non-numeric argument are passed intact to git.

It accepts multiple args and ranges too:

```console
$ ga 2-4 6 10
```

Which is the same as writing

```console
$ ga 2 3 4 6 10
```

You can also ask `git-number` to run arbitrary command instead of git on the
given arguments using the `-c` option:

```console
$ g -c rm 1
```

This will run the command `rm README`

The kind of fun that this gives you include the following:

```console
$ alias vn='git number -c vi'
$ vn 1
```

This will run `vi README`

## Subcommands ##

1. `git number id`: Runs `git status` and assigns numeric IDs to filenames.
   (This is what runs when `git number` is called without arguments).
2. `git number list`: Lists filenames associated with the given IDs.

    For example to show the second file run:

    ```console
    $ git number list 2
    ```

    or to show the first three files, and the 9th and 13th:

    ```console
    $ git number list 1-3 9 13
    ```

## What's not included ##

Batteries.

## How it works ##

When you run `git number` (or `git number id`), it:
1. Runs `git status` and inserts a number before each file reported.
2. Saves a copy of the output and metadata to `.git/gitids.go.txt`.

When you run a command through `git number`, it uses the information in
`.git/gitids.go.txt` to convert numbers and ranges back to their equivalent filenames.

## Caveat ##

1. <strike>For a file that is marked as conflicting, the ansi closing color escape
   sequence printed by git comes after the final newline, which breaks this
   script a little</strike>. This seems to be fixed in latest git.

2. git-number depends on the output of git-status, which is a porcelain. Caveat emptor.

3. It does not work for renames:

    ```console
    $ git mv a.txt b.txt
    $ g
    # On branch b
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #1      renamed:    a.txt -> b.txt
    #
    $ g reset 1  # this will NOT do what you want it to do!
    ```

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

1. Install it:
   ```console
   $ go install github.com/holygeek/git-number@latest
   ```
   Make sure `$GOPATH/bin` (usually `$HOME/go/bin`) is in your `$PATH`.

2. Set up git aliases (optional but recommended):
   ```console
   $ git number --set-git-alias
   ```
   This sets up `git id` and `git list` as shortcuts for `git number id` and `git number list`.

## See also ##

[scm_breeze](https://github.com/ndbroadbent/scm_breeze) by Nathan
Broadbent - similar in spirit with git-number, has more features,
requires either bash or zsh.

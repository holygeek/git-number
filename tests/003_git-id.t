#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 3

setup

# Test: git number id on virgin git init
(
    cd "$workdir"
    git init -q
)
got=$(cd "$workdir" && git number id --color=never 2>&1)
if [[ "$got" =~ "On branch master" && "$got" =~ "nothing to commit" ]]; then
    ok "git number id on virgin git init"
else
    not_ok "git number id on virgin git init" "$got" "On branch master ... nothing to commit"
fi

# Test: git number id - untracked files
(
    cd "$workdir"
    echo a > a
    echo b > b
)
got=$(cd "$workdir" && git number id --color=never 2>&1)
if [[ "$got" =~ "Untracked files:" && "$got" =~ "1	a" && "$got" =~ "2	b" ]]; then
    ok "git number id - untracked files"
else
    not_ok "git number id - untracked files" "$got" "Untracked files: ... 1 a ... 2 b"
fi

# Test: git number id - added and untracked files
(
    cd "$workdir"
    git add a
)
got=$(cd "$workdir" && git number id --color=never 2>&1)
if [[ "$got" =~ "Changes to be committed:" && "$got" =~ "1	new file:   a" && "$got" =~ "Untracked files:" && "$got" =~ "2	b" ]]; then
    ok "git number id - added and untracked files"
else
    not_ok "git number id - added and untracked files" "$got" "Changes to be committed: ... 1 new file: a ... Untracked files: ... 2 b"
fi

test_done

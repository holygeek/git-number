#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 2

setup

# Test: git number with custom status color
(
    cd "$workdir"
    echo 'one' > one.txt
    git init -q
    git add .
    git config color.status.header 'normal dim'
)
got=$(cd "$workdir" && git number --color=always | sed 's/\x1b\[[0-9;]*m//g')
if [[ "$got" =~ "1	new file:   one.txt" ]]; then
    ok "git number with custom status color"
else
    not_ok "git number with custom status color" "$got" "1 new file: one.txt"
fi

# Test: git number with untracked in bold red
(
    cd "$workdir"
    echo 'untracked1' > untracked1.txt
    git config color.status.untracked 'red bold'
    git number --color=always > /dev/null
)
got=$(cd "$workdir" && git list 2)
assert_eq "$got" "untracked1.txt" "git number with untracked in bold red"

test_done

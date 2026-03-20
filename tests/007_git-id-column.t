#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 2

setup

# Test: git id --column
(
    cd "$workdir"
    git init -q
    echo a > one.txt
    echo b > two.txt
)

got=$(cd "$workdir" && git id --color=never --column=always)
# Match 1 one.txt and 2 two.txt on the same line
if [[ "$got" =~ "1	one.txt" && "$got" =~ "2  two.txt" ]]; then
    ok "git id --column"
else
    not_ok "git id --column" "$got" "1 one.txt ... 2 two.txt"
fi

got=$(cd "$workdir" && git list 2)
if [[ "$got" = "two.txt" ]]; then
    ok "'git list 2' returns two.txt"
else
    not_ok "'git list 2' with 'git id --column=always' failed" "$got" "two.txt"
fi

test_done

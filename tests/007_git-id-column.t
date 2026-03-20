#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 4

setup

# Test: git number id --column
(
    cd "$workdir"
    git init -q
    echo a > one.txt
    echo b > two.txt
)

# Without color
got=$(cd "$workdir" && git number id --color=never --column=always)
# Match 1 one.txt and 2 two.txt on the same line
if [[ "$got" =~ "1	one.txt" && "$got" =~ "2  two.txt" ]]; then
    ok "git number id --column"
else
    not_ok "git number id --column" "$got" "1 one.txt ... 2 two.txt"
fi

got=$(cd "$workdir" && git number list 2)
if [[ "$got" = "two.txt" ]]; then
    ok "'git number list 2' returns two.txt"
else
    not_ok "'git number list 2' with 'git number id --column=always' failed" "$got" "two.txt"
fi

# With color - get one.txt
got=$(cd "$workdir" && git number id --color=always --column=always >/dev/null && git number list 1)
if [[ "$got" = "one.txt" ]]; then
    ok "git number list 1"
else
    not_ok "git number list 1" "$got" "one.txt"
fi

# With color - get two.txt
got=$(cd "$workdir" && git number id --color=always --column=always >/dev/null && git number list 2)
if [[ "$got" = "two.txt" ]]; then
    ok "git number list 2"
else
    not_ok "git number list 2" "$got" "two.txt"
fi


test_done

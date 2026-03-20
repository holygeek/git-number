#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 1

setup

# Test: git id --column
(
    cd "$workdir"
    git init -q
    echo a > one.txt
    echo b > two.txt
)

# Only run if git column is supported
if echo a | git column > /dev/null 2>&1; then
    got=$(cd "$workdir" && git id --color=never --column=always)
    # Match 1 one.txt and 2 two.txt on the same line
    if [[ "$got" =~ "1	one.txt" && "$got" =~ "2  two.txt" ]]; then
        ok "git id --column"
    else
        not_ok "git id --column" "$got" "1 one.txt ... 2 two.txt"
    fi
else
    echo "ok $test_count - skip: git status does not support --column"
fi

test_done

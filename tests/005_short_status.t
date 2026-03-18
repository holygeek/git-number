#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 2

setup

# Test: Show status in short format
(
    cd "$workdir"
    echo 'one' > one.txt
    git init -q
    git add .
)
got=$(cd "$workdir" && git number --color=never -s)
assert_eq "$got" "1 A  one.txt" "Show status in short format"

# Test: git list: Handle short status
got=$(cd "$workdir" && git list 1)
assert_eq "$got" "one.txt" "git list: Handle short status"

test_done

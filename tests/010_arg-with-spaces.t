#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 1

setup

# Test: argument with spaces
(
    cd "$workdir"
    mkdir tmp
    cd tmp
    git init -q
    echo a > test.txt
    git add test.txt
    git number commit -m "Initial commit"
)

got=$(cd "$workdir/tmp" && git log -1 --format=%s)
assert_eq "$got" "Initial commit" "argument with spaces"

test_done

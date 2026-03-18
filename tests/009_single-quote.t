#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 1

setup

# Test: File with single-quote characters must be quoted
filename="single'quoted'.txt"

(
    cd "$workdir"
    git init -q
    echo foo > "$filename"
    git number > /dev/null
    git number add 1
)

got=$(cd "$workdir" && git ls-files)
assert_eq "$got" "$filename" "File with single-quote characters must be quoted"

test_done

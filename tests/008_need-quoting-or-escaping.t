#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 1

setup

# Test: File with shell-unsafe characters must be quoted
filenames=(
    "file with spaces.txt"
    "(parenthesis).txt"
    "[square]brackets.txt"
    "backtick\`.txt"
    "dollar\$ign.txt"
    "background&.txt"
)

(
    cd "$workdir"
    git init -q
    for f in "${filenames[@]}"; do
        echo foo > "$f"
    done
    git number > /dev/null
    git number add 1-${#filenames[@]}
)

got=$(cd "$workdir" && git ls-files | sort)
expected=$(for f in "${filenames[@]}"; do echo "$f"; done | sort)

assert_eq "$got" "$expected" "File with shell-unsafe characters must be quoted"

test_done

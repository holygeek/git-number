#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 10

setup

# Test: git number list before git-number
(
    cd "$workdir"
    git init -q
    echo a > one.txt
    echo b > two.txt
)
got=$(cd "$workdir" && git number list 2>&1)
assert_eq "$got" "Please run git-number first" "git number list before git-number"

# Test: git number list 1
(
    cd "$workdir"
    git number > /dev/null
)
got=$(cd "$workdir" && git number list 1)
assert_eq "$got" "one.txt" "git number list 1"

# Test: git number list foo
got=$(cd "$workdir" && git number list foo)
assert_eq "$got" "foo" "git number list foo"

# Test: git number list 1 foo
got=$(cd "$workdir" && git number list 1 foo)
expected="one.txt
foo"
assert_eq "$got" "$expected" "git number list 1 foo"

# Test: git number list 1 foo 100
got=$(cd "$workdir" && git number list 1 foo 100)
expected="one.txt
foo
100"
assert_eq "$got" "$expected" "git number list 1 foo 100"

# Test: git number list 2
got=$(cd "$workdir" && git number list 2)
assert_eq "$got" "two.txt" "git number list 2"

# Test: git number list 1 2
got=$(cd "$workdir" && git number list 1 2)
expected="one.txt
two.txt"
assert_eq "$got" "$expected" "git number list 1 2"

# Test: git number list 1 2 1 2
got=$(cd "$workdir" && git number list 1 2 1 2)
expected="one.txt
two.txt
one.txt
two.txt"
assert_eq "$got" "$expected" "git number list 1 2 1 2"

# Test: pass args that look like options intact
got=$(cd "$workdir" && git number list -a -b -c)
expected="-a
-b
-c"
assert_eq "$got" "$expected" "pass args that look like options intact"

# Test: git number list (all)
got=$(cd "$workdir" && git number list)
expected="one.txt
two.txt"
assert_eq "$got" "$expected" "git number list (all)"

test_done

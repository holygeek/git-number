#!/bin/bash

# Base setup for bash tests
export srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export workdir="$srcdir/tests/testoutput"

# Ensure git-number is in PATH
export PATH="$srcdir:$PATH"

# Git test environment
export GIT_AUTHOR_EMAIL='author@example.com'
export GIT_AUTHOR_NAME='A. U. Thor'
export GIT_COMMITTER_EMAIL='author@example.com'
export GIT_COMMITTER_NAME='A. U. Thor'
export GIT_CONFIG_PARAMETERS="'alias.id=number id' 'alias.list=number list'"

test_count=0
test_failed=0
plan_set=0

plan() {
    echo "1..$1"
    plan_set=1
}

setup() {
    rm -rf "$workdir"
    mkdir -p "$workdir"
}

ok() {
    local name="$1"
    test_count=$((test_count + 1))
    echo "ok $test_count - $name"
}

not_ok() {
    local name="$1"
    local got="$2"
    local expected="$3"
    test_count=$((test_count + 1))
    test_failed=$((test_failed + 1))
    echo "not ok $test_count - $name"
    echo "  got: $got"
    echo "  expected (regex): $expected"
}

assert_match() {
    local got="$1"
    local expected="$2"
    local name="$3"
    
    if [[ "$got" =~ $expected ]]; then
        ok "$name"
    else
        not_ok "$name" "$got" "$expected"
    fi
}

assert_eq() {
    local got="$1"
    local expected="$2"
    local name="$3"
    if [[ "$got" == "$expected" ]]; then
        ok "$name"
    else
        not_ok "$name" "$got" "$expected"
    fi
}

test_done() {
    if [ $plan_set -eq 0 ]; then
        echo "1..$test_count"
    fi
    if [ $test_failed -gt 0 ]; then
        echo "Failed $test_failed tests"
        exit 1
    else
        echo "All tests passed"
        exit 0
    fi
}

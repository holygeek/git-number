#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 2

git_version=$(git version)
setup
assert_match "$git_version" "git version" "git is installed"
echo "# Using $git_version" >&2

if [ -d "$workdir" ]; then
    ok "Work dir created"
else
    not_ok "Work dir created" "directory not found" "$workdir"
fi

test_done

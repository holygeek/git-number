#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 2

setup

# Test: Modified a file in submodule
(
    cd "$workdir"
    mkdir a b
    cd a
    git init -q
    echo 'Super project' > a.txt
    git add . && git commit -q --no-verify -m 'initial commit a'
    
    cd ../b
    git init -q
    echo 'Sub project' > b.txt
    git add . && git commit -q --no-verify -m 'initial commit b'
    
    cd ../a
    git -c protocol.file.allow=always submodule -q add ../b b
    git commit -q --no-verify -m 'Added ../b as submodule in b'
    
    cd b
    echo 'Added new line' >> b.txt
)

got=$(cd "$workdir/a" && git number --color=never)
if [[ "$got" =~ "1	modified:   b (modified content)" ]]; then
    ok "Modified a file in submodule"
else
    not_ok "Modified a file in submodule" "$got" "1 modified: b (modified content)"
fi

# Test: Get name of modified submodule using git list
got=$(cd "$workdir/a" && git list 1)
assert_eq "$got" "b" "Get name of modified submodule using git list"

test_done

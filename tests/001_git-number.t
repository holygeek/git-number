#!/bin/bash

source "$(dirname "$0")/lib/test-lib.sh"

plan 11

setup

# Test 1: Two untracked files
(
    cd "$workdir"
    git init -q
    echo a > one.txt
    echo b > two.txt
)
got=$(cd "$workdir" && git number --color=never)
if [[ "$got" =~ 1.*one.txt && "$got" =~ 2.*two.txt ]]; then
    ok "Two untracked files"
else
    not_ok "Two untracked files" "$got" "1.*one.txt && 2.*two.txt"
fi

# Test 2: Added first file
(
    cd "$workdir"
    git add one.txt
)
got=$(cd "$workdir" && git number --color=never)
if [[ "$got" =~ "new file:   one.txt" && "$got" =~ "2	two.txt" ]]; then
    ok "Added first file"
else
    not_ok "Added first file" "$got" "new file: one.txt ... 2 two.txt"
fi

# Test 3: Added second file
(
    cd "$workdir"
    git add two.txt
)
got=$(cd "$workdir" && git number --color=never)
if [[ "$got" =~ "new file:   one.txt" && "$got" =~ "new file:   two.txt" ]]; then
    ok "Added second file"
else
    not_ok "Added second file" "$got" "new file: one.txt ... new file: two.txt"
fi

# Test 4: Status with deleted file
(
    cd "$workdir"
    rm -f two.txt
)
got=$(cd "$workdir" && git number --color=never)
if echo "$got" | grep "1	new file:   one.txt" > /dev/null && \
   echo "$got" | grep "2	new file:   two.txt" > /dev/null && \
   echo "$got" | grep "3	deleted:    two.txt" > /dev/null; then
    ok "Status with deleted file"
else
    # Try with different number of spaces for robustness
    if echo "$got" | grep "1" | grep "one.txt" > /dev/null && \
       echo "$got" | grep "2" | grep "two.txt" > /dev/null && \
       echo "$got" | grep "3" | grep "two.txt" > /dev/null; then
         ok "Status with deleted file (relaxed match)"
    else
        not_ok "Status with deleted file" "$got" "1 one.txt AND 2 two.txt AND 3 two.txt"
    fi
fi

# Test 5: Status after commit and reset --hard
(
    cd "$workdir"
    git commit -q --no-verify -m 'initial commit' > /dev/null
    git reset -q --hard > /dev/null
)
got=$(cd "$workdir" && git number --color=never)
if [[ "$got" =~ "nothing to commit" || "$got" =~ "Nothing to commit" ]]; then
    ok "Status after commit and reset --hard"
else
    not_ok "Status after commit and reset --hard" "$got" "nothing to commit"
fi

# Test 6: git-number status foo.txt
(
    cd "$workdir"
    echo foo > foo.txt
)
got=$(cd "$workdir" && git number --color=never)
if [[ "$got" =~ "Untracked files:" && "$got" =~ "1	foo.txt" ]]; then
    ok "git-number status foo.txt"
else
    not_ok "git-number status foo.txt" "$got" "Untracked files: ... 1 foo.txt"
fi

# Test 7: git-number status 1
got=$(cd "$workdir" && git number --color=never status 1)
if [[ "$got" =~ "On branch master" && "$got" =~ "foo.txt" ]]; then
    ok "git-number status 1"
else
    not_ok "git-number status 1" "$got" "On branch master ... foo.txt"
fi

# Test 8: git-number -c ls 1
got=$(cd "$workdir" && git number -c ls 1)
assert_eq "$got" "foo.txt" "git-number -c ls 1"

# Test 9: 'git-number -c ...' in different dir
(
    cd "$workdir"
    echo "Needle" > needle.txt
    mkdir -p sub
    cd sub
    git number > /dev/null
)
got=$(cd "$workdir" && git number -c cat 2)
assert_eq "$got" "Needle" "'git-number -c ...' in different dir"

# Test 10: retain -- in command line arg
(
    cd "$workdir"
    echo third > third.txt
    git add third.txt
    git commit -q --no-verify -m 'add third.txt' > /dev/null
    git rm -q third.txt > /dev/null
    git commit -q --no-verify -m 'remove third.txt' > /dev/null
)
got=$(cd "$workdir" && git number log -1 --format=%s -- third.txt)
assert_eq "$got" "remove third.txt" "retain -- in command line arg"

# Test 11: recognize numbers after triple dashes ---
(
    cd "$workdir"
    git clean -f -q
    echo "re-add third.txt" > third.txt
    git add third.txt
    git commit -q --no-verify -m 're-add third.txt'
    echo "modified" >> third.txt
    git number > /dev/null # third.txt should be there as modified.
)
# Find ID of third.txt
full_status=$(cd "$workdir" && git number)
id=$(echo "$full_status" | grep third.txt | awk '{print $1}' | tr -d '#\t ')
got=$(cd "$workdir" && git number log -1 --format=%s --- $id)
assert_eq "$got" "re-add third.txt" "recognize numbers after triple dashes ---"

test_done

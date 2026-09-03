#!/bin/sh

echo ::group::Check whether build.sh failed anywhere
state=$(cat .github/build-workflow/statefile || echo state-file-missing)
if test -n "$state"; then
	echo "E: .github/build-workflow/build.sh failed in: $state"
	exit 1
fi
echo "I: nope, ok"
echo ::endgroup::

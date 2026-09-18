#!/usr/bin/env sh

# Regenerates the vendored end-to-end test fixtures.
#
# Every fixture is a commits-only clone of a real upstream repository, vendored
# so the end-to-end tests neither reach the network nor depend on those
# repositories continuing to exist. See end-to-end-tests/fixtures/README.md.
#
# The repositories and their pinned commits are read out of the feature files,
# so this script cannot drift from the scenarios it serves.

set -o errexit
set -o xtrace

FEATURES_DIRECTORY="end-to-end-tests/features"
FIXTURES_DIRECTORY="end-to-end-tests/fixtures"

if [ ! -d "$FEATURES_DIRECTORY" ]; then
	echo "Run this script from the repository root."
	exit 1
fi

mkdir -p "$FIXTURES_DIRECTORY"

working_directory=$(mktemp -d)
# shellcheck disable=SC2064
trap "rm -rf '$working_directory'" EXIT

# Each scenario's Examples table starts with a repository column followed by the
# commit that repository is pinned at, so a fixture is needed for every distinct
# pairing of the two.
grep -hoE '\| *https?://[^ |]+ *\| *[0-9a-f]{40}' "$FEATURES_DIRECTORY"/*.feature |
	tr -d ' ' | sort -u >"$working_directory/pinned"

while IFS='|' read -r _ remote_repository commit; do
	[ -n "$remote_repository" ] || continue

	slug=$(printf '%s' "$remote_repository" | sed -e 's|^https\?://||' -e 's|\.git$||' -e 's|/|-|g')
	# The fixture is unpacked as a repository's .git directory, so it is built
	# in that shape rather than rewritten into it at the end.
	clone="$working_directory/$slug/.git"

	# --filter=tree:0 fetches commits and tags but no trees or blobs, which is
	# the entirety of what the linter reads.
	git clone --quiet --bare --filter=tree:0 "$remote_repository" "$clone"

	# Fail loudly now rather than shipping a fixture the scenarios cannot use.
	git --git-dir="$clone" cat-file -e "${commit}^{commit}"

	# Drop every route back to the network, so a fixture can only ever be read
	# from disk. Anything that asks for an absent tree or blob now fails instead
	# of silently refetching it.
	git --git-dir="$clone" remote remove origin
	# Absent when the server declined the filter and served a full clone, which
	# costs the fixture some size but nothing else.
	git --git-dir="$clone" config --unset extensions.partialclone || true

	# Unpacked the fixture is a repository's .git directory alongside an empty
	# working tree, which both the GIT_DIR and the working directory discovery
	# paths can open.
	git --git-dir="$clone" config core.bare false
	rm -rf "$clone/hooks" "$clone/logs" "$clone/FETCH_HEAD"

	tar -czf "$FIXTURES_DIRECTORY/$slug.tar.gz" -C "$working_directory/$slug" ".git"
done <"$working_directory/pinned"

ls -la "$FIXTURES_DIRECTORY"

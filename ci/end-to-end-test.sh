#!/usr/bin/env sh

set -o errexit
set -o xtrace

cd "clean_git_history/end-to-end-tests/"
behave

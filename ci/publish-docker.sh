#!/usr/bin/env sh

set -o errexit
set -o xtrace

if [ $# -ne 1 ]; then
	echo "Usage: $0 <release>"
	exit 1
fi

RELEASE="$1"
REPOSITORY="$(basename "$(git rev-parse --show-toplevel)")"
IMAGE="ghcr.io/developerc286/${REPOSITORY}"

# Download and extract pre-built binaries from the GitHub release for both architectures.
gh release download "${RELEASE}" --pattern "x86_64-unknown-linux-musl.tar.gz"
mkdir -p target/x86_64-unknown-linux-musl/release
tar -xzf x86_64-unknown-linux-musl.tar.gz -C target/x86_64-unknown-linux-musl/release

gh release download "${RELEASE}" --pattern "aarch64-unknown-linux-musl.tar.gz"
mkdir -p target/aarch64-unknown-linux-musl/release
tar -xzf aarch64-unknown-linux-musl.tar.gz -C target/aarch64-unknown-linux-musl/release

# Build and push the x86_64/amd64 Docker image.
docker buildx build --platform linux/amd64 --build-arg TARGET="x86_64-unknown-linux-musl" --tag "${IMAGE}:${RELEASE}-amd64" --file Dockerfile . --push

# Build and push the aarch64/arm64 Docker image.
docker buildx build --platform linux/arm64 --build-arg TARGET="aarch64-unknown-linux-musl" --tag "${IMAGE}:${RELEASE}-arm64" --file Dockerfile . --push

# Create and push the multi-architecture manifest.
docker buildx imagetools create --tag "${IMAGE}:${RELEASE}" \
	"${IMAGE}:${RELEASE}-amd64" \
	"${IMAGE}:${RELEASE}-arm64"

# Create alternate version tag (with/without 'v' prefix).
if [ "${RELEASE#v}" != "${RELEASE}" ]; then
	# Release has 'v' prefix (v1.2.3), also create version without 'v' prefix (1.2.3).
	docker buildx imagetools create --tag "${IMAGE}:${RELEASE#v}" "${IMAGE}:${RELEASE}"
else
	# Release has no 'v' prefix (1.2.3), also create version with 'v' prefix (v1.2.3).
	docker buildx imagetools create --tag "${IMAGE}:v${RELEASE}" "${IMAGE}:${RELEASE}"
fi

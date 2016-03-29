#!/usr/bin/env sh
set -o pipefail -o nounset -o errexit -o errtrace
BRANCH=$(git rev-parse --abbrev-ref HEAD)
LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))
NAME=ginit

if [ -z ${LATEST_TAG} ];
then
    echo "No tag has been found?"
    exit 1
fi
echo "Building a release for tag ${LATEST_TAG}"

# Dependencies
go get github.com/c4milo/github-release
go get github.com/mitchellh/gox

# Cleanup
rm -rf build dist && mkdir -p build dist

# Build
gox -ldflags "-w -X main.Version=${LATEST_TAG}" \
    -os="darwin" \
    -os="linux" \
    -os="windows" \
    -output "build/{{.Dir}}-${LATEST_TAG}-{{.OS}}-{{.Arch}}/${NAME}" \
    ./...

# Archive
HERE=$(pwd)
BUILDDIR=${HERE}/build
for DIR in $(ls build/);
do
    OUTFILE="${HERE}/dist/${DIR}.tar.gz"
    cd ${BUILDDIR}/${DIR} && \
        tar -czf ${OUTFILE} * && \
        shasum -a 512 ${OUTFILE} > ${OUTFILE}.sha512
done
cd ${HERE}

# Building the changelog
DIFF_REF=${LATEST_TAG}..HEAD
CHANGELOG=$(printf '# %s\n%s' 'Changelog' "$(git log ${DIFF_REF} --oneline --no-merges --reverse)")

github-release dynom/ginit ${LATEST_TAG} "$(git rev-parse --abbrev-ref HEAD)" "${CHANGELOG}" 'dist/*';
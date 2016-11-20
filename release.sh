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
gox -ldflags "-s -w -X main.Version=${LATEST_TAG}" \
    -osarch="darwin/386" \
    -osarch="darwin/amd64" \
    -osarch="linux/386" \
    -osarch="linux/amd64" \
    -osarch="windows/386" \
    -osarch="windows/amd64" \
    -output "build/{{.Dir}}-${LATEST_TAG}-{{.OS}}-{{.Arch}}/${NAME}" \
    ./...

# Archive the binaries
HERE=$(pwd)
BUILDDIR=${HERE}/build
echo "Creating archives"
for DIR in $(ls build/);
do
    OUTDIR="${HERE}/dist"
    OUTFILENAME="${DIR}.tar.gz"
    OUTFILE="${OUTDIR}/${OUTFILENAME}"
    cd ${BUILDDIR}/${DIR} && \
        tar -czf ${OUTFILE} * && \
    cd ${OUTDIR} && \
        shasum -a 512 ${OUTFILENAME} > ${OUTFILE}.sha512
done
cd ${HERE}

# Building the changelog
DIFF_REF=${LATEST_TAG}..HEAD
CHANGELOG=$(printf '# %s\n%s' 'Changelog' "$(git log ${DIFF_REF} --oneline --no-merges --reverse)")

echo "Pushing the release ${LATEST_TAG} to Github"
github-release dynom/${NAME} ${LATEST_TAG} "$(git rev-parse --abbrev-ref HEAD)" "${CHANGELOG}" 'dist/*';

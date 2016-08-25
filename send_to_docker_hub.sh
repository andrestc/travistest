#!/bin/bash

function tag_and_push {
	if [ -n "$1" ]; then
		echo "Pushing docker image to hub tagged as $1"
		docker build -t andrestc/test:$1 .
		docker push andrestc/test:$1
	fi
}

LATEST_TAG="latest"
MAJOR_TAG=""
VERSION_TAG=""

if [ -n "$TRAVIS_TAG" ] && [[ "${TRAVIS_TAG}" =~ ([0-9]+). ]]; then
	VERSION_TAG=v$TRAVIS_TAG
	if [[ $TRAVIS_TAG != *"rc"* ]]; then
		MAJOR_TAG=v${BASH_REMATCH[1]}
	fi
fi

if [ "${TRAVIS_GO_VERSION}" = "${GO_FOR_RELEASE}" ] && [ "${TRAVIS_BRANCH}" = "master" ]; then
	cat > ~/.dockercfg <<EOF
{
  "https://index.docker.io/v1/": {
    "auth": "${HUB_AUTH}",
    "email": "${HUB_EMAIL}"
  }
}
EOF
	tag_and_push $LATEST_TAG
	tag_and_push $MAJOR_TAG
	tag_and_push $VERSION_TAG
else
	echo "No image to build"
fi

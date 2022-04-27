#!/bin/bash

set -e

function usage() {
    echo "Run Docker Container for building product"
    echo ""
    echo "Command line arguments:"
    echo -e "\t--workspace, -w\n\t\tWorkspace"
    echo -e "\t--docker_image, -d\n\t\tDocker image that should be used for building product"
    echo ""

    exit 1
}

options=$(getopt -o hw:s:d: \
    --long workspace:,docker_image: \
    --long help \
    -- "$@")

# Map option variable to positional arguments (i.e. $1, $2 ...)
eval set -- "$options"

while :; do
    case "$1" in
    -h | --help) usage ;;
    -w | --workspace)
        WORKSPACE=$(readlink -f "$2")
        shift 2
        ;;
    -d | --docker_image)
        DOCKER_IMAGE_NAME="$2"
        shift 2
        ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --)
        shift
        break
        ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *)
        echo "Unexpected option: $1"
        usage
        ;;
    esac
done

# Check we have Docker image and workspace or we can't work.
if [ -z "${DOCKER_IMAGE_NAME}" ] || [ -z "${WORKSPACE}" ]; then
    usage
fi

echo "WORKSPACE         : $WORKSPACE"
echo "DOCKER_IMAGE_NAME : $DOCKER_IMAGE_NAME"

docker run \
	--network=host \
	-v "$HOME"/.ssh:/home/builder/.ssh \
	-v "$HOME"/.gitconfig:/home/builder/.gitconfig \
	-v "${WORKSPACE}":/home/builder/workspace \
	-ti --rm "$DOCKER_IMAGE_NAME"

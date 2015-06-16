#!/usr/bin/env bash

# declare arguments
INPUT=
BUILD_NUMBER=
BUILD_NAME_PREFIX=
BUILD_TYPE=

function usage() {
    echo 'find-build-artifact.sh --number latest --prefix ubuntu-server-14.04 --type qcow2 '
}

function check_dependencies() {
    if which sort > /dev/null 2>&1; then
        return 0
    fi

    echo 'the following commands must be available: sort' 1>&2
    return 1
}

function assert_dependencies() {
    if ! check_dependencies; then
        exit 2
    fi
}

# check that all required arguments have been passed
function assert_required_arguments() {
    if [ -z "${BUILD_NAME_PREFIX}" ]; then
        echo 'prefix parameter must be specified' 1>&2
        exit 2
    fi

    if [ -z "${BUILD_NUMBER}" ]; then
        echo 'build number must be specified' 1>&2
        exit 2
    fi

    if [ -z "${BUILD_TYPE}" ]; then
        echo 'build type must be specified' 1>&2
        exit 2
    fi
}

# parse options (flags, flags with arguments, long options) and input
function parse_arguments() {
    while [ $# -gt 0 ]
    do
        case "${1}" in
            -n|--number)
                BUILD_NUMBER="${2}"
                if [  "latest" != "${BUILD_NUMBER}" ]; then
                    echo 'invalid build number parameter specified' 1>&2
                    exit 2
                fi
                shift
            ;;
            -p|--prefix)
                BUILD_NAME_PREFIX="${2}"
                if [ -z "${BUILD_NAME_PREFIX}" ]; then
                    echo 'invalid prefix parameter specified' 1>&2
                    exit 2
                fi
            ;;
            -s|--status)
                if check_dependencies ; then
                    exit 0
                else
                    exit 1
                fi
            ;;
            -t|--type)
                BUILD_TYPE="${2}"
                if [  -z "${BUILD_TYPE}" ]; then
                    echo 'invalid build type parameter specified' 1>&2
                    exit 2
                fi
                shift
            ;;
            -h|--help)
                usage
                exit 1
            ;;
            --) # End of all options
                shift
                INPUT="${1}"
                break;
            ;;
            -*)
                echo "invalid parameter ""${1}" 1>&2
                exit 2
            ;;
        esac
        shift
    done
}

assert_dependencies
parse_arguments "$@"
assert_required_arguments

PROJECT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd )
BUILD_ROOT_DIR="${PROJECT_DIR}/target"

BUILD_DIR=$(find "${BUILD_ROOT_DIR}" -type d -name "${BUILD_NAME_PREFIX}*" | sort --reverse | head -n 1)
if [ -z "${BUILD_DIR}" ]; then
  echo "could not find build folder: ${BUILD_ROOT_DIR}/${BUILD_NAME_PREFIX}*" 1>&2
  exit 1
fi

BUILD_ARTIFACT=$(find "${BUILD_DIR}" -type f -name "*.${BUILD_TYPE}" | head -n 1)
if [ -z "${BUILD_ARTIFACT}" ]; then
    echo "could not find build artifact: ${BUILD_DIR}/*.${BUILD_TYPE}" 1>&2
    exit 1
fi

echo "${BUILD_ARTIFACT}"


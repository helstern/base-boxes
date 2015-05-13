#!/usr/bin/env bash

BUILD_NUMBER=latest
BUILD_NAME_PREFIX=
BUILD=
BUILD_TYPE=qcow2

function usage() {
    echo 'this script builds a '

    echo 'qemu2vagrant.build-pipeline.sh [--number latest] --prefix ubuntu-server-14.04'
}

function check_dependencies() {
    if which sort head wc packer qemu-img > /dev/null 2>&1; then
        echo 'all dependencies met'
        return 0
    fi

    echo 'the following commands must be available: sort head wc'
    return 1
}

function assert_conflicting_arguments() {
    if [ -n "${BUILD}" ] && [ -n "${BUILD_NAME_PREFIX}" ]; then
        echo 'only one of -b|--build or -n|--number can be specified'
        exit 1
    fi
}

# parse options (flags, flags with arguments, long options) and input
function parse_arguments() {
    while [ $# -gt 0 ]
    do
        case "${1}" in
            -b|--build)
                BUILD="${2}"
                shift
            ;;
            -h|--help)
                usage
                exit 1
            ;;
            -n|--number)
                BUILD_NUMBER="${2}"
                shift
            ;;
            -p|--prefix)
                BUILD_NAME_PREFIX="${2}"
                if [ -z "${BUILD_NAME_PREFIX}" ]; then
                    echo 'invalid prefix parameter specified'
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
            --) # End of all options
                shift
                INPUT="${1}"
                break;
            ;;
            -*)
                echo "invalid parameter ""${1}"
                exit 2
            ;;
        esac
        shift
    done
}

function assert_qemu_build_src() {
    if [ "$(echo "${1}" | wc --lines)" != "1" ]; then
        echo 'found more than one build dir:'
        echo "${1}"
        exit 1
    fi

    if ! test -f "${1}/manifest.qemu.packer.json"; then
        echo "missing base qemu manifest ${1}/manifest.qemu.packer.json"
        exit 1
    fi

    if ! test -f "${1}/vagrant.manifest.qemu.packer.json"; then
        echo "missing base qemu manifest ${1}/vagrant.manifest.qemu.packer.json"
        exit 1
    fi
}

parse_arguments "$@"
assert_conflicting_arguments

PROJECT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd)
# build number is the unix timestamp
BUILD_NUMBER=$(date +%s)
BASE_QEMU_ARTIFACT="${PROJECT_DIR}/target/${BUILD}-${BUILD_NUMBER}/${BUILD}.qcow2"
VAGRANT_QEMU_ARTIFACT="${PROJECT_DIR}/target/vagrant-${BUILD}-${BUILD_NUMBER}/${BUILD}.qcow2"
VAGRANT_BOX_ARTIFACT="${PROJECT_DIR}/target/${BUILD}-${BUILD_NUMBER}.box"

if [ -n "${BUILD_NAME_PREFIX}" ]; then
    BASE_QEMU_ARTIFACT=$(cd "${PROJECT_DIR}/bin"; bash ./find-build-artifact.sh --number "${BUILD_NUMBER}" --prefix "${BUILD_NAME_PREFIX}"  --type "${BUILD_TYPE}")
    echo "${BASE_QEMU_ARTIFACT}"
    echo "not implemented"
    exit 1
fi

BUILD_SRC_DIR=$(find "${PROJECT_DIR}/src" -type d -name "${BUILD}" | head -n 2)
assert_qemu_build_src "${BUILD_SRC_DIR}"

echo "building base artifact: ${BASE_QEMU_ARTIFACT}"
(cd "${BUILD_SRC_DIR}"; packer build --var "build_id=${BUILD_NUMBER}" ./manifest.qemu.packer.json)
if [ ! -f "${BASE_QEMU_ARTIFACT}" ]; then
    echo "failed to build base qemu artifact ${BASE_QEMU_ARTIFACT}"
    exit 1
fi

echo "building vagrant artifact: ${VAGRANT_QEMU_ARTIFACT}"
(cd "${BUILD_SRC_DIR}"; packer build --var "build_id=${BUILD_NUMBER}" --var "iso_url=${BASE_QEMU_ARTIFACT}"  ./vagrant.manifest.qemu.packer.json)
if [ ! -f "${VAGRANT_QEMU_ARTIFACT}" ]; then
    echo "failed to build vagrant qemu artifact ${VAGRANT_QEMU_ARTIFACT}"
    exit 1
fi

echo "converting ${VAGRANT_QEMU_ARTIFACT} to a vagrant box ${VAGRANT_BOX_ARTIFACT}"
(cd "${PROJECT_DIR}/bin"; bash ./qemu2vagrant-box.sh  "${VAGRANT_QEMU_ARTIFACT}" "${VAGRANT_BOX_ARTIFACT}")
if [ ! -f "${VAGRANT_BOX_ARTIFACT}" ]; then
    echo "failed to build vagrant box ${VAGRANT_BOX_ARTIFACT}"
    exit 1
fi

echo "importing vagrant box ${VAGRANT_BOX_ARTIFACT}"
if ! vagrant box add --force "${VAGRANT_BOX_ARTIFACT}" --name "${BUILD}" ; then
  exit 1
fi

rm -rf "$(dirname ${VAGRANT_QEMU_ARTIFACT})"
rm -f "${VAGRANT_BOX_ARTIFACT}"

echo "done"

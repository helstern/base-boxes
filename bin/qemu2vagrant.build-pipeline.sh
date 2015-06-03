#!/usr/bin/env bash

BUILD_NUMBER=latest
BUILD_NAME_PREFIX=
BUILD=
BASE_BUILD=
BUILD_TYPE=qcow2

function usage() {
    echo 'this script builds a '
    echo 'qemu2vagrant.build-pipeline.sh [--base ubuntu-server-14.04] [--build-number latest] -- ubuntu-server-14.04'
}

function check_dependencies() {
    if which sort head wc packer qemu-img vagrant > /dev/null 2>&1; then
        echo 'all dependencies met'
        return 0
    fi

    echo 'the following commands must be available: sort head wc packer qemu-img vagrant' 1>&2
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
            -b|--base)
                BASE_BUILD="${2}"
                if [ -z "${BASE_BUILD}" ]; then
                    echo 'invalid prefix parameter specified'
                    exit 2
                fi

                shift
            ;;
            -h|--help)
                usage
                exit 1
            ;;
            -n|--build-number)
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
                BUILD="${1}"
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
        echo 'found more than one build dir:' 1>&2
        echo "${1}" 1>&2
        exit 1
    fi

    if ! test -f "${1}/manifest.qemu.packer.json"; then
        echo "missing base qemu manifest ${1}/manifest.qemu.packer.json" 1>&2
        exit 1
    fi

    if ! test -f "${1}/vagrant.manifest.qemu.packer.json"; then
        echo "missing base qemu manifest ${1}/vagrant.manifest.qemu.packer.json" 1>&2
        exit 1
    fi
}

parse_arguments "$@"
assert_conflicting_arguments

PROJECT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../" && pwd)

if [ -n "${BASE_BUILD}" ]; then
    BASE_QEMU_ARTIFACT=$(bash "${PROJECT_DIR}"/bin/find-build-artifact.sh --number latest --prefix "${BASE_BUILD}" --type "${BUILD_TYPE}" 2>/dev/null)
fi

# build number is the unix timestamp
BUILD_NUMBER=$(date +%s)
BUILD_SRC_DIR=$(find "${PROJECT_DIR}/src" -type d -name "${BUILD}" | head -n 2)

if [ -z "${BASE_QEMU_ARTIFACT}" ]; then
    BASE_QEMU_ARTIFACT="${PROJECT_DIR}/target/${BUILD}-${BUILD_NUMBER}/${BUILD}.qcow2"
    (cd "${BUILD_SRC_DIR}"; packer build --var "build_id=${BUILD_NUMBER}" ./manifest.qemu.packer.json)
fi

if [ ! -f "${BASE_QEMU_ARTIFACT}" ]; then
    echo "failed to build base qemu artifact ${BASE_QEMU_ARTIFACT}" 1>&2
    exit 1
fi

VAGRANT_QEMU_ARTIFACT="${PROJECT_DIR}/target/vagrant-${BUILD}-${BUILD_NUMBER}/${BUILD}.qcow2"
echo "building vagrant qemu artifact: ${VAGRANT_QEMU_ARTIFACT}"
(cd "${BUILD_SRC_DIR}"; packer build --var "build_name=${BUILD}" --var "build_id=${BUILD_NUMBER}" --var "iso_url=${BASE_QEMU_ARTIFACT}"  ./vagrant.manifest.qemu.packer.json)
if [ ! -f "${VAGRANT_QEMU_ARTIFACT}" ]; then
    echo "failed to build vagrant qemu artifact ${VAGRANT_QEMU_ARTIFACT}" 1>&2
    exit 1
fi

VAGRANT_BOX_ARTIFACT="${PROJECT_DIR}/target/${BUILD}-${BUILD_NUMBER}.box"
echo "converting ${VAGRANT_QEMU_ARTIFACT} to a vagrant box ${VAGRANT_BOX_ARTIFACT}"
(cd "${PROJECT_DIR}/bin"; bash ./qemu2vagrant.build-box.sh  "${VAGRANT_QEMU_ARTIFACT}" "${VAGRANT_BOX_ARTIFACT}")
if [ ! -f "${VAGRANT_BOX_ARTIFACT}" ]; then
    echo "failed to build vagrant box ${VAGRANT_BOX_ARTIFACT}" 1>&2
    exit 1
fi

echo "importing vagrant box ${VAGRANT_BOX_ARTIFACT}"
if ! vagrant box add --force "${VAGRANT_BOX_ARTIFACT}" --name "${BUILD}" ; then
  exit 1
fi

rm -rf "$(dirname ${VAGRANT_QEMU_ARTIFACT})"
rm -f "${VAGRANT_BOX_ARTIFACT}"

echo "done"

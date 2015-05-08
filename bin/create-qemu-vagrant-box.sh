#!/usr/bin/env bash
set -xu

check_requirements() {
    if ! which jq > /dev/null 2>&1 ; then
        echo 'script has unmet dependencies: jq'
        exit 1
    fi
}

error() {
    local msg="${1}"
    echo "==> ERROR: ${msg}"
    exit 1
}

usage() {
    echo "Usage: ${0} IMAGE [BOX]"
    echo
    echo "Package a qcow2 image into a vagrant-libvirt reusable box"
    echo "Requires: jq"
}

# Print the image's backing file
backing(){
    local img=${1}
    qemu-img info "$img" | grep 'backing file:' | cut -d ':' -f2
}

# Rebase the image
rebase(){
    local img=${1}
    qemu-img rebase -p -b "" "$img"
    [[ "$?" -ne 0 ]] && error "Error during rebase"
}

# Is absolute path
isabspath(){
    local path=${1}
    [[ "$path" =~ ^/.* ]]
}

check_requirements

if [ -z "$1" ]; then
    usage
    exit 1
fi

IMG=$(readlink -e "$1")
[[ "$?" -ne 0 ]] && error "'$1': No such image"

IMG_DIR=$(dirname "$IMG")
IMG_BASENAME=$(basename "$IMG")

BOX=${2:-}
# If no box name is supplied infer one from image name
if [[ -z "$BOX" ]]; then
    BOX_NAME=${IMG_BASENAME%.*}
    BOX=$BOX_NAME.box
else
    BOX_NAME=$(basename "${BOX%.*}")
fi

[[ -f "$BOX" ]] && error "'$BOX': Already exists"

CWD=$(pwd)
TMP_DIR="$CWD/_tmp_package"
TMP_IMG="$TMP_DIR/box.img"

mkdir -p "$TMP_DIR"

[[ ! -w "$IMG" ]] && error "'$IMG': Permission denied"

ORIGINAL_FORMAT=$(qemu-img info --output=json "$IMG" | jq --raw-output '.format')

# We move / copy (when the image has master) the image to the tempdir
# ensure that it's moved back / removed again
if [[ -n $(backing "$IMG") ]]; then
    echo "==> Image has backing image, copying image and rebasing ..."
    trap "rm -rf $TMP_DIR" EXIT
    cp "$IMG" "$TMP_IMG"
    rebase "$TMP_IMG"
    # this is was not tested
    qemu-img convert -f "${ORIGINAL_FORMAT}" -O qcow2 "$TMP_IMG" "$TMP_IMG"
else
    if fuser -s "$IMG"; then
        error "Image '$IMG_BASENAME' is used by another process"
    fi

    if [ "${ORIGINAL_FORMAT}" != "qcow2" ]; then
        qemu-img convert -f "${ORIGINAL_FORMAT}" -O qcow2 "$IMG" "$TMP_IMG"
        trap 'rm -rf "$TMP_DIR"' EXIT
    else
        # move the image to get a speed-up and use less space on disk
        trap 'mv "$TMP_IMG" "$IMG"; rm -rf "$TMP_DIR"' EXIT
        mv "$IMG" "$TMP_IMG"
    fi
fi

cd "$TMP_DIR"

IMG_SIZE=$(qemu-img info  --output=json "$TMP_IMG" | sed -e 's/virtual-size/virtualsize/g' | jq --raw-output '. virtualsize')
IMG_SIZE=$(( ${IMG_SIZE} / 1024 / 1024 / 1024 ))

cat > metadata.json <<EOF
{
    "provider": "libvirt",
    "format": "qcow2",
    "virtual_size": ${IMG_SIZE}
}
EOF

cat > Vagrantfile <<EOF
Vagrant.configure("2") do |config|

  config.vm.provider :libvirt do |libvirt|

    libvirt.driver = "kvm"
    libvirt.host = ""
    libvirt.connect_via_ssh = false
    libvirt.storage_pool_name = "default"

  end
end
EOF

echo "==> Creating box, tarring and gzipping"

tar cvzf "$BOX" --totals ./metadata.json ./Vagrantfile ./box.img

# if box is in tmpdir move it to CWD before removing tmpdir
if ! isabspath "$BOX"; then
    mv "$BOX" "$CWD"
fi

echo "==> ${BOX} created"
echo "==> You can now add the box:"
echo "==>   'vagrant box add ${BOX} --name ${BOX_NAME}'"

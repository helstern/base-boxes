Prepares base box running ubuntu server 12.04

build non-unique build
packer build --var "build_id=" manifest.virtualbox.packer.json

build unique build
packer build manifest.virtualbox.packer.json

one-line vagrant 
packer build --var "build_id=" manifest.virtualbox.packer.json && packer build manifest.vagrant.packer.json

Prepares base box running ubuntu server 12.04

build non-unique build
packer build --var "build_id=" manifest.standard.packer.json

build unique build
packer build manifest.standard.packer.json
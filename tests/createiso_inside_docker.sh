#!/bin/sh -xe

OS_VERSION=$1
ISO_URL=http://mirror.rackspace.com/CentOS/7/isos/x86_64/CentOS-7-x86_64-Minimal-1611.iso
ISO_FNAME=$(basename ${ISO_URL})
BUILD_TARGET=/rocknsm-${TRAVIS_TAG}-x86_64.iso

# Bootstrap the build environment
cd /rock-createiso
./bootstrap.sh

# Update the snapshot
./offline-snapshot.sh

# Download the ISO
wget ${ISO_URL}

# Run the build
./master-iso.sh ${ISO_FNAME} ${BUILD_TARGET}

# Output the results
echo "--- BEGIN BUILD LOG ---"
cat $(ls build-*.log | tail -1)

echo "--- END BUILD LOG ---"

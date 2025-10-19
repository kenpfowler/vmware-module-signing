#!/bin/bash

KEY_NAME="MOK.priv"
CERT_NAME="MOK.der"
SIGN_TOOL="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"


# Check whether a directory for vmware keys to exist
VMWARE_SIGNING_DIRECTORY="$HOME/vmware-signing"

echo "Checking that directory with keys exists..."

if [ -d "$VMWARE_SIGNING_DIRECTORY" ]; 
then
  echo "Directory '$VMWARE_SIGNING_DIRECTORY' exists."
else
  echo "Directory '$VMWARE_SIGNING_DIRECTORY' does not exist."
  echo "Creating directory..."
  mkdir -p "$VMWARE_SIGNING_DIRECTORY" && echo "Created successfully."
fi

# Check if signing keys have been generated

if [ -f $VMWARE_SIGNING_DIRECTORY/MOK.der ]; then
  echo "File exists"
else
  echo "File does not exist"
  echo "Please generate signing keys"
  exit 1
fi

if [ -f $VMWARE_SIGNING_DIRECTORY/MOK.priv ]; then
  echo "File exists"
else
  echo "File does not exist"
  echo "Please generate signing keys"
  exit 1
fi

# sign kernel modules with key

$SIGN_TOOL sha256 $VMWARE_SIGNING_DIRECTORY/KEY_NAME $VMWARE_SIGNING_DIRECTORY/CERT_NAME $(modinfo -n vmmon)
$SIGN_TOOL sha256 $VMWARE_SIGNING_DIRECTORY/KEY_NAME $VMWARE_SIGNING_DIRECTORY/CERT_NAME $(modinfo -n vmnet)

# remove then add the modules from kernel
modprobe -r vmmon vmnet && modprobe vmmon vmnet

# check that vmmon module is loaded
if lsmod | grep  -q vmmon; 
then
  echo "vmmon module loaded successfully!"
else
  echo "vmmon module failed to load!"
fi

# check that vmnet module is loaded
if lsmod | grep -q vmnet; 
then
  echo "vmnet module loaded successfully!"
else
  echo "vmnet module failed to load!"
fi



#!/bin/bash

# verify script was called with sudo
if (( $EUID != 0 ))
then
	echo "Please run with sudo"
	exit 1
fi

# assign constants
KEY_NAME="MOK.priv"
CERT_NAME="MOK.der"

VMWARE_SIGNING_DIRECTORY="$(getent passwd $SUDO_USER | cut -d: -f6)/vmware-signing"

SIGN_TOOL="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"

# sign kernel modules with key
sudo $SIGN_TOOL sha256 $VMWARE_SIGNING_DIRECTORY/$KEY_NAME $VMWARE_SIGNING_DIRECTORY/$CERT_NAME $(modinfo -n vmmon)
sudo $SIGN_TOOL sha256 $VMWARE_SIGNING_DIRECTORY/$KEY_NAME $VMWARE_SIGNING_DIRECTORY/$CERT_NAME $(modinfo -n vmnet)

# remove then add the modules from kernel
sudo modprobe -r vmmon vmnet
sudo modprobe vmmon 
sudo modprobe vmnet

# check that vmmon module is loaded
if lsmod | grep  -q vmmon; 
then
  echo "vmmon module loaded successfully!"
else
  echo "vmmon module failed to load!"
  exit 1
fi

# check that vmnet module is loaded
if lsmod | grep -q vmnet; 
then
  echo "vmnet module loaded successfully!"
else
  echo "vmnet module failed to load!"
  exit 1
fi

exit 0

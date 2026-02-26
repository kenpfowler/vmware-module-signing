#!/bin/bash

# verify script was called with sudo
if (( $EUID != 0 ))
then
	echo "Please run with sudo"
	exit 1
fi

if [ -z "$SUDO_USER" ]; then
	echo "Error: Run with sudo, not as root directly."
	exit 1
fi

# assign constants
KEY_NAME="MOK.priv"
CERT_NAME="MOK.der"

VMWARE_SIGNING_DIRECTORY="$(getent passwd $SUDO_USER | cut -d: -f6)/vmware-signing"

SIGN_TOOL="/usr/src/linux-headers-$(uname -r)/scripts/sign-file"

# verify signing tool exists (requires linux-headers for the running kernel)
if [ ! -f "$SIGN_TOOL" ]; then
  echo "Error: Signing tool not found at $SIGN_TOOL. Install linux-headers-$(uname -r)."
  exit 1
fi

# verify signing keys exist
if [ ! -f "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME" ] || [ ! -f "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME" ]; then
  echo "Error: Signing keys not found in $VMWARE_SIGNING_DIRECTORY. Run enroll-vmware-mok.bash first."
  exit 1
fi

# sign kernel modules with key
if ! $SIGN_TOOL sha256 "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME" "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME" "$(modinfo -n vmmon)"; then
  echo "Error: Failed to sign vmmon module."
  exit 1
fi

if ! $SIGN_TOOL sha256 "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME" "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME" "$(modinfo -n vmnet)"; then
  echo "Error: Failed to sign vmnet module."
  exit 1
fi

# remove then add the modules from kernel
modprobe -r vmmon vmnet
modprobe vmmon
modprobe vmnet

# check that vmmon module is loaded
if lsmod | grep -q vmmon;
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

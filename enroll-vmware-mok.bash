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
MOKUTIL="mokutil"
OPENSSL="openssl"
KEY_NAME="MOK.priv"
CERT_NAME="MOK.der"

# assign directory for MOK
VMWARE_SIGNING_DIRECTORY="$(getent passwd $SUDO_USER | cut -d: -f6)/vmware-signing"

# verify dependencies are installed
if ! dpkg -s "$MOKUTIL" &> /dev/null; 
then
    echo "Error: Package '$MOKUTIL' is not installed."
    exit 1
fi

if ! dpkg -s "$OPENSSL" &> /dev/null;
then
    echo "Error: Package '$OPENSSL' is not installed."
    exit 1
fi

# verify directory to store kernel module signing keys exists
if [ ! -d "$VMWARE_SIGNING_DIRECTORY" ];
then
  mkdir -p "$VMWARE_SIGNING_DIRECTORY"
fi

echo "Your MOK will be saved to $VMWARE_SIGNING_DIRECTORY"

# abort if keys already exist to avoid invalidating a prior enrollment
if [ -f "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME" ] || [ -f "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME" ]; then
  echo "Error: Signing keys already exist in $VMWARE_SIGNING_DIRECTORY. Remove them first if you want to re-enroll."
  exit 1
fi

# generate key pair to sign vmmon and vmnet modules
if ! openssl req -new -x509 -newkey rsa:2048 -keyout "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME" -outform DER -out "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME" -noenc -days 36500 -subj "/CN=VMware/" 2> /dev/null; then
  echo "Error: Failed to generate key pair."
  exit 1
fi

chmod 400 "$VMWARE_SIGNING_DIRECTORY/$KEY_NAME"

# enroll your MOK with secure boot
echo "Importing MOK. You will be asked for a password. You'll need it to authenticate when enrolling your Machine Owner Keys (MOK)"
mokutil --import "$VMWARE_SIGNING_DIRECTORY/$CERT_NAME"

echo "Reboot to finish enrolling your MOK."

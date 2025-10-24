#!/bin/bash

# verify script was called with sudo
if (( $EUID != 0 ))
then
	echo "Please run with sudo"
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

# generate key pair to sign vmmon and vmnet modules
openssl req -new -x509 -newkey rsa:2048 -keyout $VMWARE_SIGNING_DIRECTORY/$KEY_NAME -outform DER -out $VMWARE_SIGNING_DIRECTORY/$CERT_NAME -nodes -days 36500 -subj "/CN=VMware/" &> /dev/null

# enroll your MOK with secure boot
echo "Importing MOK. You will be asked for a password. You'll need it to authenticate when enrolling your Machine Owner Keys (MOK)"
mokutil --import $VMWARE_SIGNING_DIRECTORY/$CERT_NAME

echo "Reboot to finish enrolling your MOK."

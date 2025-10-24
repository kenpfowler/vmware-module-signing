## Prerequisites

The following dependencies are required:

- openssl package
- mokutil package

Run `sudo apt update && sudo apt install openssl mokutil`

## Usage

1. Call the `enroll-vmware-mok.sh` script as superuser
2. Reboot your machine and enroll your Machine Owner Key (MOK)
3. Call the `sign-vmware-modules.sh` script as superuser to sign and load `vmmon` and `vmnet` kernel modules

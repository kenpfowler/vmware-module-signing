## Prerequisites

VMware Workstation must already be installed before running these scripts.

The following packages are required:

- openssl
- mokutil
- linux-headers for your running kernel

Run `sudo apt update && sudo apt install openssl mokutil linux-headers-$(uname -r)`

## Usage

1. Run the enrollment script with sudo:

   ```
   sudo ./enroll-vmware-mok.bash
   ```

   You will be prompted to set a MOK password. **Remember this password** — you will need it at the UEFI prompt after rebooting.

2. Reboot your machine. At the UEFI MOK enrollment screen, select **Enroll MOK → Continue**, enter the password you set, then reboot.

3. Sign the modules with sudo:
   ```
   sudo ./sign-vmware-modules.bash
   ```

## Kernel Updates

You will have to re-sign the VMware kernel modules each time the kernel is updated. You will also need to reinstall `linux-headers` if it was not updated automatically.

```
sudo apt install linux-headers-$(uname -r)
sudo ./sign-vmware-modules.bash
```

## Notes

- If you need to re-enroll (e.g. after reinstalling VMware), remove the existing keys first: `rm ~/vmware-signing/MOK.priv ~/vmware-signing/MOK.der`

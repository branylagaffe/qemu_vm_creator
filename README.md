è### QEMU Instance Creator

This repo was build to create QEMU instance in a snap

## Prerequisit

- QEMU build (a binary exists somewhere)
- `qemu-efi-aarch64` package (check ` /usr/share/qemu-efi-aarch64`)
- Hashicorp Packer

## Step by step

Follow this guide to set up packer dependancies, and create a QEMU VM

# UEFI binaries

```bash
cd packer
truncate -s 64m varstore.img

truncate -s 64m efi.img
dd if="/usr/share/qemu-efi-aarch64/QEMU_EFI.fd" of=efi.img conv=notrunc

```
[For reference](https://cdn.kernel.org/pub/linux/kernel/people/will/docs/qemu/qemu-arm64-howto.html)

# Config SSH
Add your ssh public key in the `config/authorized_keys` file

# Build an image

```bash
packer init .
packer build .
```

# Run the image

```bash
cd output-alpine-workloads

qemu-system-aarch64 -machine virt,gic-version=max,virtualization=on \ 
                    -smp 1 -m 4G -cpu max,pauth-impdef=on \ 
                    -device qemu-xhci -device usb-kbd -device bochs-display \ 
                    -parallel none \ 
                    -drive file=../efi.img,format=raw,if=pflash \ 
                    -drive file=./efivars.fd,if=pflash,format=raw \ 
                    -drive file=./base.qcow2,format=qcow2,if=virtio
                    -nographic

```


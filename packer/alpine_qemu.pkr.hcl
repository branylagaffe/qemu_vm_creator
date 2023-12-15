source "qemu" "workloads_test" {

  qemu_binary       = "/usr/local/bin/qemu-system-aarch64"
  
  // OS
  iso_url           = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-virt-3.18.5-aarch64.iso"
  iso_checksum      = "sha256:ba72f4b3cccf3addf9babc210d44096880b78ecca9e8758fb22ce2a8055d10b6"
  cdrom_interface   = "virtio"

  // Disk
  vm_name           = "test"
  output_directory  = "alpine_base"
  disk_size         = "10G"
  format            = "qcow2"
  disk_image        = true
  disk_interface    = "virtio"
  
  // Machine
  machine_type      = "virt"
  accelerator       = "tcg"
  cpus              = 2
  memory            = 2048
  net_device        = "virtio-net"
  qemuargs = [
    ["-machine", "virt,gic-version=max,virtualization=on"],
    ["-cpu", "max,pauth-impdef=on"],
    // ["-rtc", "clock=vm"],
    // ["-icount","shift=0,sleep=on,align=off"],
    // ["-device", "virtio-net,netdev=net0"],
    // ["-netdev", "user,id=net0,hostfwd=tcp::0-:22"],
    ["-net", "user"],
    ["-monitor", "none"],
    ["-device", "virtio-gpu-pci"],
    // ["-nographic"]
  ]
  shutdown_command  = "poweroff"
  
  //BOOT
  boot_wait         = "10s"
  efi_boot          = true
  efi_firmware_vars = "./varstore.img" // need to be align on 64MB
  efi_firmware_code = "./efi.img"
  
  // After boot
  communicator      = "none"
  // ssh_username      = "root"
  // ssh_password      = ""
  // ssh_timeout       = "2m"
  // use_default_display = true
  disable_vnc       = false
  boot_command     = [
		"<enter>FS0:<enter>efi\\boot\\boot<tab><enter>",
    "<wait1m>",
    "root<enter><enter>",
    "setup-keymap<enter>en<enter>gb<enter>gb<enter><wait5s>",
    "setup-hostname<enter><wait1s><enter><wait1s>",
    "setup-interfaces<enter><wait1s><enter><wait1s><enter><wait1s><enter><wait1s>",
    "rc-service networking --quiet start &<enter><wait5s>",
    "rc-service hostname --quiet restart<enter><wait5s>",

    "cat > /etc/apk/repositories << EOF; $(echo)<enter>",
    "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/main/<enter>",
    "https://dl-cdn.alpinelinux.org/alpine/v$(cut -d'.' -f1,2 /etc/alpine-release)/community/<enter>",
    "https://dl-cdn.alpinelinux.org/alpine/edge/testing/<enter>",
    "EOF<enter><wait2s>",

    "setup-sshd -c openssh<enter><wait5s>",
    "apk update<enter><wait10s>apk upgrade<enter><wait10s>",
    "apk add docker<enter><wait30s>",
    "addgroup username docker<enter><wait1s>",
    "rc-update add docker default<enter><wait5s>",
    "service docker start<enter><wait2s>",
  ]

  // boot_command = [
  //   "<enter>",
  //   "root<enter>",
  //   "apk update<enter>"
  // ]
  // headless          = "true"

//   http_directory    = "path/to/httpdir"
//   boot_command      = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos6-ks.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.workloads_test"]
}

packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

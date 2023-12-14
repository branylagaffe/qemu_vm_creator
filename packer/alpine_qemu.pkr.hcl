source "qemu" "workloads_test" {
    qemu_binary       = "/usr/local/bin/qemu-system-aarch64"
    iso_url           = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-virt-3.18.5-aarch64.iso"
    iso_checksum      = "sha256:ba72f4b3cccf3addf9babc210d44096880b78ecca9e8758fb22ce2a8055d10b6"
    output_directory  = "output_alpine"
    shutdown_command  = "echo 'packer' | poweroff"
    disk_size         = "10G"
    memory            = 2048
    use_pflash        = true
    format            = "qcow2"
    accelerator       = "tcg"
    communicator      = "ssh"
    ssh_username      = "root"
    ssh_password      = ""
    ssh_timeout       = "10s"
    vm_name           = "wl_test"
    net_device        = "virtio-net"
    disk_interface    = "virtio"
    boot_wait         = "1m"
    machine_type      = "virt"
    efi_boot          = true
    cpus              = 2
    efi_firmware_code = "./efi.img"
    efi_firmware_vars = "./varstore.img" // need to be align on 64MB
    // headless          = "true"
	// vtpm              = true

    qemuargs = [
        ["-machine", "virt,gic-version=max,virtualization=on"],
        ["-cpu", "max,pauth-impdef=on"],
        ["-rtc", "clock=vm"],
        ["-icount","shift=0,sleep=on,align=off"],
        ["-device", "virtio-gpu-pci"],
        [ "-netdev", "user,hostfwd=tcp::0-:22,id=forward"],
        [ "-device", "virtio-net,netdev=forward,id=net0"]
    ]

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

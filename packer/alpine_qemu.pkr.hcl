source "qemu" "alpine-workloads" {

  qemu_binary       = "/usr/local/bin/qemu-system-aarch64"
  headless          = false // <<== DEBUG MODE HERE
  use_default_display = false // <<== DEBUG MODE HERE
  
  // OS
  iso_url           = "https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-virt-3.18.5-aarch64.iso"
  iso_checksum      = "sha256:ba72f4b3cccf3addf9babc210d44096880b78ecca9e8758fb22ce2a8055d10b6"

  // Disk
  vm_name           = "base.qcow2"
  disk_size         = "20G"
  format            = "qcow2"
  disk_compression  = true
  // disk_interface    = "virtio" 
  
  // Machine
  machine_type      = "virt"
  accelerator       = "tcg"
  cpus              = 2
  memory            = 2048
  net_device        = "virtio-net"
  qemuargs = [
    ["-machine", "virt,gic-version=max,virtualization=on"],
    ["-cpu", "max,pauth-impdef=on"],
    ["-device", "qemu-xhci"],         //? These lines were added for
    ["-device", "usb-kbd"],           //? host (linux) that do not support
    ["-device", "bochs-display"],     //? serial0 from VNC out of the box
    ["-monitor", "none"],
    ["-parallel", "none"],
    // ["-rtc", "clock=vm"],
    // ["-icount","shift=0,sleep=on,align=off"],
  ]
  
  //BOOT
  boot_wait         = "10s"
  efi_boot          = true
  efi_firmware_vars = "./varstore.img"  // need to be align on 64MB
  efi_firmware_code = "./efi.img"       // need to be align on 64MB
  
  // SETUP
  http_directory    = "./config"
  boot_steps     = [
     // Optional
		["<enter>FS0:<enter>efi\\boot\\boot<tab><enter>", "Running bootloader"],
    ["<wait1m>", "Waiting to boot"],

    // Starting
    ["root<enter><enter>", "Entering session"],

    // Install OS
    ["setup-interfaces<enter><wait1s><enter><wait1s><enter><wait1s><enter><wait1s>", "Setting up network"],
    ["rc-service networking --quiet start<enter><wait5s>", "Starting network service"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup_repo.sh<enter><wait1s>", "Download setup script"],
    ["chmod +x *.sh<enter>", "chmod the script"],
    ["./setup_repo.sh<enter><wait5s>", "Run the setup script"],

    ["setup-disk -q -m sys /dev/vda<enter><wait30s>y<enter><wait1m30s>", "Install Alpine Linux onto disk"],
    ["reboot<enter><wait1m30s>", "Reboot"],

    // Install Package
    ["root<enter><enter>", "Entering session"],
    ["setup-hostname -n localhost<enter><wait1s>", "Setting Up Hostname"],
    ["setup-interfaces<enter><wait1s><enter><wait1s><enter><wait1s><enter><wait1s>", "Setting up network"],
    ["rc-service networking --quiet start<enter><wait5s>", "Starting network service"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/setup_repo.sh<enter><wait1s>", "Download setup script"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/package.sh<enter><wait1s>", "Download package script"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/docker.sh<enter><wait1s>", "Download docker script"],
    ["wget http://{{ .HTTPIP }}:{{ .HTTPPort }}/authorized_keys<enter><wait1s>", "Download authorized_keys file"],
    ["chmod +x *.sh<enter>", "chmod the script"],
    ["./setup_repo.sh<enter><wait5s>", "Run the setup script"],
    ["./package.sh<enter><wait2m>", "Run the package script"],

    // SSH
    ["passwd<enter>root<enter>root<enter>", "Set new password to 'root'"],
    ["setup-sshd<enter><enter><wait5s>yes<enter><wait2s><enter><wait10s>", "Install OpenSSH server"],
    
  ]

  // VALIDATION
  communicator      = "ssh"
  ssh_username      = "root"
  ssh_password      = "root"
  ssh_timeout       = "1m"
  disable_vnc       = false
  shutdown_command  = "poweroff"

}

build {
  sources = ["source.qemu.alpine-workloads"]
}

packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

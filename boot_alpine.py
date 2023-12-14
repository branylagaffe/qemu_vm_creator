#!/usr/bin/env python3
"""
# 
#                      _    _                 _   _            _             
#  __      _____  _ __| | _| | ___   __ _  __| | | |_ ___  ___| |_ ___ _ __  
#  \ \ /\ / / _ \| '__| |/ / |/ _ \ / _` |/ _` | | __/ _ \/ __| __/ _ \ '__| 
#   \ V  V / (_) | |  |   <| | (_) | (_| | (_| | | ||  __/\__ \ ||  __/ |    
#    \_/\_/ \___/|_|  |_|\_\_|\___/ \__,_|\__,_|  \__\___||___/\__\___|_|    
#                                                                            
# 
# A functional test that boots an OS and run some workloads
#
# Author:
#  Bryan Perdrizat <bryan.perdrizat@epfl.ch>
"""

# import logging
import os

from avocado_qemu import QemuSystemTest, LinuxTest
from avocado_qemu import wait_for_console_pattern
# from avocado_qemu import exec_command
# from avocado.utils import process
# from avocado.utils.path import find_command


# Point toward this file

class Aarch64VirtMachine(QemuSystemTest):
    
    KERNEL_COMMON_COMMAND_LINE = 'printk.time=0 '
    QEMU_DIR = os.join(os.path.dirname(os.path.realpath(__file__)), 'build')

    timeout = 360

    # This tests the whole boot chain from EFI to Userspace
    # We only boot a whole OS for the current top level CPU and GIC
    # Other test profiles should use more minimal boots
    def test_boot(self):
        """
        :avocado: tags=arch:aarch64
        :avocado: tags=machine:virt
        :avocado: tags=accel:tcg
        """
        iso_url = ('https://dl-cdn.alpinelinux.org/'
                   'alpine/v3.18/releases/aarch64/'
                   'alpine-virt-3.18.5-aarch64.iso')

        # Alpine use sha256 so I recalculated this myself
        iso_sha1 = 'f311fe888577e111e6a72c7352bfcb3d904e389e'
        iso_path = self.fetch_asset(iso_url, asset_hash=iso_sha1)

        self.vm.set_console()
        kernel_command_line = (self.KERNEL_COMMON_COMMAND_LINE +
                               'console=ttyAMA0')
        self.require_accelerator("tcg")

        self.vm.add_args("-accel", "tcg")
        self.vm.add_args("-cpu", "max,pauth-impdef=on")
        self.vm.add_args("-machine",
                         "virt,acpi=on,"
                         "virtualization=on,"
                         "mte=on,"
                         "gic-version=max,iommu=smmuv3")
        self.vm.add_args("-smp", "2", "-m", "2048")
        self.vm.add_args("-rtc", "clock=vm")
        self.vm.add_args("-icount", "shift=0,sleep=on,align=off")
        self.vm.add_args('-bios', os.path.join(self.BUILD_DIR, 'pc-bios', 'edk2-aarch64-code.fd'))
        self.vm.add_args("-drive", f"file={iso_path},format=raw")
        self.vm.add_args('-device', 'virtio-rng-pci,rng=rng0')
        self.vm.add_args('-object', 'rng-random,id=rng0,filename=/dev/urandom')

        self.vm.launch()

        wait_for_console_pattern(self, 'Welcome to Alpine Linux 3.18',
                                 failure_message='Kernel panic - not syncing',
                                 vm=None)
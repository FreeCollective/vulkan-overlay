# Gentoo Vulkan overlay

This layer provides an attempt to get the AMD Beta drivers working on Gentoo.

## DISCLAIMER!!!!

This is a massive hack to try to get the beta driver's to work on Gentoo.

See the [issues](https://github.com/Lucretia/vulkan-overlay/issues) before attempting this.

You mess about with this at your own risk. I will not be held responsible for any system problems caused by this.

These scripts currently do **no** error checking and may fail silently.

## To download

Find a place to put the overlay and clone it, but name it *vulkan*, this is the name of the overlay, not *vulkan-overlay*. I
named it this on Github just so it didn't get confused with anything else.

```bash
git clone git@github.com:FreeCollective/vulkan-overlay.git vulkan
```

## The source

I started with [farmboy0's](https://github.com/farmboy0/portage-overlay/blob/master/x11-drivers/ati-drivers/ati-drivers-16.15.2.277429.ebuild)
ebuild, but have heavily modified it as he was installing everything and that's not required.

Once you have this overlay somewhere and you've added the following to ```/etc/portage/repos.conf/local.conf``` or similar:

```
[vulkan]
priority = 20
location = /usr/local/overlays/vulkan
masters = gentoo
auto-sync = no
```

### x11-drivers/amdgpu-pro

This is the set of libraries, GL, EGL, GLX, GBM, Vulkan, OpenCL, VDPAU, etc.

### x11-libs/libdrm

This is the userspace DRM library that the varous graphics API's call, this library then calls the kernel API's.

To get this package to work on my machine, I've had to downgrade a lot of packages due to the libdrm supplied by AMD
being based on 2.4.66 and not having a full set of drivers in there.

In your `/etc/portage/make.conf` file, set `VIDEO_CARDS="amdgpu"`, radeon and radeonsi won't let mesa build with this
package. If you want to complain about this, aim your complaints at AMD and tell them to release the source or patches
to libdrm so I can just provide a custom source ebuild.

### sys-kernel/dkms

This is Dell's DKMS program for managing dkms modules.

* Build 2.3

### sys-kernel/amdgpu-pro-dkms

This is the kernel module source for the hybrid stack, this has extra ioctl's that are required for the rest of the
stack.

* Build 16.60-379184 teested on:
  - 4.8.14 (works)
  - 4.8.17 (works)
  - 4.9.6-gentoo (crashes)
  - 4.10-rc5 (black console on boot)
* Build 16.30.3-315407 tested on:
  - 4.7.4-gentoo
  - 4.8.0-rc1
* Build 16.30.3-315407-r1 for >=sys-kernel/git-sources-4.8-rc2

DAL doesn't work here, R9 390, add `amdgpu.dal=0` to your kernel command line if you get crashes. A quick way to test
this is to go to a terminal on boot (not X) and swtich between two and if it hangs, enable the above command line option.

### media-libs/vulkan-base

This installs a basic SDK, taken from [here](https://bugs.gentoo.org/show_bug.cgi?id=574886), it's the v2 ebuild. It's
a start, but it needs a lot more work. See below.

On this ebuild, there is a new USE flag *vkheaders*, use this if you have no header conflicts with other packages.

### app-misc/vulkan-docs

Installs the developer man pages and the API specification (in PDF form).

N.B: I really wasn't sure which category this should go into.

### dev-util/spirv-tools

The SPIR-V assembler, disassembler and validator tools from Khronos.

### dev-util/spirv-cross

Tool for converting between SPIR-V <-> high level languages.

## Vulkan

IMPORTANT! To get Vulkan to work, you need to set DRI to 3! i.e. my ```/etc/X11/xorg.conf.d/10-device.conf```:

```bash
Section "Device"
	Identifier  "AMD Radeon R9 390 (Hawaii)"
	Driver      "amdgpu"
	BusID       "PCI:1:0:0"
	Option      "DRI"         "3"
	Option      "AccelMethod" "glamor"
EndSection
```

TODO: Add this into the base config.

## Roadmap

This what I really want to happen:

1. Separate the above from the Vulkan SDK ebuild.
2. Make the ebuild's use the cmake-utils.eclass.
3. Add any further samples.

## Results

The most stable combination I've managed to find so far was 4.6.0-rc7 using amdgpu-pro-dkms-16.20.3.294842**(DEPRECATED)**.

From the [16.20.3-294842](docs/results_16.20.3-294842.md) drivers.

### Stock kernels

The Stock kernel module (non-pro) with the x11-drivers 16.20.3-294842 alone does not work properly as Vulkan does not
work at all.

Using the stock kernels of 4.6.x have proven to be flaky as the standard AMDGPU driver hangs when playing videos. This
may have been due to Pulse not running, I need to try this again.

I have recompiled the amdgpu-pro-dkms-16.30.3.306809 source and patched again for 4.6.3 and then 4.7-rc5, the former
now works, but the latter still segfaults.

I am currently running 4.6.3-gentoo with the stock kernel module (non-pro) and 16.20.3-294842 x11-drivers, the cube and
triangle Vulkan demos work, the smoketest does not, exiting with:

```bash
terminate called after throwing an instance of 'std::runtime_error'
  what():  failed to find any capable Vulkan physical device
Aborted
```

Dota 2 does run in Vulkan mode.

## Contributions

Luke A. Guest
Illia D. 

Add your name here

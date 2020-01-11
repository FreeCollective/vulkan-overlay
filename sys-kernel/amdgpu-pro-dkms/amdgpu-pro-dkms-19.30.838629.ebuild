# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit eutils linux-info multilib-build unpacker versionator

DESCRIPTION="AMDGPU-PRO kernel module for AMD precompiled drivers"
HOMEPAGE="https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux"
BUILD_VER=$(replace_version_separator 2 '-')
ARC_NAME="amdgpu-pro-${BUILD_VER}-ubuntu-18.04.tar.xz"
SRC_URI="https://drivers.amd.com/drivers/linux//${BUILD_VER}/${ARC_NAME}"

RESTRICT="fetch strip"

# We cannot use dkms from within ebuild as it tries to modify the live filesystem.
LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS=""
#SLOT="1"
SLOT="${PVR}"

RDEPEND="
	>=sys-kernel/dkms-2.7
	>=sys-firmware/amdgpu-pro-ucode-${PV}
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARC_NAME}"
	einfo "from ${HOMEPAGE} and place them in ${DISTDIR}"
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*

	# Clean things up #458658.  No one seems to actually care about
	# these, so wait until someone requests to do something else ...
	rm -f debian-binary {control,data}.tar*
}

src_prepare() {
	linux-info_pkg_setup

	unpack_deb "./amdgpu-pro-${BUILD_VER}/amdgpu-pro-dkms_${BUILD_VER}_all.deb"

	pushd ./usr/src/amdgpu-pro-${BUILD_VER} > /dev/null
		epatch "${FILESDIR}"/${BUILD_VER}/0001-Gentoo-build-support.patch
	popd > /dev/null

	mkdir -p ./inst/usr/src
	cp -R ./usr/src/amdgpu-pro-${BUILD_VER} ./inst/usr/src
	#rm -rf ./{amdgpu-pro-driver,etc,lib,usr}
}

src_install() {
	cp -R -t "${D}" ./inst/* || die "Install failed!"
}

pkg_postinst() {
	einfo "To install the kernel module, you need to do the following:"
	einfo ""
	# einfo "  dkms add -m amdgpu-pro -v ${BUILD_VER}"
	# einfo "  dkms build -m amdgpu-pro -v ${BUILD_VER}"
	einfo "  dkms install -m amdgpu-pro -v ${BUILD_VER} -k ${KV_FULL}"
}

pkg_postrm() {
	einfo "If you have built and installed the kernel module, to remove it, you need to do the following:"
	einfo ""
	einfo "  dkms remove -m amdgpu-pro -v ${BUILD_VER} -k ${KV_FULL}"
	einfo ""
	einfo "If you haven't, just:"
	einfo "  rm -rf /var/lib/dkms/amdgpu-pro"
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit eutils linux-info multilib-build unpacker versionator

DESCRIPTION="AMD GPU-Pro kernel module for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Beta-Driver-for-Vulkan-Release-Notes.aspx"
BUILD_VER=$(replace_version_separator 3 '-')
SRC_URI="https://www2.ati.com/drivers/beta/amdgpu-pro_${BUILD_VER}.tar.xz"

RESTRICT="fetch strip"

# We cannot use dkms from within ebuild as it tries to modify the live filesystem.
LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS=""
SLOT="1"

RDEPEND="
	sys-kernel/dkms
"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${PN}_${PV}.tar.xz"
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

	unpack_deb "./amdgpu-pro-driver/amdgpu-pro-dkms_${BUILD_VER}_all.deb"

	pushd ./usr/src/amdgpu-pro-${BUILD_VER} > /dev/null
		epatch "${FILESDIR}"/${BUILD_VER}/0001-Find-correct-System.map.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0002-Fix-kernel-module-install-location.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0003-Add-Gentoo-as-build-option.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0004-Remove-extra-parameter-from-ttm_bo_reserve-for-4.7.0.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0005-Fix-paging-changes.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0006-Remove-first-param-from-drm_gem_object_lookup.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0007-Remove-vblank_disable_allowed-assignment.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0008-Fix-__drm_atomic_helper_connector_destroy_state-call.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0009-Remove-no_wait_gpu-from-ttm_bo_move_-functions.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0010-Change-seq_printf-format-for-64-bit-context.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0011-Fix-vblank-calls.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0012-Fix-crtc_gamma-functions-for-4.8.0.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0013-Fix-drm_atomic_helper_swap_state-for-4.8.0.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0014-Fix-bo-priv_flags-for-4.8.0.patch
		epatch "${FILESDIR}"/${BUILD_VER}/0015-Add-extra-flag-to-ttm_bo_move_ttm-for-4.8.0-rc2.patch
	popd > /dev/null

	mkdir -p ./inst/usr/src
	cp -R ./usr/src/amdgpu-pro-${BUILD_VER} ./inst/usr/src
	rm -rf ./{amdgpu-pro-driver,etc,lib,usr}
}

src_install() {
	cp -R -t "${D}" ./inst/* || die "Install failed!"
}

pkg_postinst() {
	einfo "To install the kernel module, you need to do the following:"
	einfo ""
	# einfo "  dkms add -m amdgpu-pro -v ${BUILD_VER}"
	# einfo "  dkms build -m amdgpu-pro -v ${BUILD_VER}"
	einfo "  dkms install -m amdgpu-pro -v ${BUILD_VER}"
}

pkg_postrm() {
	einfo "If you have built and installed the kernel module, to remove it, you need to do the following:"
	einfo ""
	einfo "  dkms remove -m amdgpu-pro -v ${BUILD_VER} -k ${KV_FULL}"
	einfo ""
	einfo "If you haven't, just:"
	einfo "  rm -rf /var/lib/dkms/amdgpu-pro"
}

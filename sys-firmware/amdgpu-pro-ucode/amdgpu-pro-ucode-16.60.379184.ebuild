# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit linux-info unpacker versionator

DESCRIPTION="Microcode for AMD precompiled drivers for Radeon GCN (HD7700 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Driver-for-Linux-Release-Notes.aspx"
BUILD_VER=$(replace_version_separator 2 '-')
ARC_NAME="amdgpu-pro-${BUILD_VER}.tar.xz"
SRC_URI="https://www2.ati.com/drivers/linux/ubuntu/${ARC_NAME}"

RESTRICT="fetch strip"

LICENSE="radeon-ucode"
SLOT="0"
KEYWORDS="~amd64 ~x86"

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

src_unpack() {
	unpack ${A}
	# mv linux-firmware-* "${AMDGPU_UCODE_LINUX_FIRMWARE}" || die
}

src_prepare() {
	linux-info_pkg_setup

	unpack_deb "./amdgpu-pro-${BUILD_VER}/amdgpu-pro-dkms_${BUILD_VER}_all.deb"
}

src_install() {
	local chip files legacyfiles

	pushd usr/src/amdgpu-pro-${BUILD_VER}/firmware || die

	pushd radeon || die
	radeonfiles+=( *.bin )
	insinto /lib/firmware/amdgpu-pro-${BUILD_VER}/radeon
	doins ${radeonfiles[@]}
	popd

	pushd amdgpu
	files=( *.bin )
	insinto /lib/firmware/amdgpu-pro-${BUILD_VER}/amdgpu
	doins ${files[@]}
	popd

	FILES=( ${files[@]/#/amdgpu-pro-${BUILD_VER}/amdgpu/} ${radeonfiles[@]/#/amdgpu-pro-${BUILD_VER}/radeon/} )
}

pkg_postinst() {
	if linux_config_exists && linux_chkconfig_builtin DRM_AMDGPU; then
		if ! linux_chkconfig_present FIRMWARE_IN_KERNEL || \
			! [[ "$(linux_chkconfig_string EXTRA_FIRMWARE)" == *_rlc.bin* ]]; then
			ewarn "Your kernel has amdgpu DRM built-in but not the microcode."
			ewarn "For kernel modesetting to work, please set in kernel config"
			ewarn "CONFIG_FIRMWARE_IN_KERNEL=y"
			ewarn "CONFIG_EXTRA_FIRMWARE_DIR=\"/lib/firmware\""
			ewarn "CONFIG_EXTRA_FIRMWARE=\"${FILES[@]}\""
			ewarn "You may skip microcode files for which no hardware is installed."
			ewarn "More information at https://wiki.gentoo.org/wiki/AMDGPU#Firmware"
		fi
	fi
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

#XORG_MULTILIB=yes
#inherit xorg-2 unpacker
inherit multilib-build unpacker

DESCRIPTION="X.Org libdrm library (amdgpu-pro binary)"
#HOMEPAGE="https://dri.freedesktop.org/"
#DESCRIPTION="AMD precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Beta-Driver-for-Vulkan-Release-Notes.aspx"
PKG_VER=16.40
PKG_REV=348864
PKG_VER_STRING=${PKG_VER}-${PKG_REV}
BUILD_VER=${PKG_VER}.${PKG_REV}
LIBDRM_VER=2.4.66-${PKG_REV}
ARCH_NAME="amdgpu-pro-${PKG_VER_STRING}.tar.xz"
SRC_URI="https://www2.ati.com/drivers/beta/${ARCH_NAME}"

# TODO: Is this correct? What about mixed systems?
VIDEO_CARDS="amdgpu exynos freedreno intel nouveau omap radeon tegra vc4 vmware"
for card in ${VIDEO_CARDS}; do
		IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="abi_x86_32 ${IUSE_VIDEO_CARDS} libkms valgrind"
RESTRICT="fetch test" # see bug #236845

SLOT="0"

RDEPEND=">=dev-libs/libpthread-stubs-0.3-r1:=[${MULTILIB_USEDEP}]
	abi_x86_32? ( !app-emulation/emul-linux-x86-opengl[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	valgrind? ( dev-util/valgrind )"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARCH_NAME}"
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
	default

	unpack_deb "./amdgpu-pro-driver/libdrm2-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-dev_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-tools_${PKG_VER_STRING}_amd64.deb"

	if use abi_x86_32 ; then
		unpack_deb "./amdgpu-pro-driver/libdrm2-amdgpu-pro_${PKG_VER_STRING}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${PKG_VER_STRING}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-dev_${PKG_VER_STRING}_i386.deb"
	fi
}

src_prepare() {
	# if [[ ${PV} = 9999* ]]; then
	# 	# tests are restricted, no point in building them
	# 	sed -ie 's/tests //' "${S}"/Makefile.am
	# fi
	# xorg-2_src_prepare

	# Unpack the deb's.

	# Create /usr/lib64/pkgconfig/* files
	cat << EOF > "${T}/libdrm_amdgpu.pc.64" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib64
includedir=\${prefix}/include

Name: libdrm_amdgpu
Description: Userspace interface to kernel DRM services for amdgpu
Version: 2.4.66
Libs: -L\${libdir} -ldrm_amdgpu
Cflags: -I\${includedir} -I\${includedir}/libdrm
Requires.private: libdrm
EOF

	cat << EOF > "${T}/libdrm.pc.64" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib64
includedir=\${prefix}/include

Name: libdrm
Description: Userspace interface to kernel DRM services
Version: 2.4.66
Libs: -L\${libdir} -ldrm
Cflags: -I\${includedir} -I\${includedir}/libdrm
EOF

	cat << EOF > "${T}/libkms.pc.64" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib64
includedir=\${prefix}/include

Name: libkms
Description: Library that abstract aways the different mm interface for kernel drivers
Version: 1.0.0
Libs: -L\${libdir} -lkms
Cflags: -I\${includedir}/libkms
Requires.private: libdrm
EOF

	# Create /usr/lib632/pkgconfig/* files
	cat << EOF > "${T}/libdrm_amdgpu.pc.32" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib32
includedir=\${prefix}/include

Name: libdrm_amdgpu
Description: Userspace interface to kernel DRM services for amdgpu
Version: 2.4.66
Libs: -L\${libdir} -ldrm_amdgpu
Cflags: -I\${includedir} -I\${includedir}/libdrm
Requires.private: libdrm
EOF

	cat << EOF > "${T}/libdrm.pc.32" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib32
includedir=\${prefix}/include

Name: libdrm
Description: Userspace interface to kernel DRM services
Version: 2.4.66
Libs: -L\${libdir} -ldrm
Cflags: -I\${includedir} -I\${includedir}/libdrm
EOF

	cat << EOF > "${T}/libkms.pc.32" || die
prefix=/usr
exec_prefix=\${prefix}
libdir=/usr/lib32
includedir=\${prefix}/include

Name: libkms
Description: Library that abstract aways the different mm interface for kernel drivers
Version: 1.0.0
Libs: -L\${libdir} -lkms
Cflags: -I\${includedir}/libkms
Requires.private: libdrm
EOF
}

src_install() {
	dobin usr/bin/{amdgpu_test,kmstest,modeprint,modetest,proptest,vbltest}

	insinto /usr/$(get_libdir)/pkgconfig
	newins "${T}/libdrm_amdgpu.pc.64" "libdrm_amdgpu.pc"
	newins "${T}/libdrm.pc.64" "libdrm.pc"
	newins "${T}/libkms.pc.64" "libkms.pc"

	if use abi_x86_32 ; then
		insinto /usr/lib32/pkgconfig
		newins "${T}/libdrm_amdgpu.pc.32" "libdrm_amdgpu.pc"
		newins "${T}/libdrm.pc.32" "libdrm.pc"
		newins "${T}/libkms.pc.32" "libkms.pc"
	fi

	insinto /usr/include
	doins -r usr/include/amdgpu-pro/xf86drmMode.h
	doins -r usr/include/amdgpu-pro/xf86drm.h

	doins -r usr/include/amdgpu-pro/libdrm
	doins -r usr/include/amdgpu-pro/libkms

	exeinto /usr/$(get_libdir)
	doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
	dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/libdrm_amdgpu.so.1
	dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/libdrm_amdgpu.so

	doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libdrm.so.2.4.0
	dosym libdrm.so.2.4.0 /usr/$(get_libdir)/libdrm.so.2
	dosym libdrm.so.2.4.0 /usr/$(get_libdir)/libdrm.so

	doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libkms.so.1.0.0
	dosym libkms.so.1.0.0 /usr/$(get_libdir)/libkms.so.1

	if use abi_x86_32 ; then
		exeinto /usr/lib32
		doexe usr/lib/i386-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
		dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/libdrm_amdgpu.so.1
		dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/libdrm_amdgpu.so

		doexe usr/lib/i386-linux-gnu/amdgpu-pro/libdrm.so.2.4.0
		dosym libdrm.so.2.4.0 /usr/lib32/libdrm.so.2
		dosym libdrm.so.2.4.0 /usr/lib32/libdrm.so

		doexe usr/lib/i386-linux-gnu/amdgpu-pro/libkms.so.1.0.0
		dosym libkms.so.1.0.0 /usr/lib32/libkms.so.1
	fi
}

src_configure() {
	einfo "no configure step"
	# XORG_CONFIGURE_OPTIONS=(
	# 	# Udev is only used by tests now.
	# 	--disable-udev
	# 	--disable-cairo-tests
	# 	$(use_enable video_cards_amdgpu amdgpu)
	# 	$(use_enable video_cards_exynos exynos-experimental-api)
	# 	$(use_enable video_cards_freedreno freedreno)
	# 	$(use_enable video_cards_intel intel)
	# 	$(use_enable video_cards_nouveau nouveau)
	# 	$(use_enable video_cards_omap omap-experimental-api)
	# 	$(use_enable video_cards_radeon radeon)
	# 	$(use_enable video_cards_tegra tegra-experimental-api)
	# 	$(use_enable video_cards_vc4 vc4)
	# 	$(use_enable video_cards_vmware vmwgfx)
	# 	$(use_enable libkms)
	# 	# valgrind installs its .pc file to the pkgconfig for the primary arch
	# 	--enable-valgrind=$(usex valgrind auto no)
	# )

	# xorg-2_src_configure

	# Copy the binary files to the correct places.
}

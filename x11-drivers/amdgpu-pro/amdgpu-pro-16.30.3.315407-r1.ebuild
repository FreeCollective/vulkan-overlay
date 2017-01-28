# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )
#inherit eutils linux-info multilib-build unpacker
inherit multilib-build unpacker versionator

DESCRIPTION="AMD precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Beta-Driver-for-Vulkan-Release-Notes.aspx"
PKG_VER_STRING=$(replace_version_separator 3 '-')
SRC_URI="https://www2.ati.com/drivers/beta/amdgpu-pro_${PKG_VER_STRING}.tar.xz"

RESTRICT="fetch strip"

# The binary blobs include binaries for other open sourced packages, we don't want to include those parts, if they are
# selected, they should come from portage.
IUSE="gles2 opencl +opengl vdpau +vulkan"

LICENSE="AMD GPL-2 QPL-1.0"
KEYWORDS="~amd64"
SLOT="1"

RDEPEND="
	>=app-eselect/eselect-opengl-1.0.7
	app-eselect/eselect-opencl
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXinerama[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	x11-proto/inputproto
	x11-proto/xf86miscproto
	x11-proto/xf86vidmodeproto
	x11-proto/xineramaproto
"
DEPEND="
	=x11-libs/libdrm-2.4.66-r1
	=sys-kernel/amdgpu-pro-dkms-${PV}-r1
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

src_unpack() {
	default

	unpack_deb "./amdgpu-pro-driver/amdgpu-pro-core_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/amdgpu-pro-graphics_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-tools_${PKG_VER_STRING}_amd64.deb"

	if use opencl ; then
		# Install the clinfo tool.
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-clinfo_${PKG_VER_STRING}_amd64.deb"

		# Install the actual shared OpenCL lib - this uses the icd files to find the correct lib.
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl1_${PKG_VER_STRING}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl-dev_${PKG_VER_STRING}_amd64.deb"

		# Install the Installable Client Driver (ICD).
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-opencl-icd_${PKG_VER_STRING}_amd64.deb"

		if use abi_x86_32 ; then
			# Install the actual shared OpenCL lib - this uses the icd files to find the correct lib.
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl1_${PKG_VER_STRING}_i386.deb"
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-libopencl-dev_${PKG_VER_STRING}_i386.deb"

			# Install the Installable Client Driver (ICD).
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-opencl-icd_${PKG_VER_STRING}_i386.deb"
		fi
	fi

	if use vulkan ; then
		# Install the actual vulkan ICD.
		unpack_deb "./amdgpu-pro-driver/amdgpu-pro-vulkan-driver_${PKG_VER_STRING}_amd64.deb"

		if use abi_x86_32 ; then
			# Install the actual vulkan ICD.
			unpack_deb "./amdgpu-pro-driver/amdgpu-pro-vulkan-driver_${PKG_VER_STRING}_i386.deb"
		fi

		#chmod -x ./etc/vulkan/icd.d/*
		#rm -rf ./usr/lib
	fi

	if use opengl ; then
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dev_${PKG_VER_STRING}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dri_${PKG_VER_STRING}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-glx_${PKG_VER_STRING}_amd64.deb"
		# unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${PKG_VER_STRING}_amd64.deb"
		# unpack_deb "./amdgpu-pro-driver/libdrm2-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"

		# Install the Generic Buffer Management (BGM) library
		# TODO: This is going to require that the eselect program moves the gbm libs
		unpack_deb "./amdgpu-pro-driver/libgbm1-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dev_${PKG_VER_STRING}_i386.deb"
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-dri_${PKG_VER_STRING}_i386.deb"
			unpack_deb "./amdgpu-pro-driver/libgl1-amdgpu-pro-glx_${PKG_VER_STRING}_i386.deb"
			# unpack_deb "./amdgpu-pro-driver/libdrm-amdgpu-pro-amdgpu1_${PKG_VER_STRING}_i386.deb"

			# Install the Generic Buffer Management (BGM) library
			# TODO: This is going to require that the eselect program moves the gbm libs
			unpack_deb "./amdgpu-pro-driver/libgbm1-amdgpu-pro_${PKG_VER_STRING}_i386.deb"
		fi
	fi

	if use gles2 ; then
		unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"
		unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro-dev_${PKG_VER_STRING}_amd64.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro_${PKG_VER_STRING}_i386.deb"
			unpack_deb "./amdgpu-pro-driver/libgles2-amdgpu-pro-dev_${PKG_VER_STRING}_i386.deb"
		fi
	fi

	# Install the EGL libs
	unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"
	unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro-dev_${PKG_VER_STRING}_amd64.deb"

	if use abi_x86_32 ; then
		unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro_${PKG_VER_STRING}_i386.deb"
		unpack_deb "./amdgpu-pro-driver/libegl1-amdgpu-pro-dev_${PKG_VER_STRING}_i386.deb"
	fi

	if use vdpau ; then
		unpack_deb "./amdgpu-pro-driver/libvdpau-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"

		# No x86 version of this lib for some reason.
	fi

	# Install the X modules. No x86 version of this lib for some reason.
	unpack_deb "./amdgpu-pro-driver/xserver-xorg-video-amdgpu-pro_${PKG_VER_STRING}_amd64.deb"

	# Install the DKMS sources.
	# unpack_deb "./amdgpu-pro-driver/amdgpu-pro-dkms_${PKG_VER_STRING}_all.deb"
}

src_prepare() {
	# pushd ./usr/src/amdgpu-pro-${PKG_VER_STRING} > /dev/null
	# 	epatch "${FILESDIR}"/0001-Make-the-script-find-the-correct-system-map-file.patch
	# 	epatch "${FILESDIR}"/0002-Add-in-Gentoo-as-an-option-for-the-OS-otherwise-it-w.patch
	# 	epatch "${FILESDIR}"/0003-Fixed-API-changes-in-the-kernel.-Should-still-compil.patch
	# 	epatch "${FILESDIR}"/0004-GCC-won-t-compile-any-static-inline-function-with-va.patch
	# popd > /dev/null
	cat << EOF > "${T}/01-amdgpu-pro.conf" || die
/usr/$(get_libdir)/gbm
/usr/lib32/gbm
EOF

	cat << EOF > "${T}/10-device.conf" || die
Section "Device"
	Identifier  "Name of your GPU"
	Driver      "amdgpu"
	BusID       "PCI:1:0:0"
	Option      "DRI"         "3"
	Option      "AccelMethod" "glamor"
EndSection
EOF

	cat << EOF > "${T}/10-screen.conf" || die
Section "Screen"
		Identifier      "Your screen name"
		DefaultDepth    24
		SubSection      "Display"
				Depth   24
		EndSubSection
EndSection
EOF

	cat << EOF > "${T}/10-monitor.conf" || die
Section "Monitor"
	Identifier   "Your monitor name"
	VendorName   "The make"
	ModelName    "The model"
	Option       "DPMS"   "true" # Might want to turn this off if using an R9 390
EndSection
EOF

	if use vulkan ; then
		cat << EOF > "${T}/amd_icd64.json" || die
{
   "file_format_version": "1.0.0",
	   "ICD": {
		   "library_path": "/usr/$(get_libdir)/vulkan/vendors/amdgpu-pro/amdvlk64.so",
		   "abi_versions": "0.9.0"
	   }
}
EOF

		if use abi_x86_32 ; then
			cat << EOF > "${T}/amd_icd32.json" || die
{
   "file_format_version": "1.0.0",
	   "ICD": {
		   "library_path": "/usr/lib32/vulkan/vendors/amdgpu-pro/amdvlk32.so",
		   "abi_versions": "0.9.0"
	   }
}
EOF
		fi
	fi

	eapply_user
}

src_install() {
	# Make our new dir tree

	newman usr/share/man/amdgpu-pro.4/amdgpu.4.gz amdgpu-pro.4.gz
#	dobin usr/bin/{amdgpu_test,kmstest,modeprint,modetest,proptest,vbltest}
	insinto /etc
	doins -r etc/{amd,gbm}

	insinto /etc/ld.so.conf.d
	doins "${T}/01-amdgpu-pro.conf"

	insinto /etc/X11/xorg.conf.d
	doins "${T}/10-screen.conf"
	doins "${T}/10-monitor.conf"
	doins "${T}/10-device.conf"

	# Copy the OpenCL libs
	if use opencl ; then
		insinto /etc/OpenCL/vendors
		doins etc/OpenCL/vendors/amdocl64.icd
		dobin usr/bin/clinfo
		exeinto /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro
		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libamdocl*
		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libOpenCL.so.1
		dosym libOpenCL.so.1 /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro/libOpenCL.so

		if use abi_x86_32 ; then
			insinto /etc/OpenCL/vendors
			doins etc/OpenCL/vendors/amdocl32.icd
			exeinto /usr/lib32/OpenCL/vendors/amdgpu-pro
			doexe usr/lib/i386-linux-gnu/amdgpu-pro/libamdocl*
			doexe usr/lib/i386-linux-gnu/amdgpu-pro/libOpenCL.so.1
			dosym libOpenCL.so.1 /usr/lib32/OpenCL/vendors/amdgpu-pro/libOpenCL.so
		fi
	fi

	# Copy the Vulkan libs
	if use vulkan ; then
		insinto /etc/vulkan/icd.d
		doins "${T}/amd_icd64.json"
		exeinto /usr/$(get_libdir)/vulkan/vendors/amdgpu-pro
		doexe usr/lib/x86_64-linux-gnu/amdvlk64.so

		if use abi_x86_32 ; then
			insinto /etc/vulkan/icd.d
			doins "${T}/amd_icd32.json"
			exeinto /usr/lib32/vulkan/vendors/amdgpu-pro
			doexe usr/lib/i386-linux-gnu/amdvlk32.so
		fi
	fi

	# Copy the OpenGL libs
	local XORG_VERS=`Xorg -version 2>&1 | awk '/X.Org X Server/ {print $NF}'|sed 's/.\{2\}$//'`

	if use opengl ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
		# doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so

		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libGL.so.1.2
		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so.1
		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so

		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libgbm.so.1.0.0
		dosym libgbm.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libgbm.so.1

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/gbm
		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/gbm/gbm_amdgpu.so
		dosym gbm_amdgpu.so /usr/$(get_libdir)/opengl/amdgpu-pro/gbm/libdummy.so
		dosym opengl/amdgpu-pro/gbm /usr/$(get_libdir)/gbm

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/extensions
		doexe "usr/lib/x86_64-linux-gnu/amdgpu-pro/${XORG_VERS}/modules/extensions/libglx.so"

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/modules/drivers
		doexe "usr/lib/x86_64-linux-gnu/amdgpu-pro/${XORG_VERS}/modules/drivers/amdgpu_drv.so"
		# # TODO Do we need the amdgpu_drv.la file?

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/dri
		doexe usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
		dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/dri/amdgpu_dri.so
		# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
		dosym ../../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/x86_64-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/lib
			# doexe usr/lib/i386-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so

			doexe usr/lib/i386-linux-gnu/amdgpu-pro/libGL.so.1.2
			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so.1
			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so

			doexe usr/lib/i386-linux-gnu/amdgpu-pro/libgbm.so.1.0.0
			dosym libgbm.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libgbm.so.1

			exeinto /usr/lib32/opengl/amdgpu-pro/gbm
			doexe usr/lib/i386-linux-gnu/amdgpu-pro/gbm/gbm_amdgpu.so
			dosym gbm_amdgpu.so /usr/lib32/opengl/amdgpu-pro/gbm/libdummy.so
			dosym opengl/amdgpu-pro/gbm /usr/lib32/gbm

			exeinto /usr/lib32/opengl/amdgpu-pro/dri
			doexe usr/lib/i386-linux-gnu/dri/amdgpu_dri.so
			dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/lib32/dri/amdgpu_dri.so
			# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
			dosym ../../../lib32/opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/i386-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!
		fi
	fi

	# Copy the GLESv2 libs
	if use gles2 ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
		doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libGLESv2.so.2
		dosym libGLESv2.so.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGLESv2.so

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/lib
			doexe usr/lib/i386-linux-gnu/amdgpu-pro/libGLESv2.so.2
			dosym libGLESv2.so.2 /usr/lib32/opengl/amdgpu-pro/lib/libGLESv2.so
		fi
	fi

	# Copy the EGL libs
	exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
	doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libEGL.so.1
	dosym libEGL.so.1 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libEGL.so

	if use abi_x86_32 ; then
		exeinto /usr/lib32/opengl/amdgpu-pro/lib
		doexe usr/lib/i386-linux-gnu/amdgpu-pro/libEGL.so.1
		dosym libEGL.so.1 /usr/lib32/opengl/amdgpu-pro/lib/libEGL.so
	fi

	# Copy the VDPAU libs
	if use vdpau ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/vdpau
		doexe usr/lib/x86_64-linux-gnu/vdpau/libvdpau_amdgpu.so.1.0.0
		dosym ../opengl/amdgpu-pro/vdpau/libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1.0.0
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1.0
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so
	fi
}

pkg_prerm() {
	einfo "pkg_prerm"
	if use opengl ; then
		"${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
	fi

	if use opencl ; then
		"${ROOT}"/usr/bin/eselect opencl set --use-old mesa
	fi
}

pkg_postinst() {
	einfo "pkg_postinst"
	if use opengl ; then
		"${ROOT}"/usr/bin/eselect opengl set --use-old amdgpu-pro
	fi

	if use opencl ; then
		"${ROOT}"/usr/bin/eselect opencl set --use-old amdgpu-pro
	fi
}

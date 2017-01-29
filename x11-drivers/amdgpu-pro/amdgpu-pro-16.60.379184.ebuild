# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

MULTILIB_COMPAT=( abi_x86_{32,64} )
#inherit eutils linux-info multilib-build unpacker
inherit multilib-build unpacker versionator

DESCRIPTION="AMD precompiled drivers for Radeon Evergreen (HD5000 Series) and newer chipsets"
HOMEPAGE="http://support.amd.com/en-us/kb-articles/Pages/AMDGPU-PRO-Driver-for-Linux-Release-Notes.aspx"
BUILD_VER=$(replace_version_separator 2 '-')
BUILD_MINOR_REV=$(get_version_component_range 3)
ARC_NAME="amdgpu-pro-${BUILD_VER}.tar.xz"
SRC_URI="https://www2.ati.com/drivers/linux/ubuntu/${ARC_NAME}"

RESTRICT="fetch strip"

# The binary blobs include binaries for other open sourced packages, we don't want to include those parts, if they are
# selected, they should come from portage.
IUSE="gles2 opencl +opengl vdpau +vulkan openmax"

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
	=x11-libs/libdrm-2.4.70-r1
	=sys-kernel/amdgpu-pro-dkms-${PV}
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

src_unpack() {
	default

	if use opencl ; then
		# Install the clinfo tool.
		unpack_deb "./amdgpu-pro-${BUILD_VER}/clinfo-amdgpu-pro_${BUILD_VER}_amd64.deb"

		# Install the actual shared OpenCL lib - this uses the icd files to find the correct lib.
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libopencl1-amdgpu-pro_${BUILD_VER}_amd64.deb"

		# Install the Installable Client Driver (ICD).
		unpack_deb "./amdgpu-pro-${BUILD_VER}/opencl-amdgpu-pro-icd_${BUILD_VER}_amd64.deb"

		if use abi_x86_32 ; then
			# Install the actual shared OpenCL lib - this uses the icd files to find the correct lib.
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libopencl1-amdgpu-pro_${BUILD_VER}_i386.deb"

			# Install the Installable Client Driver (ICD).
			unpack_deb "./amdgpu-pro-${BUILD_VER}/opencl-amdgpu-pro-icd_${BUILD_VER}_i386.deb"
		fi
	fi

	if use vulkan ; then
		# Install the actual vulkan ICD.
		unpack_deb "./amdgpu-pro-${BUILD_VER}/vulkan-amdgpu-pro_${BUILD_VER}_amd64.deb"

		if use abi_x86_32 ; then
			# Install the actual vulkan ICD.
			unpack_deb "./amdgpu-pro-${BUILD_VER}/vulkan-amdgpu-pro_${BUILD_VER}_i386.deb"
		fi

		#chmod -x ./etc/vulkan/icd.d/*
		#rm -rf ./usr/lib
	fi

	if use opengl ; then
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-appprofiles_${BUILD_VER}_all.deb"
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-dri_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-ext_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-glx_${BUILD_VER}_amd64.deb"

		# Install the Generic Buffer Management (BGM) library
		# TODO: This is going to require that the eselect program moves the gbm libs
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro_${BUILD_VER}_amd64.deb"
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro-base_${BUILD_VER}_all.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-dri_${BUILD_VER}_i386.deb"
			# unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-ext_${BUILD_VER}_i386.deb"
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libgl1-amdgpu-pro-glx_${BUILD_VER}_i386.deb"

			# Install the Generic Buffer Management (BGM) library
			# TODO: This is going to require that the eselect program moves the gbm libs
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libgbm1-amdgpu-pro_${BUILD_VER}_i386.deb"
		fi
	fi

	if use gles2 ; then
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libgles2-amdgpu-pro_${BUILD_VER}_amd64.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libgles2-amdgpu-pro_${BUILD_VER}_i386.deb"
		fi
	fi

	# Install the EGL libs
	unpack_deb "./amdgpu-pro-${BUILD_VER}/libegl1-amdgpu-pro_${BUILD_VER}_amd64.deb"

	if use abi_x86_32 ; then
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libegl1-amdgpu-pro_${BUILD_VER}_i386.deb"
	fi

	# Install the VDPAU libs
	if use vdpau ; then
		unpack_deb "./amdgpu-pro-${BUILD_VER}/libvdpau-amdgpu-pro_12.0.3-${BUILD_MINOR_REV}_amd64.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-${BUILD_VER}/libvdpau-amdgpu-pro_12.0.3-${BUILD_MINOR_REV}_i386.deb"
		fi
	fi

	# Install the Open MAX libs
	if use openmax ; then
		unpack_deb "./amdgpu-pro-${BUILD_VER}/gst-omx-amdgpu-pro_1.0.0.1-${BUILD_MINOR_REV}_amd64.deb"
		unpack_deb "./amdgpu-pro-${BUILD_VER}/mesa-amdgpu-pro-omx-drivers_12.0.3-${BUILD_MINOR_REV}_amd64.deb"

		if use abi_x86_32 ; then
			unpack_deb "./amdgpu-pro-${BUILD_VER}/gst-omx-amdgpu-pro_1.0.0.1-${BUILD_MINOR_REV}_i386.deb"
			unpack_deb "./amdgpu-pro-${BUILD_VER}/mesa-amdgpu-pro-omx-drivers_12.0.3-${BUILD_MINOR_REV}_i386.deb"
		fi
	fi

	# Install the X modules. No x86 version of this lib for some reason.
	unpack_deb "./amdgpu-pro-${BUILD_VER}/xserver-xorg-video-amdgpu-pro_1.2.99-${BUILD_MINOR_REV}_amd64.deb"
	unpack_deb "./amdgpu-pro-${BUILD_VER}/xserver-xorg-video-modesetting-amdgpu-pro_1.18.3-${BUILD_MINOR_REV}_amd64.deb"
}

src_prepare() {
	# pushd ./usr/src/amdgpu-pro-${BUILD_VER} > /dev/null
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

	newman opt/amdgpu-pro/share/man/man4/amdgpu.4 amdgpu-pro.4
	newman opt/amdgpu-pro/share/man/man4/modesetting.4 modesetting-amdgpu-pro.4
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
		dobin opt/amdgpu-pro/bin/{clinfo,amdgpu-pro-px}
		exeinto /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libamdocl64.so
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libOpenCL.so.1
		dosym libOpenCL.so.1 /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro/libOpenCL.so

		if use abi_x86_32 ; then
			insinto /etc/OpenCL/vendors
			doins etc/OpenCL/vendors/amdocl32.icd
			exeinto /usr/lib32/OpenCL/vendors/amdgpu-pro
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libamdocl32.so
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libOpenCL.so.1
			dosym libOpenCL.so.1 /usr/lib32/OpenCL/vendors/amdgpu-pro/libOpenCL.so
		fi
	fi

	# Copy the Vulkan libs
	if use vulkan ; then
		insinto /etc/vulkan/icd.d
		doins "${T}/amd_icd64.json"
		exeinto /usr/$(get_libdir)/vulkan/vendors/amdgpu-pro
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/amdvlk64.so

		if use abi_x86_32 ; then
			insinto /etc/vulkan/icd.d
			doins "${T}/amd_icd32.json"
			exeinto /usr/lib32/vulkan/vendors/amdgpu-pro
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/amdvlk32.so
		fi
	fi

	# Copy the OpenGL libs
	#local XORG_VERS=`Xorg -version 2>&1 | awk '/X.Org X Server/ {print $NF}'|sed 's/.\{2\}$//'`

	if use opengl ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
		# doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so

		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libGL.so.1.2
		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so.1
		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so

		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libgbm.so.1.0.0
		dosym libgbm.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libgbm.so.1
		dosym libgbm.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libgbm.so

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/gbm
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/gbm/gbm_amdgpu.so
		dosym gbm_amdgpu.so /usr/$(get_libdir)/opengl/amdgpu-pro/gbm/libdummy.so
		dosym opengl/amdgpu-pro/gbm /usr/$(get_libdir)/gbm

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/extensions
		doexe opt/amdgpu-pro/lib/xorg/modules/extensions/libglx.so

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/modules/drivers
		doexe opt/amdgpu-pro/lib/xorg/modules/drivers/amdgpu_drv.so
		doexe opt/amdgpu-pro/lib/xorg/modules/drivers/modesetting_drv.so
		# # TODO Do we need the amdgpu_drv.la file?

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/dri
		doexe usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/dri/radeonsi_drv_video.so
		dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/dri/amdgpu_dri.so
		dosym ../opengl/amdgpu-pro/dri/radeonsi_drv_video.so /usr/$(get_libdir)/dri/radeonsi_drv_video.so
		# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
		#TODO: Do we still need this next line?
		#dosym ../../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/x86_64-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/lib
			# doexe usr/lib/i386-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so

			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libGL.so.1.2
			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so.1
			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so

			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libgbm.so.1.0.0
			dosym libgbm.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libgbm.so.1
			dosym libgbm.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libgbm.so

			exeinto /usr/lib32/opengl/amdgpu-pro/gbm
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/gbm/gbm_amdgpu.so
			dosym gbm_amdgpu.so /usr/lib32/opengl/amdgpu-pro/gbm/libdummy.so
			dosym opengl/amdgpu-pro/gbm /usr/lib32/gbm

			exeinto /usr/lib32/opengl/amdgpu-pro/dri
			doexe usr/lib/i386-linux-gnu/dri/amdgpu_dri.so
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/dri/radeonsi_drv_video.so
			dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/lib32/dri/amdgpu_dri.so
			dosym ../opengl/amdgpu-pro/dri/radeonsi_drv_video.so /usr/lib32/dri/radeonsi_drv_video.so
			# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
			#TODO: Do we still need this next line?
			#dosym ../../../lib32/opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/i386-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!
		fi
	fi

	# Copy the GLESv2 libs
	if use gles2 ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libGLESv2.so.2
		dosym libGLESv2.so.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGLESv2.so

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/lib
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libGLESv2.so.2
			dosym libGLESv2.so.2 /usr/lib32/opengl/amdgpu-pro/lib/libGLESv2.so
		fi
	fi

	# Copy the EGL libs
	exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libEGL.so.1
	dosym libEGL.so.1 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libEGL.so

	if use abi_x86_32 ; then
		exeinto /usr/lib32/opengl/amdgpu-pro/lib
		doexe opt/amdgpu-pro/lib/i386-linux-gnu/libEGL.so.1
		dosym libEGL.so.1 /usr/lib32/opengl/amdgpu-pro/lib/libEGL.so
	fi

	# Copy the VDPAU libs
	if use vdpau ; then
		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/vdpau
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/vdpau/libvdpau_amdgpu.so.1.0.0
		dosym ../opengl/amdgpu-pro/vdpau/libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1.0.0
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1.0
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so.1
		dosym libvdpau_amdgpu.so.1.0.0 /usr/$(get_libdir)/vdpau/libvdpau_amdgpu.so

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/vdpau
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/vdpau/libvdpau_amdgpu.so.1.0.0
			dosym ../opengl/amdgpu-pro/vdpau/libvdpau_amdgpu.so.1.0.0 /usr/lib32/vdpau/libvdpau_amdgpu.so.1.0.0
			dosym libvdpau_amdgpu.so.1.0.0 /usr/lib32/vdpau/libvdpau_amdgpu.so.1.0
			dosym libvdpau_amdgpu.so.1.0.0 /usr/lib32/vdpau/libvdpau_amdgpu.so.1
			dosym libvdpau_amdgpu.so.1.0.0 /usr/lib32/vdpau/libvdpau_amdgpu.so
		fi
	fi

	if use openmax ; then
		insinto /etc
		doins -r etc/xdg

		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/gstreamer-1.0
		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/gstreamer-1.0/libgstomx.so
		dosym ../opengl/amdgpu-pro/gstreamer-1.0/libgstomx.so /usr/$(get_libdir)/gstreamer-1.0/libgstomx.so

		# exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/libomxil-bellagio0
		# doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libomxil-bellagio0/libomx_mesa.so
		# dosym ../opengl/amdgpu-pro/libomxil-bellagio0/libomx_mesa.so /usr/$(get_libdir)/libomxil-bellagio0/libomx_mesa.so

		if use abi_x86_32 ; then
			exeinto /usr/lib32/opengl/amdgpu-pro/gstreamer-1.0
			doexe opt/amdgpu-pro/lib/i386-linux-gnu/gstreamer-1.0/libgstomx.so
			dosym ../opengl/amdgpu-pro/gstreamer-1.0/libgstomx.so /usr/lib32/gstreamer-1.0/libgstomx.so

		# 	exeinto /usr/lib32/opengl/amdgpu-pro/libomxil-bellagio0
		# 	doexe opt/amdgpu-pro/lib/i386-linux-gnu/libomxil-bellagio0/libomx_mesa.so
		# 	dosym ../opengl/amdgpu-pro/libomxil-bellagio0/libomx_mesa.so /usr/lib32/libomxil-bellagio0/libomx_mesa.so
		fi
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

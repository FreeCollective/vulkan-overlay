EAPI=6

inherit git-r3

DESCRIPTION="Official Vulkan man pages and specification"
HOMEPAGE="https://github.com/KhronosGroup/Vulkan-Docs"
SRC_URI=""
EGIT_REPO_URI="https://github.com/KhronosGroup/Vulkan-Docs.git"

LICENSE="Apache-2.0"
IUSE=""
SLOT="0"

KEYWORDS="~amd64"

DEPEND="app-text/dblatex
		app-text/asciidoc
		dev-util/source-highlight"

src_unpack() {
	git-r3_fetch ${EGIT_REPO_URI}
	git-r3_checkout ${EGIT_REPO_URI} "${S}"/Vulkan-Docs
}

src_compile() {
	einfo "Building Vulkan documentation"
	cd "${S}"/Vulkan-Docs/doc/specs/vulkan
	emake manpages || die "Cannot build Vulkan man pages"
	emake pdf || die "Cannot build Vulkan spec"
}

src_install() {
	cd "${S}"/Vulkan-Docs/out/1.0/man
	doman */*

	dodoc "${S}"/Vulkan-Docs/out/1.0/pdf/vkspec.pdf
}

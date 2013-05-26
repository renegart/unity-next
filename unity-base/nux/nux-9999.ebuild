# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools base eutils bzr ubuntu-versionator xdummy

GTESTVER="1.6.0"

DESCRIPTION="Visual rendering toolkit for the Unity desktop"
HOMEPAGE="http://launchpad.net/nux"

SRC_URI="test? ( http://googletest.googlecode.com/files/gtest-${GTESTVER}.zip )"	# SRC_URI must be set before EBZR_REPO_URI
EBZR_PROJECT="${PN}"
EBZR_BRANCH="trunk"
EBZR_REPO_URI="lp:${PN}"

LICENSE="GPL-3 LGPL-3"
SLOT="0/4"
KEYWORDS=""
IUSE="debug doc examples test"

RDEPEND="!unity-base/utouch-geis"
DEPEND="app-i18n/ibus
	dev-libs/boost
	>=dev-libs/glib-2.32.3
	dev-libs/libsigc++:2
	gnome-base/gnome-common
	<media-libs/glew-1.8
	>=sys-devel/gcc-4.6
	unity-base/geis
	x11-libs/gdk-pixbuf
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXxf86vm
	x11-libs/pango
	x11-proto/dri2proto
	x11-proto/glproto
	doc? ( app-doc/doxygen )
	test? ( dev-cpp/gtest )"

src_prepare() {
	if [[ ( $(gcc-major-version) -eq 4 && $(gcc-minor-version) -lt 6 ) ]]; then
		die "${P} requires an active >=gcc:4.6, please consult the output of 'gcc-config -l'"
	fi

	./autogen.sh ${myconf}	# eautoreconf fails

	# Fix building with libgeis #
	sed -e "s:libutouch-geis:libgeis:g" \
		-i configure \
			NuxGraphics/nux-graphics.pc.in
}

src_configure() {
	use debug && \
		myconf="${myconf}
			--enable-debug=yes"
	use doc && \
		myconf="${myconf}
			--enable-documentation=yes"

	! use examples && \
		myconf="${myconf}
			--enable-examples=no"
	if use test; then
		myconf="${myconf}
			--with-gtest-source-path="${WORKDIR}/gtest-${GTESTVER}""
	else
		myconf="${myconf}
			--enable-tests=no
			--enable-gputests=no"
	fi

	econf ${myconf}
}

src_test() {
	local XDUMMY_COMMAND="make check"
	xdummymake
}

src_install() {
	emake DESTDIR="${D}" install || die
	dosym /usr/libexec/nux/unity_support_test /usr/lib/nux/unity_support_test

	prune_libtool_files --modules
}

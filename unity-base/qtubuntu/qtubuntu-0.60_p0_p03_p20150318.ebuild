# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

URELEASE="vivid"
inherit qt5-build gnome2-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/universe/q/${PN}"
UVER_PREFIX="+${UVER_RELEASE}.${PVR_MICRO}"

DESCRIPTION="Qt plugins for Ubuntu Platform API (desktop)"
HOMEPAGE="https://launchpad.net/qtubuntu"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtdbus:5
	dev-qt/qtgui:5[egl,eglfs,evdev,gles2,opengl]
	dev-qt/qtsensors:5
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa[egl,gles2]
	mir-base/mir
	mir-base/platform-api"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"
QT5_BUILD_DIR="${S}"

src_prepare() {
	qt5-build_src_prepare
	export PATH="${QT5_BINDIR}:${PATH}"
}

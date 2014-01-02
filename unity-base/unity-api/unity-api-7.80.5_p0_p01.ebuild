# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/universe/u/${PN}"
URELEASE="trusty"
UVER_PREFIX="+14.04.20131219.1"

DESCRIPTION="API for Unity shell integration"
HOMEPAGE="https://launchpad.net/unity-api"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"
RESTRICT="mirror"

DEPEND="dev-libs/boost
	dev-libs/glib:2
	test? ( dev-util/cppcheck )"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"
export PATH="${PATH}:/usr/$(get_libdir)/qt5/bin"

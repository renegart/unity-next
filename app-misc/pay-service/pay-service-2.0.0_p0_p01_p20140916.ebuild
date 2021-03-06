# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

URELEASE="vivid"
inherit cmake-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/universe/p/${PN}"
UVER_PREFIX="+14.10.${PVR_MICRO}"

DESCRIPTION="Service to allow requesting payment for an item"
HOMEPAGE="http://launchpad.net/pay-service"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

DEPEND="dev-libs/glib:2
	dev-libs/libubuntu-app-launch
	dev-libs/process-cpp
	dev-libs/properties-cpp
	dev-qt/qtcore:5
	dev-qt/qtdeclarative:5
	net-libs/ubuntuone-credentials
	net-misc/curl
	sys-apps/click
	x11-libs/libaccounts-qt[qt5]"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

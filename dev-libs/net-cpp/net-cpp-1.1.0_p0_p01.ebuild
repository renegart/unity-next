# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/main/n/${PN}"
URELEASE="utopic"
UVER_PREFIX="+14.10.20140804"

DESCRIPTION="C++11 library for networking processes"
HOMEPAGE="http://launchpad.net/net-cpp"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="mirror"

RDEPEND="dev-libs/boost:="
DEPEND="dev-libs/boost
	dev-libs/jsoncpp
	dev-libs/process-cpp
	net-misc/curl"

S="${WORKDIR}/${PN}-${PV}${UVER_PREFIX}"

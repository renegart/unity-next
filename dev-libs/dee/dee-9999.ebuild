# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} )

VALA_MIN_API_VERSION="0.20"
VALA_USE_DEPEND="vapigen"

AUTOTOOLS_AUTORECONF=y

inherit autotools-utils eutils python-r1 bzr ubuntu-versionator vala

MY_P="${PN}_${PV}"
S="${WORKDIR}/${PN}-${PV}"

DESCRIPTION="Provide objects allowing to create Model-View-Controller type programs across DBus"
HOMEPAGE="https://launchpad.net/dee/"
EBZR_PROJECT="${PN}"
EBZR_BRANCH="trunk"
EBZR_REPO_URI="lp:${PN}"

SLOT="0/4.2.1"
LICENSE="GPL-3"
KEYWORDS=""
IUSE="doc debug examples +icu static-libs test"
RESTRICT="mirror"

RDEPEND="dev-libs/glib:2
	dev-libs/icu"
DEPEND="${RDEPEND}
	dev-util/gtk-doc
	test? ( dev-util/dbus-test-runner )
	$(vala_depend)"

src_prepare() {
        vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
        autotools-utils_src_prepare
}

src_configure() {
	local myeconfargs=(
		--disable-silent-rules
		$(use_enable debug trace-log)
		$(use_enable doc gtk-doc)
		$(use_enable icu)
		$(use_enable test tests)
#		$(use_enable test extended-tests)
		)
	autotools-utils_src_configure
	python_copy_sources
}

src_compile() {
	autotools-utils_src_compile

	compilation() {
		cd bindings || die
		emake \
			pyexecdir="$(python_get_sitedir)"
	}
	python_foreach_impl run_in_build_dir compilation
}

src_install() {
	autotools-utils_src_install

	if use examples; then
		insinto /usr/share/doc/${PN}/
		doins -r examples
	fi

	installation() {
		cd bindings || die
		emake \
			PYGI_OVERRIDES_DIR="$(python_get_sitedir)"/gi/overrides \
			DESTDIR="${D}" \
			install
	}
	python_foreach_impl run_in_build_dir installation

	prune_libtool_files --modules
}

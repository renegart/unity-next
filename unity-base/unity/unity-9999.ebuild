# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
GNOME2_LA_PUNT="yes"
PYTHON_DEPEND="2:2.7"

GTESTVER="1.6.0"

inherit base cmake-utils distutils eutils gnome2 python toolchain-funcs bzr ubuntu-versionator xdummy

DESCRIPTION="Fully converged Unity desktop for the phone, pc, tablet, tv"
HOMEPAGE="https://launchpad.net/unity/phablet-mods"
SRC_URI="http://googletest.googlecode.com/files/gtest-${GTESTVER}.zip"  # SRC_URI must be set before EBZR_REPO_URI
EBZR_PROJECT="${PN}"
EBZR_BRANCH="trunk"
EBZR_REPO_URI="lp:${PN}/phablet-mods"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="doc +branding pch test"

RDEPEND="dev-libs/dee:=
	dev-libs/libdbusmenu:=
	dev-libs/libunity-misc:=
	mir-base/mir
	>=unity-base/bamf-0.4.0:=
	>=unity-base/compiz-0.9.9:=
	>=unity-base/nux-4.0.0:=
	unity-base/unity-language-pack
	x11-themes/humanity-icon-theme
	x11-themes/unity-asset-pool"
DEPEND="dev-cpp/gtest
	dev-libs/boost
	dev-libs/dee
	dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libappindicator
	dev-libs/libdbusmenu
	dev-libs/libindicate[gtk,introspection]
	dev-libs/libindicate-qt
	>=dev-libs/libindicator-12.10.2
	=dev-libs/libunity-9999
	dev-libs/libunity-misc
	dev-qt/qtdeclarative:5
	dev-python/gconf-python
	>=gnome-base/gconf-3.2.5
	gnome-base/gnome-desktop:3
	>=gnome-base/gnome-menus-3.6.0:3
	>=gnome-base/gnome-control-center-3.6.3
	>=gnome-base/gnome-settings-daemon-3.6.3
	>=gnome-base/gnome-session-3.6.0
	>=gnome-base/gsettings-desktop-schemas-3.6.0
	gnome-base/gnome-shell
	gnome-base/libgdu
	>=gnome-extra/polkit-gnome-0.105
	media-libs/clutter-gtk:1.0
	media-sound/pulseaudio
	sys-apps/dbus
	>=sys-devel/gcc-4.7.3
	>=unity-base/bamf-0.4.0
	>=unity-base/compiz-0.9.9
	unity-base/dconf-qt
	=unity-base/hud-9999
	=unity-base/nux-9999
	unity-base/overlay-scrollbar
	x11-base/xorg-server[dmx]
	x11-libs/dee-qt[qt5]
	x11-libs/libXfixes
	x11-misc/appmenu-gtk
	x11-misc/appmenu-qt
	doc? ( app-doc/doxygen
		media-gfx/graphviz )
	test? ( dev-cpp/gmock
		dev-python/autopilot
		dev-util/dbus-test-runner
		sys-apps/xorg-gtest )"

pkg_pretend() {
	if [[ $(gcc-major-version) -lt 4 ]] || \
		( [[ $(gcc-major-version) -eq 4 && $(gcc-minor-version) -lt 7 ]] ) || \
			( [[ $(gcc-version) == "4.7" && $(gcc-micro-version) -lt 3 ]] ); then
				die "${P} requires an active >=gcc-4.7.3, please consult the output of 'gcc-config -l'"
	fi
}

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_unpack() {
	unpack ${A}
	bzr_src_unpack
}

src_prepare() {
	PATCHES+=( "${FILESDIR}/nopch_fix.diff" )
	base_src_prepare

	python_convert_shebangs -r 2 .

	sed -e "s:/desktop:/org/unity/desktop:g" \
		-i "com.canonical.Unity.gschema.xml" || die

	sed -e "s:Ubuntu Desktop:Unity Gentoo Desktop:g" \
		-i "panel/PanelMenuView.cpp" || die

	# Remove testsuite cmake installation #
	sed -e '/python setup.py install/d' \
			-i tests/CMakeLists.txt

	# Unset CMAKE_BUILD_TYPE env variable so that cmake-utils.eclass doesn't try to 'append-cppflags -DNDEBUG' #
	#       resulting in build failure with 'fatal error: unitycore_pch.hh: No such file or directory' #
	export CMAKE_BUILD_TYPE=none

	# Disable '-Werror'
	sed -i 's/[ ]*-Werror[ ]*//g' CMakeLists.txt services/CMakeLists.txt
}

src_configure() {
	if use test; then
		mycmakeargs="${mycmakeargs}
			-DBUILD_XORG_GTEST=ON
			-DCOMPIZ_BUILD_TESTING=ON"
	else
		mycmakeargs="${mycmakeargs}
			-DBUILD_XORG_GTEST=OFF
			-DCOMPIZ_BUILD_TESTING=OFF"
	fi

	if use pch; then
		mycmakeargs="${mycmakeargs} -Duse_pch=ON"
	else
		mycmakeargs="${mycmakeargs} -Duse_pch=OFF"
	fi

	mycmakeargs="${mycmakeargs}
		-DCOMPIZ_BUILD_WITH_RPATH=FALSE
		-DCOMPIZ_PACKAGING_ENABLED=TRUE
		-DCOMPIZ_PLUGIN_INSTALL_TYPE=package
		-DCOMPIZ_INSTALL_GCONF_SCHEMA_DIR=/etc/gconf/schemas
		-DUSE_GSETTINGS=TRUE
		-DCMAKE_INSTALL_PREFIX=/usr
		-DGTEST_ROOT_DIR="${WORKDIR}/gtest-${GTESTVER}"
		-DGTEST_SRC_DIR="${WORKDIR}/gtest-${GTESTVER}/src/"
		"
	cmake-utils_src_configure || die
}

src_compile() {
	if use test; then
		pushd tests/autopilot
			distutils_src_compile
		popd
	fi
	cmake-utils_src_compile || die
}

src_test() {
	pushd ${CMAKE_BUILD_DIR}
		# FIXME #
		# 'make check' doesn't work due to broken linktime -rpath for tests/test-unit so use 'make check-headless' only for now #
		# ./test-unit: error while loading shared libraries: libunity-protocol-private.so.0: cannot open shared object file: No such file or directory #
		local XDUMMY_COMMAND="make check-headless"
		xdummymake
	popd
}

src_install() {
	pushd ${CMAKE_BUILD_DIR}
		addpredict /root/.gconf		 	# FIXME
		addpredict /usr/share/glib-2.0/schemas/	# FIXME
		emake DESTDIR="${D}" install
	popd

	if use test; then
		pushd tests/autopilot
			distutils_src_install
		popd
	fi

	# Gentoo dash launcher icon #
	if use branding; then
		insinto /usr/share/unity/6
		doins "${FILESDIR}/launcher_bfb.png"
	fi

	# Remove all installed language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	rm -rf "${ED}usr/share/locale"

	# Make searchingthedashlegalnotice.html available to gnome-control-center's Details > Legal Notice #
	dosym /usr/share/unity/6/searchingthedashlegalnotice.html \
		/usr/share/gnome-control-center/searchingthedashlegalnotice.html
}

pkg_postinst() {
	elog
	elog "It is recommended to enable the 'ayatana' USE flag"
	elog "for portage packages so they can use the Unity"
	elog "libindicate or libappindicator notification plugins"
	elog
	elog "If you would like to use Unity's icons and themes"
	elog "select the Ambiance theme in 'System Settings > Appearance'"
	elog

	if use test; then
		elog "To run autopilot tests, do the following:"
		elog "cd $(python_get_libdir)/site-packages/unity/tests"
		elog "and run 'autopilot run unity'"
		elog
	fi

	gnome2_pkg_postinst
}

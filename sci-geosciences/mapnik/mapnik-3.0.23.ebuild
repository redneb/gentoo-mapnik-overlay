# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 python3_8 )

inherit python-any-r1 toolchain-funcs

DESCRIPTION="A Free Toolkit for developing mapping applications"
HOMEPAGE="https://mapnik.org/"
SRC_URI="
	https://github.com/mapnik/mapnik/releases/download/v${PV}/mapnik-v${PV}.tar.bz2 -> ${P}.tar.bz2
	test? ( https://github.com/mapnik/test-data/archive/v${PV}.tar.gz -> ${PN}-test-data-${PV}.tar.gz )"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cairo debug doc gdal osmfonts postgres sqlite test"

RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-libs/boost-1.48:=[threads]
	<dev-libs/boost-1.75:=[threads]
	dev-libs/icu:=
	sys-libs/zlib
	media-libs/freetype
	media-libs/harfbuzz
	dev-libs/libxml2
	media-libs/libpng:0=
	media-libs/tiff:0=
	virtual/jpeg:0=
	media-libs/libwebp:=
	<sci-libs/proj-8
	media-fonts/dejavu
	x11-libs/agg[truetype]
	cairo? (
		x11-libs/cairo
		dev-cpp/cairomm
	)
	osmfonts? (
		media-fonts/dejavu
		media-fonts/noto
		media-fonts/noto-cjk
		media-fonts/unifont
	)
	postgres? ( >=dev-db/postgresql-8.3:* )
	gdal? ( sci-libs/gdal )
	sqlite? ( dev-db/sqlite:3 )"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.0-configure-only-once.patch"
	"${FILESDIR}/${PN}-2.2.0-dont-run-ldconfig.patch"
	"${FILESDIR}/${PN}-3.0.23-boost-1.74.patch"
)

S="${WORKDIR}/mapnik-v${PV}"

src_prepare() {
	default

	if use test; then
		rmdir ${S}/test/data/  || die
		mv "${WORKDIR}"/test-data-${PV}/ ${S}/test/data/ || die
	fi

	# do not version epydoc data
	sed -i \
		-e 's:-`mapnik-config --version`::g' \
		utils/epydoc_config/build_epydoc.sh || die

	# force user flags, optimization level
	sed -i -e "s:\-O%s:%s:" \
		-i -e "s:env\['OPTIMIZATION'\]:'${CXXFLAGS}':" \
		SConstruct || die
}

src_configure() {
	local PLUGINS=shape,csv,raster,geojson
	use gdal && PLUGINS+=,gdal,ogr
	use postgres && PLUGINS+=,postgis
	use sqlite && PLUGINS+=,sqlite

	MYSCONS=(
		"CC=$(tc-getCC)"
		"CXX=$(tc-getCXX)"
		"INPUT_PLUGINS=${PLUGINS}"
		"PREFIX=/usr"
		"DESTDIR=${D}"
		"XMLPARSER=libxml2"
		"LINKING=shared"
		"RUNTIME_LINK=shared"
		"PROJ_INCLUDES=/usr/include"
		"PROJ_LIBS=/usr/$(get_libdir)"
		"LIBDIR_SCHEMA=$(get_libdir)"
		"FREETYPE_INCLUDES=/usr/include/freetype2"
		"FREETYPE_LIBS=/usr/$(get_libdir)"
		"SYSTEM_FONTS=/usr/share/fonts"
		CAIRO="$(usex cairo 1 0)"
		DEBUG="$(usex debug 1 0)"
		XML_DEBUG="$(usex debug 1 0)"
		DEMO="$(usex doc 1 0)"
		SAMPLE_INPUT_PLUGINS="$(usex doc 1 0)"
		"CUSTOM_DEFINES=-DACCEPT_USE_OF_DEPRECATED_PROJ_API_H=1"
		"CUSTOM_LDFLAGS=${LDFLAGS}"
		"CUSTOM_LDFLAGS+=-L${ED}/usr/$(get_libdir)"
	)
	python_setup
	"${EPYTHON}" scons/scons.py "${MYSCONS[@]}" configure || die
}

src_compile() {
	python_setup
	"${EPYTHON}" scons/scons.py "${MYSCONS[@]}" || die
}

src_install() {
	python_setup
	"${EPYTHON}" scons/scons.py "${MYSCONS[@]}" install || die

	dodoc AUTHORS.md README.md CHANGELOG.md
}

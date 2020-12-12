# gentoo-mapnik-overlay

This repository contains a [Gentoo ebuild overlay](https://wiki.gentoo.org/wiki/Ebuild_repository) that can be used to install [mapnik](https://mapnik.org/) in a [Gentoo](https://www.gentoo.org/) system. This repository exists because the official Gentoo package repository no longer contains an ebuild for mapnik.

## How to use it

### Via `eselect repository`

The recommended way is to install it via [eselect repository](https://wiki.gentoo.org/wiki/Eselect/Repository):

    eselect repository add mapnik git https://github.com/redneb/gentoo-mapnik-overlay.git

Then you can install mapnik like you would install any other package in Gentoo:

    emerge -av sci-geosciences/mapnik

### Manually

Alternatively, create the file `/etc/portage/repos.conf/mapnik.conf` with the following contents:

    [mapnik]
    location = <repos dir>/mapnik
    sync-type = git
    sync-uri = https://github.com/redneb/gentoo-mapnik-overlay.git
    auto-sync = yes

Then initialize the new repo with:

    emerge --sync mapnik

## Contributing

PRs are welcome.

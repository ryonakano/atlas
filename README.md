# Atlas

Atlas is a map viewer designed for elementary OS.

![Screenshot](data/Screenshot.png)

This repository is a fork of [Atlas Maps](https://launchpad.net/atlas-maps).

## Installation

### For Developers

You'll need the following dependencies:

* libchamplain-0.12-dev
* libchamplain-gtk-0.12-dev
* libclutter-1.0-dev
* libgeoclue-2-dev
* libgeocode-glib-dev
* libgranite-dev (>= 5.4.0)
* libgtk-3.0-dev
* libhandy-1-dev
* meson (>= 0.49.0)
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.atlas`

    sudo ninja install
    com.github.ryonakano.atlas

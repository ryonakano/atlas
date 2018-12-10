# Atlas Maps

Atlas Maps is a map viewer designed for elementary OS.

This repository is a fork of the [original Atlas Maps](https://launchpad.net/atlas-maps).

## Installation

### For Developers

You'll need the following dependencies:

* libchamplain-0.12-dev
* libchamplain-gtk-0.12-dev
* libclutter-1.0-dev
* libgeocode-glib-dev
* libgtk-3.0-dev
* libgranite-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.atlas-maps`

    sudo ninja install
    com.github.ryonakano.atlas-maps

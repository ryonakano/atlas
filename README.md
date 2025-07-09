# Atlas
![App window in the light mode](data/screenshots/screenshot-light.png#gh-light-mode-only)

![App window in the dark mode](data/screenshots/screenshot-dark.png#gh-dark-mode-only)

Atlas is a map viewer designed for elementary OS.

Features include:

- Search any place
- Jump to your current location instantly

## Installation
### From AppCenter (Recommended)
Click the button to get Atlas on AppCenter if you're on elementary OS:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.atlas)

### From Source Code (Flatpak)
You'll need `flatpak` and `flatpak-builder` commands installed on your system.

Run `flatpak remote-add` to add AppCenter remote for dependencies:

```
flatpak remote-add --user --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
```

To build and install, use `flatpak-builder`, then execute with `flatpak run`:

```
flatpak-builder builddir --user --install --force-clean --install-deps-from=appcenter com.github.ryonakano.atlas.yml
flatpak run com.github.ryonakano.atlas
```

### From Source Code (Native)
You'll need the following dependencies:

* libadwaita-1-dev
* libgeoclue-2-dev
* libgeocode-glib-dev (>= 3.26.3)
* libglib2.0-dev (>= 2.74)
* libgranite-7-dev (>= 7.2.0)
* libgtk-4-dev
* libshumate-dev
* meson (>= 0.57.0)
* valac

Run `meson setup` to configure the build environment and run `meson compile` to build:

```bash
meson setup builddir --prefix=/usr
meson compile -C builddir
```

To install, use `meson install`, then execute with `com.github.ryonakano.atlas`:

```bash
meson install -C builddir
com.github.ryonakano.atlas
```

## Contributing
Please refer to [the contribution guideline](CONTRIBUTING.md) if you would like to:

- submit bug reports / feature requests
- propose coding changes
- translate the project

## Get Support
Need help in use of the app? Refer to [the discussions page](https://github.com/ryonakano/atlas/discussions) to search for existing discussions or [start a new discussion](https://github.com/ryonakano/atlas/discussions/new/choose) if none is relevant.

## History
This is a fork of [Atlas Maps](https://launchpad.net/atlas-maps) and wouldn't exist without work of [Steffen Schuhmann](https://launchpad.net/~sschuhmann).

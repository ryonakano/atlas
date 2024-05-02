# Atlas
Atlas is a map viewer designed for elementary OS.

![Screenshot](data/screenshots/pantheon/screenshot-light.png)

This is a fork of [Atlas Maps](https://launchpad.net/atlas-maps) and wouldn't exist without work of [Steffen Schuhmann](https://launchpad.net/~sschuhmann).

## Installation
### For Users
On elementary OS? Click the button to get Atlas on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.atlas)

### For Developers
You'll need the following dependencies:

* libgeoclue-2-dev
* libgeocode-glib-dev (>= 3.26.3)
* libshumate-dev
* libgranite-7-dev (>= 7.1.0)
* libgtk-4-dev
* meson (>= 0.58.0)
* valac

Run `meson setup` to configure the build environment and run `ninja` to build

```bash
meson setup builddir --prefix=/usr
ninja -C builddir
```

To install, use `ninja install`, then execute with `com.github.ryonakano.atlas`

```bash
ninja install -C builddir
com.github.ryonakano.atlas
```

## Contributing

Please refer to [the contribution guideline](CONTRIBUTING.md) if you would like to:

- submit bug reports / feature requests
- propose coding changes
- translate the project

## Get Support

Need help in use of the app? Refer to [the discussions page](https://github.com/ryonakano/atlas/discussions) to search for existing discussions or [start a new discussion](https://github.com/ryonakano/atlas/discussions/new/choose) if none is relevant.

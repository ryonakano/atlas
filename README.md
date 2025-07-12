# Maps
![Screenshot in the light mode](data/screenshots/screenshot-light.png#gh-light-mode-only)

![Screenshot in the dark mode](data/screenshots/screenshot-dark.png#gh-dark-mode-only)

## Building, Testing, and Installation
Run `flatpak-builder` to configure the build environment, download dependencies, build, and install

```bash
    flatpak-builder build io.elementary.maps.yml --user --install --force-clean --install-deps-from=appcenter
```

Then execute with

```bash
    flatpak run io.elementary.maps
```

## History
This is a fork of [Atlas Maps](https://launchpad.net/atlas-maps) and wouldn't exist without work of [Steffen Schuhmann](https://launchpad.net/~sschuhmann).

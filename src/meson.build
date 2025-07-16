config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

dependencies = [
    # Version limitation for libsoup 3.x support
    # libsoup 2.x is no longer shipped on GNOME Flatpak runtime by default
    dependency('geocode-glib-2.0', version: '>= 3.26.3'),
    dependency('gio-2.0'),
    # Version limitation for GLib.ApplicationFlags.DEFAULT_FLAGS
    dependency('glib-2.0', version: '>= 2.74'),
    # Version limitation for Granite.Bin
    dependency('granite-7', version: '>= 7.6.0'),
    dependency('gtk4'),
    dependency ('json-glib-1.0'),
    dependency('libadwaita-1'),
    dependency('libgeoclue-2.0'),
    dependency('shumate-1.0'),
]

sources = files(
    'Application.vala',
    'Define.vala',
    'MainWindow.vala',
    'MapWidget.vala',
    'MapStyle.vala',
    'SearchResultItem.vala',
    'Util.vala',
)

executable(
    meson.project_name(),
    asresources,
    config_file,
    sources,
    dependencies: dependencies,
    install: true
)

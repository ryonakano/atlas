config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files(
    'Application.vala',
    'MainWindow.vala',
    'MapWidget.vala',
    'MarkerLayerManager.vala',
    'StyleSwitcher.vala',
)

executable(
    app_id,
    asresources,
    config_file,
    sources,
    # Workaround for a bug in meson < 1.4.0
    # https://gitlab.gnome.org/jwestman/blueprint-compiler/-/issues/18
    # https://github.com/mesonbuild/meson/commit/ae857e841b0a6b9b595583e74f5e21676bb83f9d
    vala_args: [
        '--gresourcesdir=data/resources'
    ],
    dependencies: [
        dependency('geocode-glib-2.0', version: '>= 3.26.3'),
        dependency('gio-2.0'),
        dependency('granite-7', version: '>= 7.1.0'),
        dependency('libgeoclue-2.0'),
        dependency('shumate-1.0'),
        dependency('gtk4')
    ],
    install: true
)

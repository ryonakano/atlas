conf_data = configuration_data()
conf_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
config_header = configure_file(
    input: 'Config.vala.in',
    output: 'Config.vala',
    configuration: conf_data
)

sources = files(
    'Application.vala',
    'MainWindow.vala',
    'MapWidget.vala',
    'MarkerLayerManager.vala',
    'StyleSwitcher.vala',
)

executable(
    meson.project_name (),
    asresources,
    config_header,
    sources,
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

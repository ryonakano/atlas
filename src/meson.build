config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('APP_VERSION', app_version)
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

granite_dep = dependency('granite-7', version: '>= 7.2.0', required: get_option('granite'))
if granite_dep.found()
    add_project_arguments('--define=USE_GRANITE', language: 'vala')
endif

dependencies = [
    dependency('geocode-glib-2.0', version: '>= 3.26.3'),
    dependency('gio-2.0'),
    dependency('glib-2.0', version: '>= 2.74'),
    granite_dep,
    dependency('gtk4'),
    dependency('libadwaita-1'),
    dependency('libgeoclue-2.0'),
    dependency('shumate-1.0'),
]

sources = files(
    'Application.vala',
    'Define.vala',
    'MainWindow.vala',
    'MapWidget.vala',
    'MarkerLayerManager.vala',
    'Util.vala',
)

executable(
    app_id,
    asresources,
    config_file,
    sources,
    dependencies: dependencies,
    install: true
)

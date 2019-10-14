project('com.github.ryonakano.atlas', 'vala', 'c')

i18n = import('i18n')
add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

conf_data = configuration_data()
conf_data.set_quoted('PKGDATADIR', join_paths(get_option('prefix'), get_option('datadir')))
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
config_header = configure_file(
    input: 'src/config.vala.in',
    output: 'config.vala',
    configuration: conf_data
)

executable(
    meson.project_name (),
    config_header,
    'src/View/SearchOptionSelector.vala',
    'src/Application.vala',
    'src/GeoClue.vala',
    'src/LocationMarker.vala',
    'src/Window.vala',
    dependencies: [
        dependency('granite'),
        dependency('gtk+-3.0'),
        dependency('champlain-gtk-0.12'),
        dependency('champlain-0.12'),
        dependency('clutter-1.0'),
        dependency('geocode-glib-1.0'),
        dependency('libgeoclue-2.0'),
    ],
    install: true
)

subdir('data')

meson.add_install_script('meson/post_install.py')

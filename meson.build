project(
    'com.github.ryonakano.atlas',
    'vala', 'c',
    version: '3.0.2',
    meson_version: '>=0.58.0'
)

app_name = 'Atlas'
app_id = meson.project_name()
if get_option('development')
    app_name += ' (Development)'
    app_id += '.Devel'
endif

gnome = import('gnome')
i18n = import('i18n')

add_global_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language:'c'
)

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)

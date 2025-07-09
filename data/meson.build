icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'icons' / i / meson.project_name() + '.png',
        rename: meson.project_name() + '.png',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

i18n.merge_file(
    input: 'atlas.desktop.in',
    output: '@0@.desktop'.format(meson.project_name()),
    po_dir: meson.project_source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'atlas.metainfo.xml.in',
    output: '@0@.metainfo.xml'.format(meson.project_name()),
    po_dir: meson.project_source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

install_data(
    'atlas.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

asresources = gnome.compile_resources(
    'as-resources',
    'atlas.gresource.xml',
    source_dir: 'data',
    c_name: 'as'
)

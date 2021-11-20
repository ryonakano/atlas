icon_sizes = ['32', '48', '64', '128', '256']

foreach i : icon_sizes
    install_data(
        'icons' / i / 'atlas.png',
        rename: meson.project_name() + '.png',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

install_data(
    'icons' / 'atlas' / 'LocationMarker.svg',
    install_dir: get_option('prefix') / get_option('datadir')
)

i18n.merge_file(
    input: meson.project_name() + '.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.source_root() / 'po' / 'extra',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: meson.project_name() + '.appdata.xml.in',
    output: meson.project_name() + '.appdata.xml',
    po_dir: meson.source_root() / 'po' / 'extra',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

install_data(
    'schemas' / 'com.github.ryonakano.atlas.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

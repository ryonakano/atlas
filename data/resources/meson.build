blueprints = custom_target('blueprints',
    input: files(
        'ui/main-window.blp',
    ),
    output: '.',
    command: [
        find_program('blueprint-compiler'),
        'batch-compile',
        '@OUTPUT@',
        '@CURRENT_SOURCE_DIR@',
        '@INPUT@'
    ]
)

asresources = gnome.compile_resources(
    'as-resources',
    'atlas.gresource.xml',
    dependencies: blueprints,
    c_name: 'as'
)

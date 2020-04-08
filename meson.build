project('com.github.lafydev.terminalcolors', 'vala', 'c')

switchboard_dep = dependency('switchboard-2.0')

gettext_name = meson.project_name() + '-plug'
gnome = import('gnome')
i18n = import('i18n')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(gettext_name),
    language:'c'
)

install_data(
    join_paths('data/icons', 'com.github.lafydev.terminalcolors.png'),
    install_dir: join_paths(get_option('datadir'), 'icons', 'hicolor', '32x32', 'apps')
)

shared_module(
    meson.project_name(),
    'src/Plug.vala',
    dependencies: [
        dependency('glib-2.0'),
        dependency('gio-2.0'),
        dependency('gobject-2.0'),
        dependency('gtk+-3.0'),
        switchboard_dep
    ],
    install: true,
    install_dir : join_paths(switchboard_dep.get_pkgconfig_variable('plugsdir'), 'personnel')
)
subdir('po')
meson.add_install_script('meson/post_install.py')

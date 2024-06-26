/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.Application : Gtk.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    public static Settings settings { get; private set; }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };
    private MainWindow main_window;
    private StyleManager style_manager;

    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS,
            resource_base_path: Config.RESOURCE_PREFIX
        );
    }

    static construct {
        settings = new Settings (Config.APP_ID);
    }

    private void setup_style () {
        style_manager = StyleManager.get_default ();

        var style_action = new SimpleAction.stateful (
            "color-scheme", VariantType.STRING, new Variant.string (StyleManager.COLOR_SCHEME_DEFAULT)
        );
        style_action.bind_property ("state", style_manager, "color-scheme",
                                    BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                                    Util.style_action_transform_to_cb,
                                    Util.style_action_transform_from_cb);
        settings.bind ("color-scheme", style_manager, "color-scheme", SettingsBindFlags.DEFAULT);
        add_action (style_action);
    }

    protected override void startup () {
        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        setup_style ();

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q" });
        set_accels_for_action ("win.search", { "<Control>f" });
    }

    protected override void activate () {
        if (get_windows () != null) {
            main_window.present ();
            return;
        }

        main_window = new MainWindow ();
        main_window.set_application (this);
        // The main_window seems to need showing before restoring its size in Gtk4
        main_window.present ();

        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        /*
         * Binding of main_window maximization with "SettingsBindFlags.DEFAULT" results the main_window getting bigger and bigger on open.
         * So we use the prepared binding only for setting
         */
        if (settings.get_boolean ("maximized")) {
            main_window.maximize ();
        }

        settings.bind ("maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    private void on_quit_activate () {
        if (main_window != null) {
            main_window.prep_destroy ();
            // Prevent quit() for now for pre-destruction process
            return;
        }

        quit ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}

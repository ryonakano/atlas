/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Copyright 2014-2015 Atlas Developers, 2018-2022 Ryo Nakano
 */

public class Atlas.Application : Gtk.Application {
    public static bool IS_ON_PANTHEON {
        get {
            return GLib.Environment.get_variable ("XDG_CURRENT_DESKTOP") == "Pantheon";
        }
    }

    private MainWindow main_window;
    public static Settings settings;

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: Build.PROJECT_NAME
        );
    }

    construct {
        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Build.PROJECT_NAME, Build.LOCALEDIR);
        Intl.bind_textdomain_codeset (Build.PROJECT_NAME, "UTF-8");
        Intl.textdomain (Build.PROJECT_NAME);
    }

    static construct {
        settings = new Settings (Build.PROJECT_NAME);
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

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}

/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Atlas Developers
 * 
 * Some code inspired from elementary/switchboard-plug-pantheon-shell, src/Views/Appearance.vala
 */

public class Atlas.StyleSwitcher : Gtk.Grid {
    private Granite.Settings granite_settings;
    private Gtk.Settings gtk_settings;
    private Gtk.RadioButton light_style_radio;
    private Gtk.RadioButton dark_style_radio;
    private Gtk.RadioButton system_style_radio;

    public StyleSwitcher () {
        Object (
            column_spacing: 6,
            row_spacing: 6,
            margin_bottom: 6
        );
    }

    construct {
        granite_settings = Granite.Settings.get_default ();
        gtk_settings = Gtk.Settings.get_default ();

        var style_label = new Gtk.Label (_("Style option:")) {
            halign = Gtk.Align.START
        };

        var light_style_image = new Gtk.Image.from_icon_name ("display-brightness-symbolic", Gtk.IconSize.BUTTON);
        var light_style_grid = new Gtk.Grid ();
        light_style_grid.attach (light_style_image, 0, 0, 1, 1);
        light_style_grid.attach (new Gtk.Label (_("Light style")), 0, 1, 1, 1);

        light_style_radio = new Gtk.RadioButton (null);
        light_style_radio.get_style_context ().add_class ("image-button");
        light_style_radio.add (light_style_grid);

        var dark_style_image = new Gtk.Image.from_icon_name ("weather-clear-night-symbolic", Gtk.IconSize.BUTTON);
        var dark_style_grid = new Gtk.Grid ();
        dark_style_grid.attach (dark_style_image, 0, 0, 1, 1);
        dark_style_grid.attach (new Gtk.Label (_("Dark style")), 0, 1, 1, 1);

        dark_style_radio = new Gtk.RadioButton.from_widget (light_style_radio);
        dark_style_radio.get_style_context ().add_class ("image-button");
        dark_style_radio.add (dark_style_grid);

        var system_style_image = new Gtk.Image.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.BUTTON);
        var system_style_grid = new Gtk.Grid ();
        system_style_grid.attach (system_style_image, 0, 0, 1, 1);
        system_style_grid.attach (new Gtk.Label (_("System style")), 0, 1, 1, 1);

        system_style_radio = new Gtk.RadioButton.from_widget (light_style_radio);
        system_style_radio.get_style_context ().add_class ("image-button");
        system_style_radio.add (system_style_grid);

        attach (style_label, 0, 0, 3, 1);
        attach (light_style_radio, 0, 1, 1, 1);
        attach (dark_style_radio, 1, 1, 1, 1);
        attach (system_style_radio, 2, 1, 1, 1);

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            setup_style ();
        });

        light_style_radio.notify["active"].connect (() => {
            set_app_style (false, false);
        });
        dark_style_radio.notify["active"].connect (() => {
            set_app_style (true, false);
        });
        system_style_radio.notify["active"].connect (() => {
            set_app_style (
                granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK,
                true
            );
        });

        setup_style ();
    }

    private void set_app_style (bool is_prefer_dark, bool is_follow_system_style) {
        gtk_settings.gtk_application_prefer_dark_theme = is_prefer_dark;
        Application.settings.set_boolean ("is-prefer-dark", is_prefer_dark);
        Application.settings.set_boolean ("is-follow-system-style", is_follow_system_style);
    }

    private void setup_style () {
        if (Application.settings.get_boolean ("is-follow-system-style")) {
            set_app_style (granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK, true);
            system_style_radio.active = true;
        } else {
            bool is_prefer_dark = Application.settings.get_boolean ("is-prefer-dark");
            set_app_style (is_prefer_dark, false);
            if (is_prefer_dark) {
                dark_style_radio.active = true;
            } else {
                light_style_radio.active = true;
            }
        }
    }
}

/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    private Gtk.Button current_location;
    private Gtk.Spinner spinner;
    private Gtk.SearchEntry search_entry;

    construct {
        title = Application.APP_NAME;

        current_location = new Gtk.Button () {
            tooltip_text = _("Current Location"),
            icon_name = "mark-location-symbolic",
            margin_start = 6,
            margin_end = 6
        };

        spinner = new Gtk.Spinner () {
            visible = false,
            margin_start = 6,
            margin_end = 6
        };

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            tooltip_markup = Granite.markup_accel_tooltip ({"<Control>F"}, _("Search Location")),
            valign = Gtk.Align.CENTER,
            margin_start = 6,
            margin_end = 6
        };

        var style_switcher = new StyleSwitcher ();

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 6,
            margin_bottom = 6
        };

        var src_label = new Gtk.Label (_("Map Source:")) {
            halign = Gtk.Align.START
        };

        var mapnik_chkbtn = new Gtk.CheckButton.with_label ("Mapnik") {
            active = false
        };

        var transport_chkbtn = new Gtk.CheckButton.with_label (_("Transport Map")) {
            active = false,
            group = mapnik_chkbtn
        };

        // TODO: Save and restore the last selected map source
        mapnik_chkbtn.active = true;

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        preferences_box.append (style_switcher);
        preferences_box.append (separator);
        preferences_box.append (src_label);
        preferences_box.append (mapnik_chkbtn);
        preferences_box.append (transport_chkbtn);

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label (Application.APP_NAME),
            hexpand = true,
            vexpand = true
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (preferences_button);
        headerbar.pack_end (search_entry);
        headerbar.pack_end (spinner);
        set_titlebar (headerbar);

        var map_widget = new MapWidget ();
        child = map_widget;

        current_location.clicked.connect (() => {
            map_widget.go_to_current ();
        });

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "") {
                return;
            }

            busy_begin ();
            // TODO: Should be deactivated when search result found
            Timeout.add (5000, () => {
                busy_end ();

                return false;
            });
        });

        mapnik_chkbtn.toggled.connect (() => {
            map_widget.select_mapnik ();
        });

        transport_chkbtn.toggled.connect (() => {
            map_widget.select_transport ();
        });

        map_widget.busy_begin.connect (() => {
            busy_begin ();
        });

        map_widget.busy_end.connect (() => {
            busy_end ();
        });

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state) {
                switch (keyval) {
                    case Gdk.Key.q:
                        close_request ();
                        return true;
                    case Gdk.Key.f:
                        on_f_key_pressed ();
                        return true;
                    default:
                        break;
                }
            }

            return false;
        });
        ((Gtk.Widget) this).add_controller (event_controller_key);

        close_request.connect (() => {
            map_widget.save_map_state ();
            destroy ();
            return false;
        });
    }

    private void on_f_key_pressed () {
        search_entry.grab_focus ();
    }

    private void busy_begin () {
        current_location.sensitive = false;
        spinner.show ();
        spinner.start ();
    }

    private void busy_end () {
        current_location.sensitive = true;
        spinner.hide ();
        spinner.stop ();
    }
}

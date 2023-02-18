/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Copyright 2014-2015 Atlas Developers, 2018-2022 Ryo Nakano
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    private Gtk.Button current_location;
    private Gtk.Spinner spinner;

    public MainWindow () {
        Object (
            title: "Atlas"
        );
    }

    construct {
        if (!Shumate.VectorRenderer.is_supported ()) {
            return;
        }

        GLib.Bytes style_json;
        try {
            style_json = GLib.resources_lookup_data (
                "/com/github/ryonakano/atlas/osm-liberty/style.json", GLib.ResourceLookupFlags.NONE
            );
        } catch (Error e) {
            warning (e.message);
        }

        Shumate.VectorRenderer renderer;
        try {
            renderer = new Shumate.VectorRenderer ("vector-tiles", (string) style_json.get_data ());
            renderer.set_license ("© OpenStreetMap contributors");
        } catch (Error e) {
            warning ("Failed to create vector map style: %s", e.message);
        }

        GLib.Bytes sprites_json;
        try {
            sprites_json = GLib.resources_lookup_data (
                "/com/github/ryonakano/atlas/osm-liberty/sprites.json", GLib.ResourceLookupFlags.NONE
            );
            var sprites_pixbuf = new Gdk.Pixbuf.from_resource (
                "/com/github/ryonakano/atlas/osm-liberty/sprites.png"
            );
            renderer.set_sprite_sheet_data (sprites_pixbuf, (string) sprites_json.get_data ());
        } catch (Error e) {
            warning ("Failed to create spritesheet for vector map style: %s", e.message);
        }

        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        registry.add (renderer);

        var map = new Shumate.SimpleMap () {
            map_source = registry.get_by_id (renderer.get_id ())
        };
        child = map;

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

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            tooltip_markup = Granite.markup_accel_tooltip ({"<Control>F"}, _("Search Location")),
            valign = Gtk.Align.CENTER,
            margin_start = 6,
            margin_end = 6
        };

        var style_switcher = new StyleSwitcher ();

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        preferences_box.append (style_switcher);

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label ("Atlas")
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (preferences_button);
        headerbar.pack_end (search_entry);
        headerbar.pack_end (spinner);
        set_titlebar (headerbar);

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state) {
                switch (keyval) {
                    case Gdk.Key.q:
                        destroy ();
                        return true;
                    case Gdk.Key.f:
                        search_entry.grab_focus ();
                        return true;
                    default:
                        break;
                }
            }

            return false;
        });
        ((Gtk.Widget)this).add_controller (event_controller_key);

        current_location.clicked.connect (() => {
            show_current_location ();
        });

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "") {
                return;
            }

            Spinner.activate (spinner, _("Searching locations…"));

            // TODO: Should be deactivated when search result found
            Timeout.add (5000, () => {
                Spinner.deactivate (spinner);

                return false;
            });
        });
    }

    private void show_current_location () {
        current_location.sensitive = false;
        Spinner.activate (spinner, _("Detecting your current location…"));

        // TODO: Should be deactivated when moved to the current location
        Timeout.add (5000, () => {
            Spinner.deactivate (spinner);
            current_location.sensitive = true;

            return false;
        });
    }
}

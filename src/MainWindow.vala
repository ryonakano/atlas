/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Copyright 2014-2015 Atlas Developers, 2018-2022 Ryo Nakano
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    private Atlas.GeoClue geo_clue;

    private Shumate.Map base_map;

    // The Royal Observatory
    private const double DEFAULT_LATITUDE = 51.2840;
    private const double DEFAULT_LONGITUDE = 0.0005;
    private const double DEFAULT_ZOOM_LEVEL = 4;

    private Gtk.Button current_location;
    private Gtk.Spinner spinner;

    public MainWindow () {
        Object (
            title: "Atlas"
        );
    }

    construct {
        geo_clue = new Atlas.GeoClue ();

        var registry = new Shumate.MapSourceRegistry.with_defaults ();

        var map_widget = new Shumate.SimpleMap () {
            map_source = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK)
        };
        child = map_widget;
        base_map = map_widget.map;

        var marker_layer = new Shumate.MarkerLayer (map_widget.viewport);
        base_map.add_layer (marker_layer);

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

        double latitude = Atlas.Application.settings.get_double ("latitude");
        double longitude = Atlas.Application.settings.get_double ("longitude");
        double zoom_level = Atlas.Application.settings.get_double ("zoom-level");
        if (zoom_level < map_widget.map_source.min_zoom_level || map_widget.map_source.max_zoom_level < zoom_level) {
            zoom_level = DEFAULT_ZOOM_LEVEL;
        }

        // First time launch
        if (latitude == DEFAULT_LATITUDE && longitude == DEFAULT_LONGITUDE) {
            get_current_location (geo_clue, ref latitude, ref longitude);
        }

        base_map.go_to_full (latitude, longitude, zoom_level);
//        MarkerLayer.new_marker_at_pos (marker_layer, latitude, longitude);

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state) {
                switch (keyval) {
                    case Gdk.Key.q:
                        save_map_state (base_map);
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
        ((Gtk.Widget) this).add_controller (event_controller_key);

        current_location.clicked.connect (() => {
            double la = DEFAULT_LATITUDE;
            double lon = DEFAULT_LONGITUDE;
            get_current_location (geo_clue, ref la, ref lon);
            base_map.go_to (la, lon);
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

    private void get_current_location (Atlas.GeoClue geo, ref double latitude, ref double longitude) {
        GClue.Location? location = null;

        current_location.sensitive = false;
        Spinner.activate (spinner, _("Detecting your current location…"));

        geo.get_current_location.begin ((obj, res) => {
            location = geo.get_current_location.end (res);
            current_location.sensitive = true;
            Spinner.deactivate (spinner);
        });

        if (location != null) {
            latitude = location.latitude;
            longitude = location.longitude;
        }
    }

    private void save_map_state (Shumate.Map map) {
        Atlas.Application.settings.set_double ("latitude", map.viewport.latitude);
        Atlas.Application.settings.set_double ("longitude", map.viewport.longitude);
        Atlas.Application.settings.set_double ("zoom-level", map.viewport.zoom_level);
    }
}

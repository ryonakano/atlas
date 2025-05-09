/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MapWidget : Gtk.Box {
    public Shumate.MapSource map_source {
        get {
            return map_widget.map_source;
        }

        set {
            map_widget.map_source = value;
        }
    }

    private Shumate.SimpleMap map_widget;
    private Shumate.Map base_map;
    private GClue.Location? location = null;

    private MarkerLayerManager manager;
    private bool is_watching_location = false;

    // The Royal Observatory
    private const double DEFAULT_LATITUDE = 51.2840;
    private const double DEFAULT_LONGITUDE = 0.0005;
    private const double DEFAULT_ZOOM_LEVEL = 15;

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;

        map_widget = new Shumate.SimpleMap () {
            vexpand = true,
            hexpand = true
        };

        append (map_widget);
        base_map = map_widget.map;
    }

    public void init_marker_layers () {
        manager = new MarkerLayerManager (map_widget);
    }

    // Set the initial location of the map widget.
    private void set_init_place () {
        Shumate.MapSource map_source = map_widget.map_source;

        double latitude = Atlas.Application.settings.get_double ("latitude");
        double longitude = Atlas.Application.settings.get_double ("longitude");
        double zoom_level = Atlas.Application.settings.get_double ("zoom-level");
        if (zoom_level < map_source.min_zoom_level || map_source.max_zoom_level < zoom_level) {
            zoom_level = DEFAULT_ZOOM_LEVEL;
        }

        // First time launch
        if (latitude == DEFAULT_LATITUDE && longitude == DEFAULT_LONGITUDE) {
            go_to_current ();
        } else {
            base_map.go_to_full (latitude, longitude, zoom_level);
        }
    }

    public async bool watch_location_change () {
        if (is_watching_location) {
            debug ("Location is already being watched");
            return true;
        }

        GClue.Simple? simple = yield get_gclue_simple ();
        if (simple == null) {
            // Location services might be disabled
            set_init_place ();
            return false;
        }

        // draw initial current location
        draw_location (simple.location);
        is_watching_location = true;
        set_init_place ();

        // redraw on location change
        simple.notify["location"].connect (() => {
            draw_location (simple.location);
        });

        return true;
    }

    private void draw_location (GClue.Location location) {
        double lat = location.latitude;
        double lng = location.longitude;
        this.location = location;

        // Use fixed latitude and longitude as current location (for debug)
        if (Atlas.Application.settings.get_boolean ("fixed-location")) {
            lat = Atlas.Application.settings.get_double ("latitude-fixed");
            lng = Atlas.Application.settings.get_double ("longitude-fixed");
            this.location.latitude = lat;
            this.location.longitude = lng;
        }

        manager.clear_markers (MarkerType.LOCATION);
        manager.new_marker_at_pos (MarkerType.LOCATION, lat, lng);
    }

    // Inspired from https://gitlab.gnome.org/GNOME/gnome-clocks/blob/master/src/geocoding.vala
    private async GClue.Simple? get_gclue_simple () {
        GClue.Simple? simple = null;

        try {
            simple = yield new GClue.Simple (Config.APP_ID, GClue.AccuracyLevel.EXACT, null);
        } catch (Error e) {
            warning ("Failed to connect to GeoClue2 service: %s", e.message);
        }

        return simple;
    }

    public void go_to_current () {
        if (location == null) {
            warning ("Unable to go to current location: No location information provided");
            return;
        }

        base_map.go_to_full (location.latitude, location.longitude, DEFAULT_ZOOM_LEVEL);
    }

    public void go_to_place (Geocode.Place place) {
        Geocode.Location loc = place.location;

        manager.clear_markers (MarkerType.POINTER);
        manager.new_marker_at_pos (MarkerType.POINTER, loc.latitude, loc.longitude);
        base_map.go_to (loc.latitude, loc.longitude);
    }

    // Saves the latest state of the map.
    public void save_map_state () {
        Atlas.Application.settings.set_double ("latitude", base_map.viewport.latitude);
        Atlas.Application.settings.set_double ("longitude", base_map.viewport.longitude);
        Atlas.Application.settings.set_double ("zoom-level", base_map.viewport.zoom_level);
    }
}

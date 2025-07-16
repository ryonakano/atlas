/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.MapWidget : Gtk.Box {
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
    // Displays the "pin" icon at a specified place by search
    private Shumate.MarkerLayer pin_layer;
    // Displays the position of current location
    private Shumate.MarkerLayer location_layer;

    private GClue.Location? location = null;

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

        try {
            load_vector_tiles ();
        } catch (Error e) {
            critical ("Failed to create vector map style: %s", e.message);
        }
    }

    private void load_vector_tiles () throws Error requires (Shumate.VectorRenderer.is_supported ()) {
        // var bytes = resources_lookup_data ("/io/elementary/maps/tiles/style.json", NONE);
        // var style_json = (string) bytes.get_data ();

        var sprites_json = resources_lookup_data ("/io/elementary/maps/tiles/sprites.json", NONE);
        var sprites_texture = Gdk.Texture.from_resource ("/io/elementary/maps/tiles/sprites.png");

        var sprites_2x_json = resources_lookup_data ("/io/elementary/maps/tiles/sprites@2x.json", NONE);
        var sprites_2x_texture = Gdk.Texture.from_resource ("/io/elementary/maps/tiles/sprites@2x.png");

        var renderer = new Shumate.VectorRenderer (Define.MapID.EXPLORE_LIGHT, MapStyle.get_style ());
        renderer.set_max_zoom_level (22);
        renderer.set_license ("© OpenMapTiles © OpenStreetMap contributors");

        var sprites = renderer.get_sprite_sheet ();
        sprites.add_page (sprites_texture, (string) sprites_json.get_data (), 1);
        sprites.add_page (sprites_2x_texture, (string) sprites_2x_json.get_data (), 1);

        var map_source_registry = new Shumate.MapSourceRegistry.with_defaults ();
        map_source_registry.add (renderer);

        map_widget.map_source = map_source_registry.get_by_id (Define.MapID.EXPLORE_LIGHT);

        critical (MapStyle.get_style ());
    }

    public void init_marker_layers () {
        pin_layer = new Shumate.MarkerLayer (map_widget.viewport);
        map_widget.add_overlay_layer (pin_layer);

        location_layer = new Shumate.MarkerLayer (map_widget.viewport);
        map_widget.add_overlay_layer (location_layer);
    }

    // Set the initial location of the map widget.
    private void set_init_place () {
        Shumate.MapSource map_source = map_widget.map_source;

        double latitude = Maps.Application.settings.get_double ("latitude");
        double longitude = Maps.Application.settings.get_double ("longitude");
        double zoom_level = Maps.Application.settings.get_double ("zoom-level");
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
        if (Maps.Application.settings.get_boolean ("fixed-location")) {
            lat = Maps.Application.settings.get_double ("latitude-fixed");
            lng = Maps.Application.settings.get_double ("longitude-fixed");
            this.location.latitude = lat;
            this.location.longitude = lng;
        }

        clear_location ();
        mark_location_at (lat, lng);
    }

    // Inspired from https://gitlab.gnome.org/GNOME/gnome-clocks/blob/master/src/geocoding.vala
    private async GClue.Simple? get_gclue_simple () {
        GClue.Simple? simple = null;

        try {
            simple = yield new GClue.Simple ("io.elementary.maps", GClue.AccuracyLevel.EXACT, null);
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

        clear_pin ();
        mark_pin_at (loc.latitude, loc.longitude);
        base_map.go_to (loc.latitude, loc.longitude);
    }

    // Saves the latest state of the map.
    public void save_map_state () {
        Maps.Application.settings.set_double ("latitude", base_map.viewport.latitude);
        Maps.Application.settings.set_double ("longitude", base_map.viewport.longitude);
        Maps.Application.settings.set_double ("zoom-level", base_map.viewport.zoom_level);
    }

    private void clear_location () {
        location_layer.remove_all ();
    }

    private void clear_pin () {
        pin_layer.remove_all ();
    }

    private void mark_location_at (double latitude, double longitude) {
        var marker = new Shumate.Point () {
            latitude = latitude,
            longitude = longitude,
            selectable = true
        };

        location_layer.add_marker (marker);
    }

    private void mark_pin_at (double latitude, double longitude) {
        var image = new Gtk.Image.from_icon_name ("pointer") {
            icon_size = Gtk.IconSize.LARGE
        };

        var marker = new Shumate.Marker () {
            latitude = latitude,
            longitude = longitude,
            child = image,
            selectable = true
        };

        pin_layer.add_marker (marker);
    }
}

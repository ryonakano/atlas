/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MapWidget : Gtk.Box {
    public signal void busy_begin ();
    public signal void busy_end ();

    private Shumate.MapSource src_mapnik;
    private Shumate.MapSource src_transport;
    private Shumate.SimpleMap map_widget;
    private Shumate.Map base_map;
    private GClue.Simple? simple = null;

    private MarkerLayerManager manager;

    // The Royal Observatory
    private const double DEFAULT_LATITUDE = 51.2840;
    private const double DEFAULT_LONGITUDE = 0.0005;
    private const double DEFAULT_ZOOM_LEVEL = 15;

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;

        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        src_mapnik = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK);
        src_transport = registry.get_by_id (Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP);

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
    public void set_init_place () {
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

    public void go_to_current () {
        GClue.Location? location = null;

        busy_begin ();
        get_current_location.begin ((obj, res) => {
            location = get_current_location.end (res);
            busy_end ();

            if (location == null) {
                return;
            }

            manager.clear_markers (MarkerType.LOCATION);
            manager.new_marker_at_pos (MarkerType.LOCATION, location.latitude, location.longitude);
            base_map.go_to_full (location.latitude, location.longitude, DEFAULT_ZOOM_LEVEL);
        });
    }

    public void select_mapnik () {
        map_widget.map_source = src_mapnik;
    }

    public void select_transport () {
        map_widget.map_source = src_transport;
    }

    // Get the current location.
    // @return The current location represented by GClue.Location, or null if failed
    // Inspired from https://gitlab.gnome.org/GNOME/gnome-clocks/blob/master/src/geocoding.vala
    public async GClue.Location? get_current_location () {
        if (simple != null) {
            return simple.get_location ();
        }

        try {
            simple = yield new GClue.Simple (Build.PROJECT_NAME, GClue.AccuracyLevel.EXACT, null);
        } catch (Error e) {
            warning ("Failed to connect to GeoClue2 service: %s", e.message);
            return null;
        }

        return simple.get_location ();
    }

    public void go_to_place (Geocode.Place place) {
        Geocode.Location loc;
        loc = place.location;

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

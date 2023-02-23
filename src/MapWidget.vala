/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MapWidget : Gtk.Box {
    public signal void busy_begin ();
    public signal void busy_end ();

    private Atlas.GeoClue geo;

    private Shumate.Map? base_map = null;

    // The Royal Observatory
    private const double DEFAULT_LATITUDE = 51.2840;
    private const double DEFAULT_LONGITUDE = 0.0005;
    private const double DEFAULT_ZOOM_LEVEL = 10;

    public MapWidget () {
    }

    construct {
        orientation = Gtk.Orientation.HORIZONTAL;

        geo = new Atlas.GeoClue ();

        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        Shumate.MapSource map_source_mapnik = registry.get_by_id (Shumate.MAP_SOURCE_OSM_MAPNIK);

        var map_widget = new Shumate.SimpleMap () {
            map_source = map_source_mapnik,
            vexpand = true,
            hexpand = true
        };
        append (map_widget);
        base_map = map_widget.map;

        var marker_layer = new Shumate.MarkerLayer (map_widget.viewport);
        base_map.add_layer (marker_layer);

        init_go_to (map_widget, geo);
    }

    public void init_go_to (Shumate.SimpleMap map_widget, Atlas.GeoClue geo) {
        Shumate.Map base_map = map_widget.map;
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

//        MarkerLayer.new_marker_at_pos (marker_layer, latitude, longitude);
    }

    public void go_to_current () {
        GClue.Location? location = null;

        busy_begin ();
        geo.get_current_location.begin ((obj, res) => {
            location = geo.get_current_location.end (res);
            busy_end ();

            if (location == null) {
                return;
            }

            base_map.go_to_full (location.latitude, location.longitude, DEFAULT_ZOOM_LEVEL);
        });
    }

    public void save_map_state () {
        if (base_map == null) {
            return;
        }

        Atlas.Application.settings.set_double ("latitude", base_map.viewport.latitude);
        Atlas.Application.settings.set_double ("longitude", base_map.viewport.longitude);
        Atlas.Application.settings.set_double ("zoom-level", base_map.viewport.zoom_level);
    }
}

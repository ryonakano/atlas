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
    private Shumate.MarkerLayer? marker_layer = null;

    private Xdp.Portal? portal = null;
    private Cancellable? loc_monitor_cancelable = null;

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

    public void add_marker_layer () {
        Shumate.Map base_map = map_widget.map;

        marker_layer = new Shumate.MarkerLayer (map_widget.viewport);
        base_map.add_layer (marker_layer);
    }

    // Set the initial location of the map widget.
    public void set_init_place () {
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
    }

    public void go_to_current () {
        busy_begin ();

        if (portal == null) {
            portal = new Xdp.Portal ();
            portal.location_updated.connect ((lat, lng, alt, acc, sp, hd, desc, sec, msec) => {
                base_map.go_to_full (lat, lng, DEFAULT_ZOOM_LEVEL);
                portal.location_monitor_stop ();
                busy_end ();
            });
        }

        if (loc_monitor_cancelable != null) {
            loc_monitor_cancelable.cancel ();
        }

        loc_monitor_cancelable = new Cancellable ();

        portal.location_monitor_start.begin (null, 0, 0, Xdp.LocationAccuracy.EXACT, Xdp.LocationMonitorFlags.NONE,
                                             loc_monitor_cancelable, (obj, res) => {
            try {
                portal.location_monitor_start.end (res);
            } catch (Error e) {
                warning (e.message);
            }
        });
    }

    public void select_mapnik () {
        map_widget.map_source = src_mapnik;
    }

    public void select_transport () {
        map_widget.map_source = src_transport;
    }

    public void go_to_place (Geocode.Place place) {
        Geocode.Location loc;
        loc = place.location;

        marker_layer.remove_all ();
        MarkerLayer.new_marker_at_pos (marker_layer, loc.latitude, loc.longitude);
        base_map.go_to (loc.latitude, loc.longitude);
    }

    // Saves the latest state of the map.
    public void save_map_state () {
        Atlas.Application.settings.set_double ("latitude", base_map.viewport.latitude);
        Atlas.Application.settings.set_double ("longitude", base_map.viewport.longitude);
        Atlas.Application.settings.set_double ("zoom-level", base_map.viewport.zoom_level);
    }
}

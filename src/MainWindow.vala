/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Atlas Developers
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    public MainWindow () {
        Object (
            title: "Atlas"
        );
    }

    construct {
        //  GLib.Bytes style_json = GLib.resources_lookup_data (
        //      "/com/github/ryonakano/atlas/map-style.json", GLib.ResourceLookupFlags.NONE
        //  );

        //  if (Shumate.VectorRenderer.is_supported ()) {
        //      var renderer = new Shumate.VectorRenderer ("vector-tiles", (string) style_json.get_data ()) {
        //          license = "© OpenStreetMap contributors"
        //      };
        //      var registry = new Shumate.MapSourceRegistry.with_defaults ();
        //      registry.add (renderer);

        //      var map = new Shumate.SimpleMap () {
        //          map_source = renderer
        //      };
        //      child = map;
        //  }
        var renderer = new Shumate.RasterRenderer.from_url ("https://tile.openstreetmap.org/${z}/${x}/${y}.png") {
            name = "OpenStreetMap Carto",
            id = "osm-carto",
            license = "© OpenStreetMap contributors"
        };
        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        registry.add (renderer);

        var map = new Shumate.SimpleMap () {
            map_source = renderer
        };
        child = map;
    }
}

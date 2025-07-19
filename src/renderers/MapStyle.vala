/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Maps.MapStyle : Maps.JsonObject {
    public int version { get; private set; }
    public string name { get; construct set; }
    public Sources sources { get; private set; }
    public Gee.ArrayList<Layer> layers { get; private set; }

    private const string BLUEBERRY_100 = "#8cd5ff";
    private const string LIME_300 = "#9bdb4d";
    private const string SILVER_300 = "#d4d4d4";

    public MapStyle (string name) {
        Object (name: name);
    }

    construct {
        version = 8;
        sources = new Sources ();

        var background_layer = new Layer () {
            id = "background",
            kind = "background",
            paint = new Layer.Paint () {
                background_color = "rgb(239,239,239)"
            }
        };

        var park_layer = new Layer () {
            id = "park",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "park",
            paint = new Layer.Paint () {
                fill_color = LIME_300,
                fill_opacity = 0.7,
                fill_outline_color = "rgba(95, 208, 100, 1)"
            }
        };

        var water_layer = new Layer () {
            id = "water",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "water",
          // "filter": ["all", ["!=", "brunnel", "tunnel"]],
            paint = new Layer.Paint () {
                fill_color = BLUEBERRY_100
            }
        };

        var road_motorway_layer = new Layer () {
            id = "road_motorway",
            kind = "line",
            source = "vector-tiles",
            source_layer = "transportation",
            minzoom = 5,
        //   "filter": [
        //     "all",
        //     ["!in", "brunnel", "bridge", "tunnel"],
        //     ["==", "class", "motorway"],
        //     ["!=", "ramp", 1]
        //   ],
            layout = new Layer.Layout () {
                line_cap = "round",
                line_join = "round"
            },
            paint = new Layer.Paint () {
                line_color = new Layer.Paint.LineColor () {
                    base = 1
                    // "stops": [[5, "#ffe16b"], [6, "#ffe16b"]]
                },
                line_width = new Layer.Paint.LineWidth () {
                    base = 1.2
                    // "stops": [[5, 0], [7, 1], [20, 18]]
                }

            }
        };

        var building_layer = new Layer () {
            id = "building",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "building",
            minzoom = 13,
            paint = new Layer.Paint () {
                fill_color = SILVER_300,
        //     "fill-outline-color": {
        //       "base": 1,
        //       "stops": [[13, "hsla(35, 6%, 79%, 0.32)"], [14, "hsl(35, 6%, 79%)"]]
        //     }
            }
        };

        var place_city_layer = new Layer () {
            id = "place_city",
            kind = "symbol",
            source = "vector-tiles",
            source_layer = "place",
            minzoom = 5,
            maxzoom = 15,

          // "filter": ["all", ["==", "class", "city"]],

            layout = new Layer.Layout () {
          //   "icon-image": {"base": 1, "stops": [[0, "dot_9"], [8, ""]]},
                text_anchor = "bottom",
                text_field = "{name_en}", // FIXME: Localize properly
                text_font = {"Inter Medium"},
                text_max_width = 8,
                text_offset = {0, 0},
                text_size = new Layer.Layout.TextSize () {
                    base = 1.2
                    // "stops": [[7, 14], [11, 32]]
                },
                icon_allow_overlap = true,
                icon_optional = false
            },
            paint = new Layer.Paint () {
                text_color = "#333"
            }

          // "metadata": {
          //   "libshumate:cursor": "pointer"
          // }
        };

        layers = new Gee.ArrayList<Layer> (null);
        layers.add (background_layer);
        layers.add (park_layer);
        layers.add (water_layer);
        layers.add (road_motorway_layer);
        layers.add (building_layer);
        layers.add (place_city_layer);

    //   // "metadata": {
    //   //   "libshumate:cursor": "pointer"
    //   // }
    }

    public string to_string () {
        var generator = new Json.Generator () {
            root = Json.gobject_serialize (this)
        };

        return generator.to_data (null).replace ("kind", "type");
    }

    public class Sources : Object {
        public VectorTiles vector_tiles { get; private set; }

        construct {
            vector_tiles = new VectorTiles ();
        }

        public class VectorTiles : Maps.JsonObject {
            public string kind { get; private set; default = "vector"; }
            public string[] tiles { get; private set; default = {"https://tileserver.gnome.org/data/v3/{z}/{x}/{y}.pbf"}; }
            public int maxzoom { get; private set; }
            public int minzoom { get; private set; }

            construct {
                maxzoom = 22;
                minzoom = 0;
            }
        }
    }

    public class Layer : Maps.JsonObject {
        public string id { get; set; }
        public string kind { get; set; }
        public string source { get; set; }
        public string source_layer { get; set; }
        public int maxzoom { get; set; }
        public int minzoom { get; set; }

        // public string[] filter { get; set; }
        public Layout layout { get; set; }
        public Paint paint { get; set; }

        public class Paint : Maps.JsonObject {
            public double fill_opacity { get; set; }
            public string background_color { get; set; }
            public string fill_color { get; set; }
            public string fill_outline_color { get; set; }
            public string text_color { get; set; }
            public LineColor line_color { get; set;}
            public LineWidth line_width { get; set; }

            public class LineColor : Maps.JsonObject {
                public double base { get; set; }
            }

            public class LineWidth : Maps.JsonObject {
                public double base { get; set; }
            }
        }

        public class Filter : Maps.JsonObject {
            
        }

        public class Layout : Maps.JsonObject {
            public string line_cap { get; set; }
            public string line_join { get; set; }
            public string text_anchor { get; set; }
            public string text_field { get; set; }
            public string[] text_font { get; set; }
            public int text_max_width { get; set; }
            public int[] text_offset { get; set; } // Type `int[]' can not be used for a GLib.Object property
            public TextSize text_size { get; set; }
            public string text_transform { get; set; }
            public bool icon_allow_overlap { get; set; }
            public bool icon_optional { get; set; }

            public class TextSize : Maps.JsonObject {
                public double base { get; set; }
            }
        }
    }
}

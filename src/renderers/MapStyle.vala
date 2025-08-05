/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */


// https://openmaptiles.org/docs/style/mapbox-gl-style-spec/
// https://openmaptiles.org/schema/
public class Maps.MapStyle : Maps.JsonObject {
    public int version { get; private set; }
    public string name { get; construct set; }
    public Sources sources { get; private set; }
    public Gee.ArrayList<Layer> layers { get; private set; }

    private const string BANANA_300 = "#ffe16b";
    private const string BLUEBERRY_100 = "#8cd5ff";
    private const string LATTE_25 = "#f6f3ed";
    private const string LATTE_50 = "#f7f0e3";
    private const string LATTE_75 = "#f3e7d3";
    private const string LATTE_100 = "#efdfc4";
    private const string LIME_100 = "#d1ff82";
    private const string LIME_300 = "#9bdb4d";
    private const string SILVER_100 = "#fafafa";
    private const string SILVER_300 = "#d4d4d4";

    public MapStyle (string name) {
        Object (name: name);
    }

    construct {
        version = 8;
        sources = new Sources ();

        var background = new Layer () {
            id = "background",
            kind = "background",
            paint = new Layer.Paint () {
                background_color = LATTE_25
            }
        };

        var park = new Layer () {
            id = "park",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "park",
            paint = new Layer.Paint () {
                fill_color = LIME_300,
                fill_opacity = 0.7,
                fill_outline_color = LIME_300
            }
        };

        var park_outline = new Layer () {
            id = "park_outline",
            kind = "line",
            source = "vector-tiles",
            source_layer = "park",
            paint = new Layer.Paint () {
                // line_dasharray = [1, 1.5],
                // line_color = LIME_100 // FIXME: segfault
            }
        };

        // var landuse_residential_filter = new Maps.Expression ("all");
        // landuse_residential_filter.append ("==", "class", "residential");

        // var landuse_residential = new Layer () {
        //     id = "landuse_residential",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landuse",
        //     maxzoom = 8,
        //     filter = landuse_residential_filter,
        //     paint = new Layer.Paint () {
        //         // fill_color = {
        //         //     "base": 1,
        //         //     "stops": [
        //         //         [9, "hsla(0, 3%, 85%, 0.84)"],
        //         //         [12, "hsla(35, 57%, 88%, 0.49)"]
        //         //     ]
        //         // }
        //     }
        // };

        // var landcover_wood_filter = new Maps.Expression ("all");
        // landcover_wood_filter.append ("==", "class", "wood");

        // var landcover_wood = new Layer () {
        //     id = "landcover_wood",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landcover",
        //     filter = landcover_wood_filter,
        //     paint = new Layer.Paint () {
        //         fill_antialias = false,
        //         fill_color = "hsla(98, 61%, 72%, 0.7)",
        //         fill_opacity = 0.4
        //     }
        // };

        // var landcover_grass_filter = new Maps.Expression ("all");
        // landcover_grass_filter.append ("==", "class", "grass");

        // var landcover_grass = new Layer () {
        //     id = "landcover_grass",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landcover",
        //     filter = landcover_grass_filter,
        //     paint = new Layer.Paint () {
        //         fill_antialias = false,
        //         fill_color = LIME_300,
        //         fill_opacity = 0.5
        //     }
        // };

        // var landcover_ice_filter = new Maps.Expression ("all");
        // landcover_ice_filter.append ("==", "class", "ice");

        // var landcover_ice = new Layer () {
        //     id = "landcover_ice",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landcover",
        //     filter = landcover_ice_filter,
        //     paint = new Layer.Paint () {
        //         fill_antialias = false,
        //         fill_color = "rgba(224, 236, 236, 1)",
        //         fill_opacity = 0.8
        //     }
        // };

        // var landuse_cemetery_filter = new Maps.Expression ("all");
        // landuse_cemetery_filter.append ("==", "class", "cemetery");

        // var landuse_cemetery = new Layer () {
        //     id = "landuse_cemetery",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landuse",
        //     filter = landuse_cemetery_filter,
        //     paint = new Layer.Paint () {
        //         fill_color = "hsl(75, 37%, 81%)"
        //     }
        // };

        // var landuse_hospital_filter = new Maps.Expression ("all");
        // landuse_hospital_filter.append ("==", "class", "hospital");

        // var landuse_hospital = new Layer () {
        //     id = "landuse_hospital",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landuse",
        //     paint = new Layer.Paint () {
        //         fill_color = "#fde"
        //     }
        // };

        // var landuse_school = new Layer () {
        //     id = "landuse_school",
        //     kind = "fill",
        //     source = "openmaptiles",
        //     source_layer = "landuse",
        //     // "filter": ["==", "class", "school"],
        //     paint = new Layer.Paint () {
        //         fill_color = "rgb(236,238,204)"
        //     }
        // };

        var waterway_tunnel_filter = new Maps.Expression ("all");
        waterway_tunnel_filter.append ("==", "brunnel", "tunnel");

        var waterway_tunnel = new Layer () {
            id = "waterway_tunnel",
            kind = "line",
            source = "openmaptiles",
            source_layer = "waterway",
            filter = waterway_tunnel_filter,
            // paint = new Layer.Paint () {
            //     line_color = "#a0c8f0",
            //     line_dasharray = {3, 3},
            //     // line_gap_width = {"stops": [[12, 0], [20, 6]]},
            //     line_opacity = 1,
            //     // line_width = {"base": 1.4, "stops": [[8, 1], [20, 2]]}
            // }
        };

        // var waterway_river_filter = new Maps.Expression ("all");
        // waterway_river_filter.append ("==", "class", "river");
        // waterway_river_filter.append ("!=", "brunnel", "tunnel");

        // var waterway_river = new Layer () {
        //     id = "waterway_river",
        //     kind = "line",
        //     source = "openmaptiles",
        //     source_layer = "waterway",
        //     filter = waterway_river_filter,
        //     layout = new Layer.Layout () {
        //         line_cap = "round"
        //     },
        //     paint = new Layer.Paint () {
        //         line_color = "#a0c8f0",
        //         // line_width = {"base": 1.2, "stops": [[11, 0.5], [20, 6]]}
        //     }
        // };

        // var waterway_other_filter = new Maps.Expression ("all");
        // waterway_other_filter.append ("!=", "class", "river");
        // waterway_other_filter.append ("!=", "brunnel", "tunnel");

        // var waterway_other = new Layer () {
        //     id = "waterway_other",
        //     kind = "line",
        //     source = "openmaptiles",
        //     source_layer = "waterway",
        //     filter = waterway_other_filter,
        //     layout = new Layer.Layout () {
        //         line_cap = "round"
        //     },
        //     paint = new Layer.Paint () {
        //         line_color = "#a0c8f0",
        //         // line_width = {"base": 1.3, "stops": [[13, 0.5], [20, 6]]}
        //     }
        // };

        var water_filter = new Maps.Expression ("all");
        water_filter.append ("!=", "brunnel", "tunnel");

        var water = new Layer () {
            id = "water",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "water",
            filter = water_filter,
            paint = new Layer.Paint () {
                fill_color = BLUEBERRY_100
            }
        };

        var road_minor_filter = new Maps.Expression ("all");
        // road_minor_filter.append ("==", "$type", "LineString"); // FIXME: segfault
        // road_minor_filter.append ("!in", "brunnel", "bridge", "tunnel"); // FIXME: segfault
        road_minor_filter.append ("in", "class", "minor");

        var road_minor = new Layer () {
            id = "road_minor",
            kind = "line",
            source = "vector-tiles",
            source_layer = "transportation",
            filter = road_minor_filter,
            layout = new Layer.Layout () {
                line_cap = "round",
                line_join = "round"
            },
            paint = new Layer.Paint () {
                line_color = SILVER_100
        //     line_width = {"base": 1.2, "stops": [[13.5, 0], [14, 2.5], [20, 18]]}
            }
        };


        var road_secondary_tertiary_filter = new Maps.Expression ("all");
        road_secondary_tertiary_filter.append ("!in", "brunnel", "bridge", "tunnel");
        road_secondary_tertiary_filter.append ("in", "class", "secondary", "tertiary");

        var road_secondary_tertiary = new Layer () {
            id = "road_secondary_tertiary",
            kind = "line",
            source = "vector-tiles",
            source_layer = "transportation",
            filter = road_secondary_tertiary_filter,
            layout = new Layer.Layout () {
                line_cap = "round",
                line_join = "round"
            },
            paint = new Layer.Paint () {
                line_color = SILVER_100
        //     line_width = {"base": 1.2, "stops": [[6.5, 0], [8, 0.5], [20, 13]]}
            }
        };

        var road_trunk_primary_filter = new Maps.Expression ("all");
        road_trunk_primary_filter.append ("!in", "brunnel", "bridge", "tunnel");
        road_trunk_primary_filter.append ("in", "class", "primary", "trunk");

        var road_trunk_primary = new Layer () {
            id = "road_trunk_primary",
            kind = "line",
            source = "vector-tiles",
            source_layer = "transportation",
            filter = road_trunk_primary_filter,
            layout = new Layer.Layout () {
                line_join = "round"
            },
            paint = new Layer.Paint () {
                line_color = SILVER_300
        //     line_width = {"base": 1.2, "stops": [[5, 0], [7, 1], [20, 18]]}
            }
        };

        var road_motorway_filter = new Maps.Expression ("all");
        road_motorway_filter.append ("==", "class", "motorway");

        var road_motorway = new Layer () {
            id = "road_motorway",
            kind = "line",
            source = "vector-tiles",
            source_layer = "transportation",
            minzoom = 5,
            filter = road_motorway_filter,
            layout = new Layer.Layout () {
                line_cap = "round",
                line_join = "round"
            },
            paint = new Layer.Paint () {
                line_color = BANANA_300,
                line_width = new InterpolateExpression () {
                    base_val = 1.2
                //     stops = {[5, 0], [7, 1], [20, 18]}
                }
            }
        };

        var building = new Layer () {
            id = "building",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "building",
            minzoom = 13,
            paint = new Layer.Paint () {
                fill_color = LATTE_75,
        //     "fill-outline-color": {
        //       "base": 1,
        //       "stops": [[13, "hsla(35, 6%, 79%, 0.32)"], [14, "hsl(35, 6%, 79%)"]]
        //     }
            }
        };

        var place_city_filter = new Maps.Expression ("all");
        place_city_filter.append ("==", "class", "city");

        var place_city = new Layer () {
            id = "place_city",
            kind = "symbol",
            source = "vector-tiles",
            source_layer = "place",
            minzoom = 5,
            maxzoom = 15,
            filter = place_city_filter,
            layout = new Layer.Layout () {
          //   "icon-image": {"base": 1, "stops": [[0, "dot_9"], [8, ""]]},
                text_anchor = "bottom",
                text_field = "{name_en}", // FIXME: Localize properly
                text_font = {"Inter Medium"},
                text_max_width = 8,
                text_offset = {0, 0},
                // text_size = new InterpolateExpression () {
                //     base = 1.2
                //     "stops": [[7, 14], [11, 32]]
                // },
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
        layers.add (background);
        layers.add (park);
        // layers.add (park_outline);
        // layers.add (landuse_residential);
        // layers.add (landcover_wood);
        // layers.add (landcover_grass);
        // layers.add (landcover_ice);
        // layers.add (landuse_cemetery);
        // layers.add (landuse_hospital);
        // layers.add (landuse_school);
        // layers.add (waterway_tunnel);
        // layers.add (waterway_river);
        // layers.add (waterway_other);
        layers.add (water);
        layers.add (road_minor);
        layers.add (road_secondary_tertiary);
        layers.add (road_trunk_primary);
        layers.add (road_motorway);
        layers.add (building);
        layers.add (place_city);

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
                minzoom = 0;
                maxzoom = 14;
            }
        }
    }

    // https://docs.maptiler.com/gl-style-specification/layers/
    public class Layer : Maps.JsonObject {
        public string id { get; set; }
        public string kind { get; set; }
        public string source { get; set; }
        public string source_layer { get; set; }
        public int maxzoom { get; set; }
        public int minzoom { get; set; }

        public Expression filter { get; set; }
        public Layout layout { get; set; }
        public Paint paint { get; set; }

        // https://docs.maptiler.com/gl-style-specification/layers/#paint-property
        public class Paint : Maps.JsonObject {
            public double fill_opacity { get; set; }
            public string background_color { get; set; }
            public bool fill_antialias { get; set;}
            public string fill_color { get; set; }
            public string fill_outline_color { get; set; }
            public string text_color { get; set; }
            public string line_color { get; set; }
            public double line_opacity { get; set; }
            public double[] line_dasharray { get; set; }
            public InterpolateExpression line_width { get; set; }
        }

        public class Layout : Maps.JsonObject {
            public string line_cap { get; set; }
            public string line_join { get; set; }
            public string text_anchor { get; set; }
            public string text_field { get; set; }
            public string[] text_font { get; set; }
            public int text_max_width { get; set; }
            public double[] text_offset { get; set; }
            public InterpolateExpression text_size { get; set; }
            public string text_transform { get; set; }
            public bool icon_allow_overlap { get; set; }
            public bool icon_optional { get; set; }
        }
    }
}

// https://docs.maptiler.com/gl-style-specification/expressions/#interpolate
public class Maps.InterpolateExpression : Maps.JsonObject {
    public double base_val { get; set; } // Need to serialize as base
    public Gee.ArrayList<Json.Array> stops { get; set; }

    construct {
        stops = new Gee.ArrayList<Json.Array> (null);
    }
}

// https://docs.maptiler.com/gl-style-specification/expressions/
public class Maps.Expression : Maps.JsonObject {
    public string name { get; construct set; }
    public Gee.ArrayList<Json.Array> args { get; set; }

    public Expression (string name) {
        Object (name: name);
    }

    construct {
        args = new Gee.ArrayList<Json.Array> (null);
    }

    public void append (string operator, ...) {
        var argument = new Json.Array ();

        argument.add_string_element (operator);

        var list = va_list ();
        while (true) {
            string? string_arg = list.arg ();
            if (string_arg != null) {
                argument.add_string_element (string_arg);
                continue;
            }

            int? int_arg = list.arg ();
            if (int_arg != null) {
                argument.add_int_element (int_arg);
                continue;
            }

            break;
        }

        args.add (argument);
    }

    // FIXME: assertion 'self != NULL' failed
    public Json.Node serialize () {
        var array = new Json.Array ();

        array.add_string_element (name);

        foreach (var argument in args) {
            array.add_array_element (argument);
        }

        var node = new Json.Node (ARRAY);
        node.set_array (array);

        return node;
    }
}

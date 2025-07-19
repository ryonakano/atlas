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

    public MapStyle (string name) {
        Object (name: name);
    }

    construct {
        version = 8;
        sources = new Sources ();

        var background_layer = new Layer () {
            id = "background",
            kind = "background",
            paint = new Paint () {
                background_color = "rgb(239,239,239)"
            }
        };

        var park_layer = new Layer () {
            id = "park",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "park",
            paint = new Paint () {
                fill_color = LIME_300,
                fill_opacity = 0.7,
                fill_outline_color = "rgba(95, 208, 100, 1)"
            }
        };

    //     var water_layer = new Layer () {
    //         id = "water",
    //         layer_type = "fill",
    //         source = "vector-tiles",
    //         source_layer = "water"
    //     };
    //     water_layer.begin_object (builder);

    //     builder.set_member_name ("filter");
    //     builder.begin_array ();
    //     builder.add_string_value ("all");
    //     builder.begin_array ();
    //     builder.add_string_value ("!=");
    //     builder.add_string_value ("brunnel");
    //     builder.add_string_value ("tunnel");
    //     builder.end_array ();
    //     builder.end_array ();

    //     builder.set_member_name ("paint");
    //     builder.begin_object ();
    //     builder.set_member_name ("fill-color").add_string_value (BLUEBERRY_100);
    //     builder.end_object ();

    //     builder.end_object ();

        var water_layer = new Layer () {
            id = "water",
            kind = "fill",
            source = "vector-tiles",
            source_layer = "water",
            paint = new Paint () {
                fill_color = BLUEBERRY_100
            }
        };

    //     var place_city_layer = new Layer () {
    //         id = "place_city",
    //         layer_type = "symbol",
    //         source = "vector-tiles",
    //         source_layer = "place",
    //         min_zoom = 5,
    //         max_zoom = 15
    //     };
    //     place_city_layer.begin_object (builder);

    //     builder.set_member_name ("filter");
    //     builder.begin_array ();
    //     builder.add_string_value ("all");
    //     builder.end_array ();
    //     builder.add_string_value ("==");
    //     builder.add_string_value ("class");
    //     builder.add_string_value ("city");
    //     builder.end_array ();
    //     builder.end_array ();

    //     builder.set_member_name ("layout");
    //     builder.begin_object ();
    //     builder.set_member_name ("text-anchor").add_string_value ("bottom");
    //     builder.set_member_name ("text-field").add_string_value ("{name_en}");
    //     builder.set_member_name ("text-font");
    //     builder.begin_array ();
    //     builder.add_string_value ("Inter Medium");
    //     builder.end_array ();
    //     builder.set_member_name ("text-size");
    //     builder.begin_object ();
    //     builder.set_member_name ("base").add_double_value (1.2);
    //     builder.set_member_name ("stops");
    //     builder.begin_array ();
    //     builder.begin_array ();
    //     builder.add_int_value (7);
    //     builder.add_int_value (14);
    //     builder.end_array ();
    //     builder.begin_array ();
    //     builder.add_int_value (11);
    //     builder.add_int_value (32);
    //     builder.end_array ();
    //     builder.end_array ();
    //     builder.end_object ();
    //     builder.end_object ();
    //   // "layout": {
    //   //   "icon-image": {"base": 1, "stops": [[0, "dot_9"], [8, ""]]},
    //   //   "text-anchor": "bottom",
    //   //   "text-field": "{name_en}",
    //   //   "text-font": ["Inter Medium"],
    //   //   "text-max-width": 8,
    //   //   "text-offset": [0, 0],
    //   //   "text-size": {"base": 1.2, "stops": [[7, 14], [11, 32]]},
    //   //   "icon-allow-overlap": true,
    //   //   "icon-optional": false
    //   // },

    //     builder.set_member_name ("paint");
    //     builder.begin_object ();
    //     builder.set_member_name ("text-color").add_string_value ("#333");
    //     builder.end_object ();

    //   // "metadata": {
    //   //   "libshumate:cursor": "pointer"
    //   // }

    //     builder.end_object ();


    //     builder.end_array ().end_object ();

    //     var generator = new Json.Generator () {
    //     	root = builder.get_root ()
    //     };

	   //  return generator.to_data (null);
    // }

        layers = new Gee.ArrayList<Layer> (null);
        layers.add (background_layer);
        layers.add (park_layer);
        layers.add (water_layer);
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
                maxzoom = 14;
                minzoom = 0;
            }
        }
    }

    public class Layer : Maps.JsonObject {
        public string id { get; set; }
        public string kind { get; set; }
        public string source { get; set; }
        public string source_layer { get; set; }
        public int max_zoom { get; set; }
        public int min_zoom { get; set; }

        // public string[] filter { get; set; }
        public Paint paint { get; set; }
    }

    public class Paint : Maps.JsonObject {
        public double fill_opacity { get; set; }
        public string background_color { get; set; }
        public string fill_color { get; set; }
        public string fill_outline_color { get; set; }
    }
}

public class Maps.JsonObject : Object, Json.Serializable {
    public override Json.Node serialize_property (string prop, Value val, ParamSpec spec) {
        var type = spec.value_type;

        if (type.is_a (typeof (Gee.ArrayList))) {
            return serialize_list (prop, val, spec);
        }

        return default_serialize_property (prop, val, spec);
    }

    private static Json.Node serialize_list (string prop, Value val, ParamSpec spec) {
        var list = (Gee.ArrayList<Object>) val;
        if (list == null) {
            return new Json.Node (NULL);
        }

        var array = new Json.Array ();
        foreach (var object in list) {
            array.add_element (Json.gobject_serialize (object));
        }

        var node = new Json.Node (ARRAY);
        node.set_array (array);

        return node;
    }
}

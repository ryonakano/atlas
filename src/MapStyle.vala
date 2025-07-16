/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Maps.MapStyle : Object {
    public static string get_style () {
        string BLUEBERRY_100 = "#8cd5ff";
        string LIME_300 = "#9bdb4d";

        var builder = new Json.Builder ().begin_object ();

        builder.set_member_name ("version").add_int_value (8);
        builder.set_member_name ("name").add_string_value ("Granite Light");
        builder.set_member_name ("sources").begin_object ();
        builder.set_member_name ("vector-tiles").begin_object ();
        builder.set_member_name ("type").add_string_value ("vector");
        builder.set_member_name ("tiles").begin_array ();
        builder.add_string_value ("https://tileserver.gnome.org/data/v3/{z}/{x}/{y}.pbf");
        builder.end_array ();
        builder.set_member_name ("minzoom").add_int_value (0);
        builder.set_member_name ("maxzoom").add_int_value (14);
        builder.end_object ().end_object ();

        builder.set_member_name ("layers").begin_array ();

        var background_layer = new Layer () {
            id = "background",
            layer_type = "background"
        };
        background_layer.begin_object (builder);

        builder.set_member_name ("paint");
        builder.begin_object ();
            builder.set_member_name ("background-color").add_string_value ("rgb(239,239,239)");
        builder.end_object ();

        builder.end_object ();

        var park_layer = new Layer () {
            id = "park",
            layer_type = "fill",
            source = "vector-tiles",
            source_layer = "park"
        };
        park_layer.begin_object (builder);

        builder.set_member_name ("paint");
        builder.begin_object ();
            builder.set_member_name ("fill-color").add_string_value (LIME_300);
            builder.set_member_name ("fill-opacity").add_double_value (0.7);
            builder.set_member_name ("fill-outline-color").add_string_value ("rgba(95, 208, 100, 1)");
        builder.end_object ();

        builder.end_object ();

        var water_layer = new Layer () {
            id = "water",
            layer_type = "fill",
            source = "vector-tiles",
            source_layer = "water"
        };
        water_layer.begin_object (builder);

        builder.set_member_name ("filter");
        builder.begin_array ();
        builder.add_string_value ("all");
        builder.begin_array ();
        builder.add_string_value ("!=");
        builder.add_string_value ("brunnel");
        builder.add_string_value ("tunnel");
        builder.end_array ();
        builder.end_array ();

        builder.set_member_name ("paint");
        builder.begin_object ();
            builder.set_member_name ("fill-color").add_string_value (BLUEBERRY_100);
        builder.end_object ();

        builder.end_object ();


        builder.end_array ().end_object ();

        var generator = new Json.Generator () {
        	root = builder.get_root ()
        };

	    return generator.to_data (null);
    }

    private class Layer : Object {
        public string id { get; set; }
        public string layer_type { get; set; }
        public string source { get; set; }
        public string source_layer { get; set; }

        public Json.Builder begin_object (Json.Builder builder) {
            builder.begin_object ();

            if (id != null) {
                builder.set_member_name ("id").add_string_value (id);
            }

            if (layer_type != null) {
                builder.set_member_name ("type").add_string_value (layer_type);
            }

            if (source != null) {
                builder.set_member_name ("source").add_string_value (source);
            }

            if (source_layer != null) {
                builder.set_member_name ("source-layer").add_string_value (source_layer);
            }

            return builder;
        }
    }
}

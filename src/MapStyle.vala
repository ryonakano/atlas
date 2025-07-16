/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 */

public class Maps.MapStyle : Object {
    public static string get_style () {
        var builder = new Json.Builder ();
        builder.begin_object ();

            builder.set_member_name ("version");
            builder.add_int_value (8);

            builder.set_member_name ("name");
            builder.add_string_value ("Granite Light");

            builder.set_member_name ("sources");
            builder.begin_object ();

                builder.set_member_name ("vector-tiles");
                builder.begin_object ();

                    builder.set_member_name ("type");
                    builder.add_string_value ("vector");

                    builder.set_member_name ("tiles");
                    builder.begin_array ();
                        builder.add_string_value ("https://tileserver.gnome.org/data/v3/{z}/{x}/{y}.pbf");
                    builder.end_array ();

                    builder.set_member_name ("minzoom");
                    builder.add_int_value (0);

                    builder.set_member_name ("maxzoom");
                    builder.add_int_value (14);

                builder.end_object ();

            builder.end_object ();

            builder.set_member_name ("layers");
            builder.begin_array ();

                builder.begin_object ();

                    builder.set_member_name ("id");
                    builder.add_string_value ("background");

                    builder.set_member_name ("type");
                    builder.add_string_value ("background");

                    builder.set_member_name ("paint");
                    builder.begin_object ();
                        builder.set_member_name ("background-color");
                        builder.add_string_value ("rgb(239,239,239)");
                    builder.end_object ();

                builder.end_object ();

            builder.end_array ();

        builder.end_object ();

        var generator = new Json.Generator () {
        	root = builder.get_root ()
        };

	    return generator.to_data (null);
    }
}

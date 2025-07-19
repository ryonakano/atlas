/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Util {
    public static Adw.ColorScheme to_adw_scheme (string str_scheme) {
        switch (str_scheme) {
            case Define.ColorScheme.DEFAULT:
                return Adw.ColorScheme.DEFAULT;
            case Define.ColorScheme.FORCE_LIGHT:
                return Adw.ColorScheme.FORCE_LIGHT;
            case Define.ColorScheme.FORCE_DARK:
                return Adw.ColorScheme.FORCE_DARK;
            default:
                warning ("Invalid color scheme string: %s", str_scheme);
                return Adw.ColorScheme.DEFAULT;
        }
    }

    public static string to_str_scheme (Adw.ColorScheme adw_scheme) {
        switch (adw_scheme) {
            case Adw.ColorScheme.DEFAULT:
                return Define.ColorScheme.DEFAULT;
            case Adw.ColorScheme.FORCE_LIGHT:
                return Define.ColorScheme.FORCE_LIGHT;
            case Adw.ColorScheme.FORCE_DARK:
                return Define.ColorScheme.FORCE_DARK;
            default:
                warning ("Invalid color scheme: %d", adw_scheme);
                return Define.ColorScheme.DEFAULT;
        }
    }

    private Shumate.MapSourceRegistry registry;

    public static bool map_source_get_mapping_cb (Value value, Variant variant, void* user_data) {
        if (registry == null) {
            registry = new Shumate.MapSourceRegistry.with_defaults ();

            try {
                load_vector_tiles ();
            } catch (Error e) {
                critical ("Failed to create vector map style: %s", e.message);
            }
        }

        string map_source;
        var val = (string) variant;
        switch (val) {
            case Define.MapSetting.EXPLORE:
                map_source = Define.MapID.EXPLORE_LIGHT;
                break;
            case Define.MapSetting.TRANSIT:
                map_source = Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP;
                break;
            default:
                warning ("map_source_get_mapping_cb: Invalid map_source: %s", val);
                return false;
        }


        value.set_object (registry.get_by_id (map_source));

        return true;
    }

    private void load_vector_tiles () throws Error requires (Shumate.VectorRenderer.is_supported ()) {
        var style_json = new Maps.MapStyle (Define.MapID.EXPLORE_LIGHT).to_string ();
        critical (style_json);

        var renderer = new Shumate.VectorRenderer (Define.MapID.EXPLORE_LIGHT, style_json) {
            license = "© OpenMapTiles © OpenStreetMap contributors",
            max_zoom_level = 14, // FIXME: Map no longer renders past 14
            min_zoom_level = 2
        };

        var sprites_json = resources_lookup_data ("/io/elementary/maps/tiles/sprites.json", NONE);
        var sprites_texture = Gdk.Texture.from_resource ("/io/elementary/maps/tiles/sprites.png");

        var sprites_2x_json = resources_lookup_data ("/io/elementary/maps/tiles/sprites@2x.json", NONE);
        var sprites_2x_texture = Gdk.Texture.from_resource ("/io/elementary/maps/tiles/sprites@2x.png");

        var sprites = renderer.get_sprite_sheet ();
        sprites.add_page (sprites_texture, (string) sprites_json.get_data (), 1);
        sprites.add_page (sprites_2x_texture, (string) sprites_2x_json.get_data (), 2);

        registry.add (renderer);
    }
}

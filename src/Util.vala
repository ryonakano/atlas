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

    public static bool map_source_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
        Variant? variant = from_value.dup_variant ();
        if (variant == null) {
            warning ("Failed to Variant.dup_variant");
            return false;
        }

        string map_source;
        var val = variant.get_string ();
        switch (val) {
            case Define.MapSource.MAPNIK:
                map_source = Shumate.MAP_SOURCE_OSM_MAPNIK;
                break;
            case Define.MapSource.TRANSPORT:
                map_source = Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP;
                break;
            default:
                warning ("map_source_action_transform_to_cb: Invalid map_source: %s", val);
                return false;
        }

        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        to_value.set_object (registry.get_by_id (map_source));

        return true;
    }

    public static bool map_source_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
        unowned var val = (Shumate.MapSource) from_value.get_object ();
        string id = val.id;
        switch (id) {
            case Shumate.MAP_SOURCE_OSM_MAPNIK:
                to_value.set_variant (new Variant.string (Define.MapSource.MAPNIK));
                break;
            case Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP:
                to_value.set_variant (new Variant.string (Define.MapSource.TRANSPORT));
                break;
            default:
                warning ("map_source_action_transform_from_cb: Invalid map_source: %s", id);
                return false;
        }

        return true;
    }

    public static static bool map_source_get_mapping_cb (Value value, Variant variant, void* user_data) {
        string map_source;
        var val = (string) variant;
        switch (val) {
            case Define.MapSource.MAPNIK:
                map_source = Shumate.MAP_SOURCE_OSM_MAPNIK;
                break;
            case Define.MapSource.TRANSPORT:
                map_source = Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP;
                break;
            default:
                warning ("map_source_get_mapping_cb: Invalid map_source: %s", val);
                return false;
        }

        var registry = new Shumate.MapSourceRegistry.with_defaults ();
        value.set_object (registry.get_by_id (map_source));

        return true;
    }

    public static static Variant map_source_set_mapping_cb (Value value, VariantType expected_type, void* user_data) {
        string map_source;
        var val = (Shumate.MapSource) value;
        unowned var id = val.id;
        switch (id) {
            case Shumate.MAP_SOURCE_OSM_MAPNIK:
                map_source = Define.MapSource.MAPNIK;
                break;
            case Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP:
                map_source = Define.MapSource.TRANSPORT;
                break;
            default:
                warning ("map_source_set_mapping_cb: Invalid map_source: %s", id);
                // fallback to mapnik
                map_source = Define.MapSource.MAPNIK;
                break;
        }

        return new Variant.string (map_source);
    }
}

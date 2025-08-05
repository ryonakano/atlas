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

    public static bool map_source_get_mapping_cb (Value value, Variant variant, void* user_data) {
        unowned var registry = user_data as Shumate.MapSourceRegistry;
        if (registry == null) {
            warning ("map_source_get_mapping_cb: Invalid user_data");
            return false;
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
}

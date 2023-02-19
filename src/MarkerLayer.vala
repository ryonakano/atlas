/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas.MarkerLayer {
    public static void new_marker_at_pos (Shumate.MarkerLayer self, double latitude, double longitude) {
        var image = new Gtk.Image.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR)) {
            icon_size = Gtk.IconSize.LARGE
        };
        var marker = new Shumate.Marker () {
            latitude = latitude,
            longitude = longitude,
            child = image,
            selectable = true
        };
        self.add_marker (marker);
    }
}

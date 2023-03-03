/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas.MarkerLayer {
    private const string MARKER_RESOURCE_PATH = "/com/github/ryonakano/atlas/location-marker.svg";

    public static void new_marker_at_pos (Shumate.MarkerLayer self, double latitude, double longitude) {
        var image = new Gtk.Image.from_resource (MARKER_RESOURCE_PATH) {
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

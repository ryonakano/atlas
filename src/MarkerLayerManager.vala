/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas {
    public enum MarkerType {
        POINTER,
        LOCATION
    }

    public class MarkerLayerManager : Object {
        private struct LayerData {
            Shumate.MarkerLayer layer;
            string image;
        }

        private const string POINTER_IMAGE = "pointer";
        private const string LOCATION_IMAGE = "location";

        public Shumate.SimpleMap map_widget { private get; construct; }
        private LayerData[] layer_data;

        public MarkerLayerManager (Shumate.SimpleMap map_widget) {
            Object (map_widget: map_widget);
        }

        construct {
            var pointer_layer = new Shumate.MarkerLayer (map_widget.viewport);
            map_widget.add_overlay_layer (pointer_layer);
            LayerData pointer_data = {
                pointer_layer,
                POINTER_IMAGE
            };
            layer_data += pointer_data;

            var location_layer = new Shumate.MarkerLayer (map_widget.viewport);
            map_widget.add_overlay_layer (location_layer);
            LayerData location_data = {
                location_layer,
                LOCATION_IMAGE
            };
            layer_data += location_data;
        }

        public void new_marker_at_pos (MarkerType type, double latitude, double longitude) {
            LayerData data = layer_data[type];

            var image = new Gtk.Image.from_icon_name (data.image) {
                icon_size = Gtk.IconSize.LARGE
            };
            var marker = new Shumate.Marker () {
                latitude = latitude,
                longitude = longitude,
                child = image,
                selectable = true
            };
            data.layer.add_marker (marker);
        }

        public void clear_markers (MarkerType type) {
            LayerData data = layer_data[type];
            data.layer.remove_all ();
        }
    }
}

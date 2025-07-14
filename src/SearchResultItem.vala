/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.SearchResultItem : Granite.Bin {
    private Geocode.Place? _place = null;
    public Geocode.Place place {
        get {
            return _place;
        }

        set {
            _place = value;

            image.gicon = place.icon;
            name_label.label = place.name;

            if (place.street_address != null && place.town != null) {
                ///TRANSLATORS: a street address, followed by a town or city
                info_label.label = _("%s, %s").printf (place.street_address, place.town);

                return;
            }

            if (place.place_type == TOWN && place.state != null && place.country != null) {
                ///TRANSLATORS: a state or probince, followed by a country
                info_label.label = _("%s, %s").printf (place.state, place.country);

                return;
            }

            var street = place.street ?? unknown_text;
            var postal_code = place.postal_code ?? unknown_text;
            var town = place.town ?? unknown_text;

            info_label.label = "%s, %s, %s, %s".printf (street, postal_code, town, place.state);
        }
    }

    private string unknown_text = _("Unknown");

    private Gtk.Image image;
    private Gtk.Label name_label;
    private Gtk.Label info_label;

    construct {
        image = new Gtk.Image () {
            icon_size = LARGE
        };

        name_label = new Gtk.Label (null) {
            halign = START
        };

        info_label = new Gtk.Label (null) {
            halign = START
        };
        info_label.add_css_class (Granite.STYLE_CLASS_SMALL_LABEL);
        info_label.add_css_class (Granite.STYLE_CLASS_DIM_LABEL);

        var label_box = new Gtk.Box (VERTICAL, 0);
        label_box.append (name_label);
        label_box.append (info_label);

        var box = new Gtk.Box (HORIZONTAL, 6);
        box.append (image);
        box.append (label_box);

        child = box;
    }
}

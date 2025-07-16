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

            var street = place.street ?? unknown_text;
            var postal_code = place.postal_code ?? unknown_text;
            var town = place.town ?? unknown_text;

            image.icon_name = place.icon.to_string () + "-symbolic";
            name_label.label = place.name;
            info_label.label = "%s, %s, %s".printf (street, postal_code, town);

            // Not add because this widget gets recycled
            css_classes = {get_cssclass_for_placetype (place.place_type)};
        }
    }

    private string unknown_text = _("Unknown");

    private Gtk.Image image;
    private Gtk.Label name_label;
    private Gtk.Label info_label;

    class construct {
        set_css_name ("search-result-item");
    }

    construct {
        image = new Gtk.Image () {
            valign = CENTER
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

    private string get_cssclass_for_placetype (Geocode.PlaceType place_type) {
        var css_name = "";
        switch (place_type) {
            case AIRPORT:
            case BUS_STOP:
            case LIGHT_RAIL_STATION:
            case RAILWAY_STATION:
                css_name = "transit";
                break;

            case BAR:
            case RESTAURANT:
                css_name = "service";
                break;

            case COLLOQUIAL:
            case CONTINENT:
            case COUNTRY:
            case COUNTY:
            case ESTATE:
            case LOCAL_ADMINISTRATIVE_AREA:
            case POSTAL_CODE:
            case STATE:
            case SUBURB:
            case SUPERNAME:
            case TIME_ZONE:
            case TOWN:
            case ZONE:
                css_name = "administrative-division";
                break;

            case DRAINAGE:
            case ISLAND:
            case OCEAN:
            case SEA:
                css_name = "water";
                break;

            case HISTORICAL_COUNTY:
            case HISTORICAL_STATE:
            case HISTORICAL_TOWN:
                css_name = "historical";
                break;

            case LAND_FEATURE:
                css_name = "land-feature";
                break;

            case MOTORWAY:
                css_name = "motorway";
                break;

            case BUILDING:
            case PLACE_OF_WORSHIP:
            case POINT_OF_INTEREST:
            case SCHOOL:
                css_name = "point-of-interest";
                break;

            case STREET:
                css_name = "street";
                break;

            case MISCELLANEOUS:
            case UNKNOWN:
                // Default style
                break;
        }

        return css_name;
    }
}

/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Atlas.MainWindow : Hdy.Window {
    private GtkChamplain.Embed champlain;
    private Champlain.View view;
    private GLib.Cancellable search_cancellable;
    private Gtk.ToggleButton button_search_options;
    private View.SearchOptionSelector option_selector;
    private Gtk.ListStore location_store;
    private Champlain.MarkerLayer poi_layer;
    private Atlas.LocationMarker point;
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app,
            title: _("Atlas")
        );
    }

    construct {
        Hdy.init ();
        var geo_clue = new Atlas.GeoClue ();
        location_store = new Gtk.ListStore (2, typeof (Geocode.Place), typeof (string));

        var location_completion = new Gtk.EntryCompletion () {
            minimum_key_length = 3,
            model = location_store,
            text_column = 1
        };

        champlain = new GtkChamplain.Embed () {
            margin = 3
        };
        view = champlain.champlain_view;
        var factory = Champlain.MapSourceFactory.dup_default ();
        view.map_source = factory.create_cached_source (Champlain.MAP_SOURCE_OSM_MAPNIK);

        poi_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE);
        view.add_layer (poi_layer);

        view.go_to (Atlas.Application.settings.get_double ("langitude"), Atlas.Application.settings.get_double ("longitude"));
        view.zoom_level = Atlas.Application.settings.get_int ("zoom-level");

        var current_location = new Gtk.Button () {
            tooltip_text = _("Current Location"),
            image = new Gtk.Image.from_icon_name ("mark-location-symbolic", Gtk.IconSize.LARGE_TOOLBAR)
        };

        var spinner = new Gtk.Spinner () {
            tooltip_text = _("Detecting your current location…"),
            no_show_all = true
        };

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            valign = Gtk.Align.CENTER,
            completion = location_completion
        };

        button_search_options = new Gtk.ToggleButton () {
            tooltip_text = _("Search Options"),
            image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR)
        };

        var headerbar = new Hdy.HeaderBar () {
            title = _("Atlas"),
            show_close_button = true
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (button_search_options);
        headerbar.pack_end (search_entry);
        headerbar.pack_end (spinner);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.add (headerbar);
        main_box.add (champlain);
        add (main_box);

        location_completion.set_match_func ((completion, key, iter) => {
            return true;
        });
        location_completion.match_selected.connect ((model, iter) => suggestion_selected (model, iter));

        current_location.clicked.connect (() => {
            current_location.sensitive = false;
            spinner.show ();
            spinner.start ();

            geo_clue.get_current_location.begin ((obj, res) => {
                var location = geo_clue.get_current_location.end (res);
                view.center_on (location.latitude, location.longitude);
                view.zoom_level = 15;
                spinner.hide ();
                spinner.stop ();
                current_location.sensitive = true;
            });
        });

        search_entry.search_changed.connect (() => {
            compute_location.begin (search_entry.text);
        });

        button_search_options.clicked.connect (on_search_options_clicked);

        destroy.connect (() => {
            Atlas.Application.settings.set_double ("langitude", view.latitude);
            Atlas.Application.settings.set_double ("longitude", view.longitude);
            Atlas.Application.settings.set_int ("zoom-level", (int) view.zoom_level);
        });
    }

    protected override bool configure_event (Gdk.EventConfigure event) {
        if (configure_id != 0) {
            GLib.Source.remove (configure_id);
        }

        configure_id = Timeout.add (100, () => {
            configure_id = 0;

            Atlas.Application.settings.set_boolean ("maximized", is_maximized);

            if (!is_maximized) {
                int x, y, w, h;
                get_position (out x, out y);
                get_size (out w, out h);
                Atlas.Application.settings.set_int ("position-x", x);
                Atlas.Application.settings.set_int ("position-y", y);
                Atlas.Application.settings.set_int ("window-width", w);
                Atlas.Application.settings.set_int ("window-height", h);
            }

            return false;
        });

        return base.configure_event (event);
    }

    private bool suggestion_selected (Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value place;

        model.get_value (iter, 0, out place);
        center_map ((Geocode.Place)place);

        return false;
    }

    private void center_map (Geocode.Place loc) {
        if (point == null) {
            point = new Atlas.LocationMarker ();
        }

        point.latitude = loc.location.latitude;
        point.longitude = loc.location.longitude;

        view.go_to (point.latitude, point.longitude);

        poi_layer.remove_all ();
        poi_layer.add_marker (point);

        view.zoom_level = 6;
    }

    private void on_search_options_clicked (Gtk.Widget widget) {
        if (option_selector == null) {
            option_selector = new View.SearchOptionSelector () {
                relative_to = widget
            };
            option_selector.hide.connect (() => {
                button_search_options.active = false;
                option_selector.visible = false;
            });
        }

        if (!option_selector.visible) {
            option_selector.show_all ();
        } else {
            option_selector.hide ();
        }
    }

    // TODO Move to GeoCode
    private async void compute_location (string loc) {
    // TODO Use search options
        if (search_cancellable != null) {
            search_cancellable.cancel ();
        }

        search_cancellable = new GLib.Cancellable ();

        var forward = new Geocode.Forward.for_string (loc);
        try {
            forward.answer_count = 10;
            var places = yield forward.search_async (search_cancellable);

            Gtk.TreeIter location;
            if (places != null) {
                location_store.clear ();
            }

            foreach (var place in places) {
                location_store.append (out location);
                location_store.set (location, 0, place, 1, place.name);
            }
        } catch (Error error) {
            warning (error.message);
        }
    }
}

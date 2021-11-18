/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    private GtkChamplain.Embed champlain;
    private Gtk.SearchEntry search;
    private GLib.Cancellable search_cancellable;
    private Gtk.EntryCompletion location_completion;
    private Gtk.ToggleButton button_search_options;
    private View.SearchOptionSelector option_selector;
    private Gtk.ListStore location_store;
    private Champlain.MarkerLayer poi_layer;
    private Atlas.LocationMarker point;
    private Atlas.GeoClue geo_clue;
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app
        );
    }

    construct {
        var current_location = new Gtk.Button ();
        current_location.image = new Gtk.Image.from_icon_name ("mark-location-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        current_location.tooltip_text = _("Current Location");

        var spinner = new Gtk.Spinner ();
        spinner.tooltip_text = _("Detecting your current location…");
        spinner.no_show_all = true;

        search = new Gtk.SearchEntry ();
        search.placeholder_text = _("Search Location");
        search.valign = Gtk.Align.CENTER;

        button_search_options = new Gtk.ToggleButton ();
        button_search_options.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        button_search_options.tooltip_text = _("Search Options");

        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        headerbar.pack_start (current_location);
        headerbar.pack_end (button_search_options);
        headerbar.pack_end (search);
        headerbar.pack_end (spinner);
        headerbar.title = _("Atlas");

        set_titlebar (headerbar);

        location_store = new Gtk.ListStore (2, typeof (Geocode.Place), typeof (string));
        location_completion = new Gtk.EntryCompletion ();
        location_completion.set_minimum_key_length (3);
        search.set_completion (location_completion);

        location_completion.set_match_func ((completion, key, iter) => {
            return true;
        });

        location_completion.set_model (location_store);
        location_completion.set_text_column (1);

        location_completion.match_selected.connect ((model, iter) => suggestion_selected (model, iter));

        champlain = new GtkChamplain.Embed ();
        var view = champlain.champlain_view;
        var factory = Champlain.MapSourceFactory.dup_default ();
        view.map_source = factory.create_cached_source (Champlain.MAP_SOURCE_OSM_MAPNIK);

        poi_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE);
        view.add_layer (poi_layer);

        point = new Atlas.LocationMarker ();

        champlain.champlain_view.go_to (Atlas.Application.settings.get_double ("langitude"), Atlas.Application.settings.get_double ("longitude"));
        champlain.champlain_view.zoom_level = Atlas.Application.settings.get_int ("zoom-level");

        search.search_changed.connect (() => on_search (search.text));

        add (champlain);

        geo_clue = new Atlas.GeoClue ();

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

        button_search_options.clicked.connect (on_search_options_clicked);
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

            Atlas.Application.settings.set_double ("langitude", champlain.champlain_view.latitude);
            Atlas.Application.settings.set_double ("longitude", champlain.champlain_view.longitude);
            Atlas.Application.settings.set_int ("zoom-level", (int) champlain.champlain_view.zoom_level);

            return false;
        });

        return base.configure_event (event);
    }

    private void on_search (string search_location) {
        compute_location.begin (search_location);
    }

    private bool suggestion_selected (Gtk.TreeModel model, Gtk.TreeIter iter) {
        Value place;

        model.get_value (iter, 0, out place);
        center_map ((Geocode.Place)place);

        return false;
    }

    private void center_map (Geocode.Place loc) {
        point.latitude = loc.location.latitude;
        point.longitude = loc.location.longitude;

        champlain.champlain_view.go_to (point.latitude, point.longitude);

        poi_layer.remove_all ();
        poi_layer.add_marker (point);

        champlain.champlain_view.zoom_level = 6;
    }

    private void on_search_options_clicked (Gtk.Widget widget) {
        if (option_selector == null) {
            option_selector = new View.SearchOptionSelector ();
            option_selector.set_relative_to (widget);
            option_selector.hide.connect (() => {
                button_search_options.active = false;
                option_selector.visible = false;
            });
        }

        if (option_selector.visible == false) {
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
            forward.set_answer_count (10);
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

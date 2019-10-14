/*
* Copyright 2014-2019 Atlas Maps Developers
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*
* Authored by: Steffen Schuhmann <dev@sschuhmann.de>
*/

public class Atlas.Window : Gtk.ApplicationWindow {
    private GtkChamplain.Embed champlain;
    private Gtk.SearchEntry search;
    private Gtk.Button user_location;
    private GLib.Cancellable search_cancellable;
    private Gtk.EntryCompletion location_completion;
    private Gtk.ToggleButton button_search_options;
    private View.SearchOptionSelector option_selector;
    private Gtk.ListStore location_store;
    private Champlain.MarkerLayer poi_layer;
    private Atlas.LocationMarker point;
    private Atlas.GeoClue geo_clue;

    public Window (Gtk.Application app) {
        Object (
            application: app
        );
    }

    construct {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;

        search = new Gtk.SearchEntry ();
        search.placeholder_text = _("Search Location");
        search.valign = Gtk.Align.CENTER;

        button_search_options = new Gtk.ToggleButton ();
        button_search_options.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        button_search_options.tooltip_text = _("Search Options");

        user_location = new Gtk.Button ();
        user_location.image = new Gtk.Image.from_icon_name ("mark-location-symbolic", Gtk.IconSize.LARGE_TOOLBAR);
        user_location.tooltip_text = _("Current Location");

        headerbar.pack_end (button_search_options);
        headerbar.pack_end (search);
        headerbar.pack_start (user_location);

        set_titlebar (headerbar);
        title = _("Atlas");

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

        setup_window ();

        delete_event.connect (on_delete_window);

        search.search_changed.connect (() => on_search (search.text));

        add (champlain);

        geo_clue = new Atlas.GeoClue ();

        user_location.clicked.connect (() => {
            view.center_on (geo_clue.geo_location.latitude, geo_clue.geo_location.longitude);
            view.zoom_level = 12;
        });

        button_search_options.clicked.connect (on_search_options_clicked);

        geo_clue.seek.begin ();
        show_all ();
    }

    private void setup_window () {
        default_width = Atlas.Application.settings.get_int ("window-width");
        default_height = Atlas.Application.settings.get_int ("window-height");
        move (Atlas.Application.settings.get_int ("position-x"), Atlas.Application.settings.get_int ("position-y"));

        if (Atlas.Application.settings.get_boolean ("maximized")) {
            maximize ();
        }

        champlain.champlain_view.go_to (Atlas.Application.settings.get_double ("langitude"), Atlas.Application.settings.get_double ("longitude"));
        champlain.champlain_view.zoom_level = Atlas.Application.settings.get_int ("zoom-level");
    }

    private bool on_delete_window () {
        int x_pos, y_pos;
        if ((get_window ().get_state () & Gdk.WindowState.MAXIMIZED) == 0) {
            int width, height;
            get_position (out x_pos, out y_pos);
            Atlas.Application.settings.set_int ("position-x", x_pos);
            Atlas.Application.settings.set_int ("position-y", y_pos);
            get_size (out width, out height);
            Atlas.Application.settings.set_int ("window-width", width);
            Atlas.Application.settings.set_int ("window-height", height);
        }

        Atlas.Application.settings.set_double ("langitude", champlain.champlain_view.latitude);
        Atlas.Application.settings.set_double ("longitude", champlain.champlain_view.longitude);
        Atlas.Application.settings.set_int ("zoom-level", (int) champlain.champlain_view.zoom_level);

        return false;
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

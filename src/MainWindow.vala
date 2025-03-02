/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MainWindow : Adw.ApplicationWindow {
    private class PlaceListBoxRow : Gtk.ListBoxRow {
        public Geocode.Place place { get; construct; }

        public PlaceListBoxRow (Geocode.Place place) {
            Object (place: place);
        }
    }

    [Flags]
    private enum BusyState {
        /** Busy with locating */
        LOCATING,

        /** Busy with searching */
        SEARCHING,

        /** Busy for some reason */
        BUSY = LOCATING | SEARCHING
    }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "search", on_search_activate },
    };
    private int busy_state = 0;
    private string unknown_text = _("Unknown");
    private ListStore location_store;
    private Cancellable? search_cancellable = null;

    private Gtk.Button current_location;
    private Gtk.Spinner spinner;
    private Gtk.SearchEntry search_entry;
    private Gtk.ListBox search_res_list;
    private Gtk.Popover search_res_popover;
    private MapWidget map_widget;

    construct {
        title = "Atlas";
        add_action_entries (ACTION_ENTRIES, this);

        location_store = new ListStore (typeof (Geocode.Place));

        current_location = new Gtk.Button () {
            tooltip_text = _("Move to the current location"),
            icon_name = "mark-location-symbolic",
            margin_start = 6,
            margin_end = 6
        };

        spinner = new Gtk.Spinner () {
            margin_start = 6,
            margin_end = 6
        };

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            valign = Gtk.Align.CENTER,
            margin_start = 6,
            margin_end = 6
        };

        var search_placeholder = new Adw.StatusPage () {
            title = _("No Results Found"),
            description = _("Try a different search"),
            icon_name = "edit-find-symbolic",
            margin_start = 12,
            margin_end = 12
        };

        search_res_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.BROWSE
        };
        search_res_list.bind_model (location_store, construct_search_res);
        search_res_list.set_placeholder (search_placeholder);

        var search_res_list_scrolled = new Gtk.ScrolledWindow () {
            child = search_res_list,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };

        search_res_popover = new Gtk.Popover () {
            width_request = 400,
            height_request = 500,
            has_arrow = false,
            child = search_res_list_scrolled,
            default_widget = search_res_list
        };
        search_res_popover.set_parent (search_entry);

        var style_submenu = new Menu ();
        style_submenu.append (_("System"), "app.color-scheme('%s')".printf (Define.ColorScheme.DEFAULT));
        style_submenu.append (_("Light"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_LIGHT));
        style_submenu.append (_("Dark"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_DARK));

        var map_source_submenu = new Menu ();
        map_source_submenu.append (_("Mapnik"), "win.map-source('%s')".printf (Define.MapSource.MAPNIK));
        map_source_submenu.append (_("Transport"), "win.map-source('%s')".printf (Define.MapSource.TRANSPORT));

        var menu = new Menu ();
        menu.append_submenu (_("Style"), style_submenu);
        menu.append_submenu (_("Map Source"), map_source_submenu);

        var menu_button = new Gtk.MenuButton () {
            tooltip_text = _("Main Menu"),
            icon_name = "open-menu",
            menu_model = menu,
            primary = true
        };

        var headerbar = new Adw.HeaderBar () {
            hexpand = true,
            vexpand = true
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (menu_button);
        headerbar.pack_end (search_entry);
        headerbar.pack_end (spinner);

        map_widget = new MapWidget ();

        var toolbar_view = new Adw.ToolbarView ();
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.set_content (map_widget);

        content = toolbar_view;
        width_request = 700;
        height_request = 500;

        setup_map_source_action ();

        // Add the marker layer on top after selecting map source
        map_widget.init_marker_layers ();

        // Try to seek the current location
        busy_start (BusyState.LOCATING);
        map_widget.watch_location_change.begin ((obj, res) => {
            bool watch_enabled = map_widget.watch_location_change.end (res);
            busy_end (BusyState.LOCATING);
            if (!watch_enabled) {
                current_location.tooltip_text = _("Failed to connect to location service");
                current_location.sensitive = false;
            }
        });

        current_location.clicked.connect (() => {
            map_widget.go_to_current ();
        });

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "") {
                return;
            }

            if ((bool)(busy_state & BusyState.SEARCHING)) {
                return;
            }

            busy_start (BusyState.SEARCHING);
            compute_location.begin (search_entry.text, location_store, (obj, res) => {
                compute_location.end (res);

                search_res_popover.popup ();
                search_entry.grab_focus ();
                busy_end (BusyState.SEARCHING);
            });
        });

        search_res_list.row_activated.connect ((row) => {
            unowned var place_row = row as PlaceListBoxRow;
            if (place_row == null) {
                return;
            }

            map_widget.go_to_place (place_row.place);
        });

        var search_entry_gesture = new Gtk.EventControllerKey ();
        search_entry_gesture.key_pressed.connect (() => {
            search_res_popover.popdown ();
        });
        ((Gtk.Widget) search_res_popover).add_controller (search_entry_gesture);

        close_request.connect (() => {
            prep_destroy ();
            return Gdk.EVENT_STOP;
        });
    }

    public void prep_destroy () {
        search_res_popover.unparent ();
        map_widget.save_map_state ();
        destroy ();
    }

    private void on_search_activate () {
        search_entry.grab_focus ();
    }

    private void busy_start (int state) {
        // Not busy → Busy
        if (!(bool)(busy_state & BusyState.BUSY)) {
            spinner.visible = true;
            spinner.spinning = true;
        }

        // Not locating → Locating
        if ((bool)(state & BusyState.LOCATING)) {
            current_location.sensitive = false;
        }

        busy_state |= state;
    }

    private void busy_end (int state) {
        busy_state &= ~state;

        // Locating → Not locating
        if ((bool)(state & BusyState.LOCATING)) {
            current_location.sensitive = true;
        }

        // Busy → Not busy
        if (!(bool)(busy_state & BusyState.BUSY)) {
            spinner.visible = false;
            spinner.spinning = false;
        }
    }

    private void setup_map_source_action () {
        var map_source_action = new SimpleAction.stateful (
            "map-source", VariantType.STRING, new Variant.string (Define.MapSource.MAPNIK)
        );
        map_source_action.bind_property ("state", map_widget, "map-source",
                                         BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                                         Util.map_source_action_transform_to_cb,
                                         Util.map_source_action_transform_from_cb);
        Application.settings.bind_with_mapping ("map-source", map_widget, "map-source", SettingsBindFlags.DEFAULT,
                                                Util.map_source_get_mapping_cb,
                                                Util.map_source_set_mapping_cb,
                                                null, null);
        add_action (map_source_action);
    }

    private async void compute_location (string loc, ListStore loc_store) {
        if (search_cancellable != null) {
            search_cancellable.cancel ();
        }

        search_cancellable = new Cancellable ();

        var forward = new Geocode.Forward.for_string (loc) {
            answer_count = 10
        };

        loc_store.remove_all ();

        var places = new List<Geocode.Place> ();
        try {
            places = yield forward.search_async (search_cancellable);
        } catch (Error error) {
            warning (error.message);
        }

        foreach (unowned var place in places) {
            loc_store.append (place);
        }
    }

    private Gtk.Widget construct_search_res (Object item) {
        unowned var place = item as Geocode.Place;

        var icon = new Gtk.Image.from_gicon (place.icon);

        var place_name_label = new Gtk.Label (place.name) {
            halign = Gtk.Align.START
        };
        place_name_label.add_css_class ("title-4");

        string street = place.street ?? unknown_text;
        string postal_code = place.postal_code ?? unknown_text;
        string town = place.town ?? unknown_text;

        string info_text = "%s, %s, %s".printf (street, postal_code, town);

        var info_label = new Gtk.Label (info_text) {
            halign = Gtk.Align.START
        };
        info_label.add_css_class ("dim-label");

        var label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
        label_box.append (place_name_label);
        label_box.append (info_label);

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        box.append (icon);
        box.append (label_box);

        var row = new PlaceListBoxRow (place) {
            child = box
        };

        return row;
    }
}

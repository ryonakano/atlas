/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    [CCode (has_target = false)]
    private delegate bool KeyPressHandler (Object obj, uint keyval, uint keycode, Gdk.ModifierType state);
    private static Gee.HashMap<uint, KeyPressHandler> win_kp_handler;

    private class PlaceListBoxRow : Gtk.ListBoxRow {
        public Geocode.Place place { get; construct; }

        public PlaceListBoxRow (Geocode.Place place) {
            Object (place: place);
        }
    }

    private enum MapSource {
        MAPNIK,
        TRANSPORT;
    }

    private string unknown_text = _("Unknown");

    private ListStore location_store;
    private Cancellable? search_cancellable = null;

    private Gtk.Button current_location;
    private Gtk.Spinner spinner;
    public Gtk.SearchEntry search_entry { get; construct; }
    private Gtk.ListBox search_res_list;
    private Gtk.Popover search_res_popover;

    static construct {
        win_kp_handler = new Gee.HashMap<uint, KeyPressHandler> ();
        win_kp_handler[Gdk.Key.f] = win_kp_handler_f;
        win_kp_handler[Gdk.Key.q] = win_kp_handler_q;
    }

    construct {
        title = Application.APP_NAME;

        bool is_searching = false;
        location_store = new ListStore (typeof (Geocode.Place));

        current_location = new Gtk.Button () {
            tooltip_text = _("Move to the current location"),
            icon_name = "mark-location-symbolic",
            margin_start = 6,
            margin_end = 6
        };

        spinner = new Gtk.Spinner () {
            visible = false,
            margin_start = 6,
            margin_end = 6
        };

        search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            tooltip_markup = Granite.markup_accel_tooltip ({"<Control>F"}, _("Search Location")),
            valign = Gtk.Align.CENTER,
            margin_start = 6,
            margin_end = 6
        };

        var search_res_msg_view = new Granite.Placeholder (_("No Search Results")) {
            description = _("Try changing the search term."),
            margin_start = 12,
            margin_end = 12
        };

        search_res_list = new Gtk.ListBox () {
            selection_mode = Gtk.SelectionMode.BROWSE
        };
        search_res_list.bind_model (location_store, construct_search_res);

        var search_res_list_scrolled = new Gtk.ScrolledWindow () {
            child = search_res_list,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            vexpand = true
        };

        var search_res_stack = new Gtk.Stack () {
            height_request = 500
        };
        search_res_stack.add_child (search_res_msg_view);
        search_res_stack.add_child (search_res_list_scrolled);

        search_res_popover = new Gtk.Popover () {
            has_arrow = false,
            child = search_res_stack,
            default_widget = search_res_list
        };

        var style_switcher = new StyleSwitcher ();

        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL) {
            margin_top = 6,
            margin_bottom = 6
        };

        var src_label = new Gtk.Label (_("Map Source:")) {
            halign = Gtk.Align.START
        };

        var mapnik_chkbtn = new Gtk.CheckButton.with_label ("Mapnik") {
            active = false
        };

        var transport_chkbtn = new Gtk.CheckButton.with_label (_("Transport Map")) {
            active = false,
            group = mapnik_chkbtn
        };

        var preferences_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 6) {
            margin_top = 12,
            margin_bottom = 12,
            margin_start = 12,
            margin_end = 12
        };
        preferences_box.append (style_switcher);
        preferences_box.append (separator);
        preferences_box.append (src_label);
        preferences_box.append (mapnik_chkbtn);
        preferences_box.append (transport_chkbtn);

        var preferences_popover = new Gtk.Popover () {
            child = preferences_box
        };

        var preferences_button = new Gtk.MenuButton () {
            tooltip_text = _("Preferences"),
            icon_name = "open-menu",
            popover = preferences_popover
        };

        var headerbar = new Gtk.HeaderBar () {
            title_widget = new Gtk.Label (Application.APP_NAME),
            hexpand = true,
            vexpand = true
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (preferences_button);
        headerbar.pack_end (search_entry);
        headerbar.pack_end (search_res_popover);
        headerbar.pack_end (spinner);
        set_titlebar (headerbar);

        var map_widget = new MapWidget ();
        child = map_widget;

        if ((MapSource) Application.settings.get_enum ("map-source") == MapSource.TRANSPORT) {
            transport_chkbtn.active = true;
            map_widget.select_transport ();
        } else {
            mapnik_chkbtn.active = true;
            map_widget.select_mapnik ();
        }

        map_widget.set_init_place ();

        current_location.clicked.connect (() => {
            map_widget.go_to_current ();
        });

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "" || is_searching) {
                return;
            }

            is_searching = true;
            busy_begin ();

            compute_location.begin (search_entry.text, location_store, (obj, res) => {
                bool res_found = compute_location.end (res);
                if (res_found) {
                    search_res_stack.visible_child = search_res_list_scrolled;
                } else {
                    search_res_stack.visible_child = search_res_msg_view;
                }

                search_res_popover.popup ();
                search_entry.grab_focus ();
                busy_end ();
                is_searching = false;
            });
        });

        search_res_list.row_activated.connect ((row) => {
            unowned var place_row = row as PlaceListBoxRow;
            if (place_row == null) {
                return;
            }

            map_widget.go_to_place (place_row.place);
        });

        mapnik_chkbtn.toggled.connect (() => {
            Application.settings.set_enum ("map-source", MapSource.MAPNIK);
            map_widget.select_mapnik ();
        });

        transport_chkbtn.toggled.connect (() => {
            Application.settings.set_enum ("map-source", MapSource.TRANSPORT);
            map_widget.select_transport ();
        });

        map_widget.busy_begin.connect (() => {
            busy_begin ();
        });

        map_widget.busy_end.connect (() => {
            busy_end ();
        });

        var search_entry_gesture = new Gtk.EventControllerKey ();
        search_entry_gesture.key_pressed.connect (() => {
            search_res_popover.popdown ();
        });
        ((Gtk.Widget) search_res_popover).add_controller (search_entry_gesture);

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            var handler = win_kp_handler[keyval];
            // Unhandled key event
            if (handler == null) {
                return false;
            }

            return handler (this, keyval, keycode, state);
        });
        ((Gtk.Widget) this).add_controller (event_controller_key);

        close_request.connect (() => {
            map_widget.save_map_state ();
            destroy ();
            return false;
        });
    }

    // F key press handler for MainWindow
    // obj must be "(typeof) MainWindow"
    private static bool win_kp_handler_f (Object obj, uint keyval, uint keycode, Gdk.ModifierType state) {
        MainWindow window = obj as MainWindow;
        assert (window is MainWindow);

        if (!(Gdk.ModifierType.CONTROL_MASK in state)) {
            return false;
        }

        window.search_entry.grab_focus ();
        return true;
    }

    // Q key press handler for MainWindow
    // obj must be "(typeof) MainWindow"
    private static bool win_kp_handler_q (Object obj, uint keyval, uint keycode, Gdk.ModifierType state) {
        MainWindow window = obj as MainWindow;
        assert (window is MainWindow);

        if (!(Gdk.ModifierType.CONTROL_MASK in state)) {
            return false;
        }

        window.close_request ();
        return true;
    }

    private void busy_begin () {
        current_location.sensitive = false;
        spinner.show ();
        spinner.start ();
    }

    private void busy_end () {
        current_location.sensitive = true;
        spinner.hide ();
        spinner.stop ();
    }

    private async bool compute_location (string loc, ListStore loc_store) {
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

        if (places.is_empty ()) {
            return false;
        }

        foreach (unowned var place in places) {
            loc_store.append (place);
        }

        return true;
    }

    private Gtk.Widget construct_search_res (Object item) {
        unowned var place = item as Geocode.Place;

        var icon = new Gtk.Image.from_gicon (place.icon);

        string street = place.street ?? unknown_text;
        string postal_code = place.postal_code ?? unknown_text;
        string town = place.town ?? unknown_text;

        string info_text = "%s, %s, %s".printf (street, postal_code, town);
        var label = new Granite.HeaderLabel (place.name) {
            secondary_text = info_text
        };

        var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0) {
            margin_top = 6,
            margin_bottom = 6,
            margin_start = 6,
            margin_end = 6
        };
        box.append (icon);
        box.append (label);

        var row = new PlaceListBoxRow (place) {
            child = box
        };

        return row;
    }
}

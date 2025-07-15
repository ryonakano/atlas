/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.MainWindow : Adw.ApplicationWindow {
    [Flags]
    private enum BusyReason {
        /** Busy with locating */
        LOCATING,

        /** Busy with searching */
        SEARCHING,

        /** Busy for any reason */
        ANY = LOCATING | SEARCHING
    }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "search", on_search_activate },
    };
    private int current_busy_reason = 0;
    private ListStore location_store;
    private Cancellable? search_cancellable = null;

    private Gtk.Button current_location;
    private Gtk.Spinner spinner;
    private Gtk.SearchEntry search_entry;
    private Gtk.Popover search_res_popover;
    private MapWidget map_widget;

    construct {
        title = _("Maps");
        add_action_entries (ACTION_ENTRIES, this);

        location_store = new ListStore (typeof (Geocode.Place));

        current_location = new Gtk.Button.from_icon_name ("find-location-symbolic") {
            tooltip_text = _("Move to the current location"),
            valign = CENTER
        };

        spinner = new Gtk.Spinner ();

        search_entry = new Gtk.SearchEntry () {
            hexpand = true,
            placeholder_text = _("Search Maps")
        };

        var search_clamp = new Adw.Clamp () {
            child = search_entry
        };

        var search_placeholder = new Adw.StatusPage () {
            title = _("No Results Found"),
            description = _("Try a different search"),
            icon_name = "edit-find-symbolic",
            margin_start = 12,
            margin_end = 12
        };

        var list_factory = new Gtk.SignalListItemFactory ();
        list_factory.setup.connect (setup_factory);
        list_factory.bind.connect (bind_factory);

        var selection_model = new Gtk.NoSelection (location_store);

        var search_listview = new Gtk.ListView (selection_model, list_factory) {
            single_click_activate = true
        };
        search_listview.add_css_class (Granite.STYLE_CLASS_RICH_LIST);

        var search_res_list_scrolled = new Gtk.ScrolledWindow () {
            child = search_listview,
            hscrollbar_policy = Gtk.PolicyType.NEVER,
            max_content_height = 500,
            propagate_natural_height = true
        };

        var search_stack = new Gtk.Stack () {
            vhomogeneous = false
        };
        search_stack.add_child (search_res_list_scrolled);
        search_stack.add_child (search_placeholder);

        search_res_popover = new Gtk.Popover () {
            width_request = 400,
            has_arrow = false,
            child = search_stack
        };
        search_res_popover.set_parent (search_entry);

        var style_submenu = new Menu ();
        style_submenu.append (_("System"), "app.color-scheme('%s')".printf (Define.ColorScheme.DEFAULT));
        style_submenu.append (_("Light"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_LIGHT));
        style_submenu.append (_("Dark"), "app.color-scheme('%s')".printf (Define.ColorScheme.FORCE_DARK));

        var map_source_submenu = new Menu ();
        map_source_submenu.append (_("Mapnik"), "win.map-source('%s')".printf (Define.MapSource.MAPNIK));
        map_source_submenu.append (_("Transport"), "win.map-source('%s')".printf (Define.MapSource.TRANSPORT));

        var main_menu = new Menu ();
        main_menu.append_submenu (_("Style"), style_submenu);
        main_menu.append_submenu (_("Map Source"), map_source_submenu);

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu-symbolic",
            menu_model = main_menu,
            primary = true,
            tooltip_text = _("Main Menu"),
            valign = CENTER
        };

        var headerbar = new Adw.HeaderBar () {
            title_widget = search_clamp
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (menu_button);
        headerbar.pack_end (spinner);

        map_widget = new MapWidget ();

        var toolbar_view = new Adw.ToolbarView () {
            top_bar_style = Adw.ToolbarStyle.RAISED
        };
        toolbar_view.add_top_bar (headerbar);
        toolbar_view.set_content (map_widget);

        content = toolbar_view;
        width_request = 450;
        height_request = 500;

        setup_map_source_action ();

        // Add the marker layer on top after selecting map source
        map_widget.init_marker_layers ();

        // Try to seek the current location
        busy_start (BusyReason.LOCATING);
        map_widget.watch_location_change.begin ((obj, res) => {
            bool watch_enabled = map_widget.watch_location_change.end (res);
            busy_end (BusyReason.LOCATING);
            if (!watch_enabled) {
                current_location.tooltip_text = _("Failed to connect to location service");
                current_location.sensitive = false;
            }
        });

        current_location.clicked.connect (() => {
            map_widget.go_to_current ();
        });

        selection_model.items_changed.connect (() => {
            if (selection_model.get_n_items () == 0) {
                search_stack.visible_child = search_placeholder;
            } else {
                search_stack.visible_child = search_res_list_scrolled;
            }
        });

        var search_key_controller = new Gtk.EventControllerKey ();
        search_key_controller.key_pressed.connect ((keyval, keycode, state) => {
            switch (keyval) {
                // Intercept space key so it's not used for list activation: https://github.com/elementary/maps/issues/150
                case Gdk.Key.KP_Space:
                case Gdk.Key.space:
                    search_key_controller.forward (search_entry.get_delegate ());
                    return Gdk.EVENT_STOP;
                default:
                    // NOP
                    break;
            }

            return Gdk.EVENT_PROPAGATE;
        });
        ((Gtk.Widget) search_res_popover).add_controller (search_key_controller);

        search_entry.set_key_capture_widget (search_res_popover);

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "") {
                search_res_popover.popdown ();
                return;
            }

            search_res_popover.popup ();
            search_location.begin (search_entry.text, location_store);
        });

        search_listview.activate.connect ((pos) => {
            var place = (Geocode.Place) selection_model.get_item (pos);
            map_widget.go_to_place (place);
            search_res_popover.popdown ();
        });

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

    private void busy_start (BusyReason new_reason) {
        // Not busy → Busy
        if (!(bool)(current_busy_reason & BusyReason.ANY)) {
            spinner.spinning = true;
        }

        // Not locating → Locating
        if ((bool)(new_reason & BusyReason.LOCATING)) {
            current_location.sensitive = false;
        }

        current_busy_reason |= new_reason;
    }

    private void busy_end (BusyReason new_reason) {
        current_busy_reason &= ~new_reason;

        // Locating → Not locating
        if ((bool)(new_reason & BusyReason.LOCATING)) {
            current_location.sensitive = true;
        }

        // Busy → Not busy
        if (!(bool)(current_busy_reason & BusyReason.ANY)) {
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
                                                (SettingsBindGetMappingShared) Util.map_source_get_mapping_cb,
                                                (SettingsBindSetMappingShared) Util.map_source_set_mapping_cb,
                                                null, null);
        add_action (map_source_action);
    }

    private async void search_location (string term, ListStore res) {
        busy_start (BusyReason.SEARCHING);

        yield compute_location (term, res);

        busy_end (BusyReason.SEARCHING);
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
            return;
        }

        foreach (unowned var place in places) {
            loc_store.append (place);
        }
    }

    private void setup_factory (Object object) {
        var search_result_item = new SearchResultItem ();

        var list_item = (Gtk.ListItem) object;
        list_item.child = search_result_item;
    }

    private void bind_factory (Object object) {
        var list_item = (Gtk.ListItem) object;

        var search_result_item = (SearchResultItem) list_item.child;
        search_result_item.place = (Geocode.Place) list_item.item;
    }
}

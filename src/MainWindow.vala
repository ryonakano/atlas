/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Atlas.MainWindow : Hdy.Window {
    private GtkChamplain.Embed champlain;
    private Champlain.View view;
    private GLib.Cancellable search_cancellable;
    private Gtk.ListStore location_store;
    private Champlain.MarkerLayer poi_layer;
    private Atlas.LocationMarker point;
    private uint configure_id;

    public MainWindow (Application app) {
        Object (
            application: app,
            title: "Atlas"
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

        var spinner = new Spinner ();

        var search_entry = new Gtk.SearchEntry () {
            placeholder_text = _("Search Location"),
            valign = Gtk.Align.CENTER,
            completion = location_completion
        };
        var mode_switch = new Granite.ModeSwitch.from_icon_name (
            "display-brightness-symbolic",
            "weather-clear-night-symbolic"
        ) {
            primary_icon_tooltip_text = _("Light background"),
            secondary_icon_tooltip_text = _("Dark background"),
            valign = Gtk.Align.CENTER
        };

        ///TRANSLATORS: Whether to follow system's dark style settings
        var follow_system_label = new Gtk.Label (_("Follow system style:")) {
            halign = Gtk.Align.END
        };

        var follow_system_switch = new Gtk.Switch () {
            halign = Gtk.Align.START
        };

        var preferences_grid = new Gtk.Grid () {
            margin = 12,
            column_spacing = 6,
            row_spacing = 6
        };
        preferences_grid.attach (follow_system_label, 0, 0);
        preferences_grid.attach (follow_system_switch, 1, 0);

        var preferences_button = new Gtk.ToolButton (
            new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR), null
        ) {
            tooltip_text = _("Preferences")
        };

        var preferences_popover = new Gtk.Popover (preferences_button);
        preferences_popover.add (preferences_grid);

        preferences_button.clicked.connect (() => {
            preferences_popover.show_all ();
        });

        var headerbar = new Hdy.HeaderBar () {
            title = "Atlas",
            show_close_button = true
        };
        headerbar.pack_start (current_location);
        headerbar.pack_end (preferences_button);
        headerbar.pack_end (mode_switch);
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
            spinner.activate (_("Detecting your current location…"));

            geo_clue.get_current_location.begin ((obj, res) => {
                var location = geo_clue.get_current_location.end (res);
                view.center_on (location.latitude, location.longitude);
                view.zoom_level = 15;
                spinner.disactivate ();
                current_location.sensitive = true;
            });
        });

        search_entry.search_changed.connect (() => {
            if (search_entry.text == "") {
                return;
            }

            spinner.activate (_("Searching locations…"));

            compute_location.begin (search_entry.text, (obj, res) => {
                spinner.disactivate ();
            });
        });

        destroy.connect (() => {
            Atlas.Application.settings.set_double ("langitude", view.latitude);
            Atlas.Application.settings.set_double ("longitude", view.longitude);
            Atlas.Application.settings.set_int ("zoom-level", (int) view.zoom_level);
        });

        configure_event.connect ((event) => {
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

            return Gdk.EVENT_PROPAGATE;
        });

        key_press_event.connect ((key) => {
            if (Gdk.ModifierType.CONTROL_MASK in key.state) {
                switch (key.keyval) {
                    case Gdk.Key.q:
                        destroy ();
                        break;
                    case Gdk.Key.f:
                        search_entry.grab_focus ();
                        break;
                }
            }
        });

        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            if (Application.settings.get_boolean ("is-follow-system-style")) {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            }
        });

        follow_system_switch.notify["active"].connect (() => {
            if (follow_system_switch.active) {
                gtk_settings.gtk_application_prefer_dark_theme = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            } else {
                gtk_settings.gtk_application_prefer_dark_theme = Application.settings.get_boolean ("is-prefer-dark");
            }
        });

        Application.settings.bind ("is-prefer-dark", mode_switch, "active", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-prefer-dark", gtk_settings, "gtk-application-prefer-dark-theme", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-follow-system-style", follow_system_switch, "active", SettingsBindFlags.DEFAULT);
        Application.settings.bind ("is-follow-system-style", mode_switch, "sensitive", SettingsBindFlags.INVERT_BOOLEAN);
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
    }

    // TODO Move to GeoCode
    private async void compute_location (string loc) {
    // TODO Use search options
        if (search_cancellable != null) {
            search_cancellable.cancel ();
        }

        search_cancellable = new GLib.Cancellable ();

        var forward = new Geocode.Forward.for_string (loc) {
            answer_count = 10
        };
        try {
            var places = yield forward.search_async (search_cancellable);
            if (places != null) {
                location_store.clear ();
            }

            Gtk.TreeIter location;
            foreach (unowned var place in places) {
                location_store.append (out location);
                location_store.set (location, 0, place, 1, place.name);
            }
        } catch (Error error) {
            warning (error.message);
        }
    }
}

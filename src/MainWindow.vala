/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2024 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas {
    [GtkTemplate (ui = "/com/github/ryonakano/atlas/ui/main-window.ui")]
    public class MainWindow : Gtk.ApplicationWindow {
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

        private const ActionEntry[] ACTION_ENTRIES = {
            { "search", on_search_activate },
        };
        private string unknown_text = _("Unknown");
        private Cancellable? search_cancellable = null;

        //public Gtk.SearchEntry search_entry { get; construct; }
        //private MapWidget map_widget;

        private MarkerLayerManager manager;


        public bool is_busy { get; private set; default = false; }
        private ListStore location_store;

        [GtkChild]
        private unowned Gtk.Button current_location;
        [GtkChild]
        private unowned Gtk.SearchEntry search_entry;
        [GtkChild]
        private unowned Gtk.Popover search_res_popover;
        [GtkChild]
        private unowned Gtk.ListBox search_res_list;
        [GtkChild]
        private unowned Gtk.Spinner spinner;
        [GtkChild]
        private unowned Shumate.SimpleMap map_widget;

        construct {
            add_action_entries (ACTION_ENTRIES, this);
            setup_map_source_action ();

            search_entry.set_key_capture_widget (search_res_popover);

            location_store = new ListStore (typeof (Geocode.Place));
            search_res_list.bind_model (location_store, construct_search_res);

            // FIXME: Setting this seems to make the headerbar fatten with Adwaita.
            //search_entry.tooltip_markup = Granite.markup_accel_tooltip ({"<Control>F"}, _("Search Location"));

            search_entry.search_changed.connect (() => {
                if (search_entry.text == "" || is_busy) {
                    return;
                }

                is_busy = true;
                compute_location.begin (search_entry.text, location_store, (obj, res) => {
                    bool res_found = compute_location.end (res);
                    /*
                    if (res_found) {
                        search_res_stack.visible_child = search_res_list_scrolled;
                    } else {
                        search_res_stack.visible_child = search_res_msg_view;
                    }
                    */

                    search_res_popover.popup ();
                    search_entry.grab_focus ();
                    is_busy = false;
                });
            });


            // Add the marker layer on top after selecting map source
            init_marker_layers ();

            // Try to seek the current location
            /*
            is_busy = true;
            map_widget.watch_location_change.begin ((obj, res) => {
                bool watch_enabled = map_widget.watch_location_change.end (res);
                busy_end ();
                if (!watch_enabled) {
                    current_location.tooltip_text = _("Failed to connect to location service");
                    current_location.sensitive = false;
                }
            });
            */

            current_location.clicked.connect (() => {
                //map_widget.go_to_current ();
            });

            close_request.connect (() => {
                prep_destroy ();
                return Gdk.EVENT_STOP;
            });
        }

        public void prep_destroy () {
            //map_widget.save_map_state ();
            destroy ();
        }

        private void init_marker_layers () {
            manager = new MarkerLayerManager (map_widget);
        }

        private void setup_map_source_action () {
            var map_source_action = new SimpleAction.stateful (
                "map-source", VariantType.STRING, new Variant.string ("mapnik")
            );
            map_source_action.bind_property ("state", map_widget, "map-source",
                                        BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
                                        map_source_action_transform_to_cb,
                                        map_source_action_transform_from_cb);
            Application.settings.bind_with_mapping ("map-source", map_widget, "map-source", SettingsBindFlags.DEFAULT,
                                        map_source_get_mapping_cb,
                                        map_source_set_mapping_cb,
                                        null, null);
            add_action (map_source_action);
        }

        private bool map_source_action_transform_to_cb (Binding binding, Value from_value, ref Value to_value) {
            Variant? variant = from_value.dup_variant ();
            if (variant == null) {
                warning ("Failed to Variant.dup_variant");
                return false;
            }

            string map_source;
            var val = variant.get_string ();
            switch (val) {
                case "mapnik":
                    map_source = Shumate.MAP_SOURCE_OSM_MAPNIK;
                    break;
                case "transport":
                    map_source = Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP;
                    break;
                default:
                    warning ("map_source_action_transform_to_cb: Invalid map_source: %s", val);
                    return false;
            }

            var registry = new Shumate.MapSourceRegistry.with_defaults ();
            to_value.set_object (registry.get_by_id (map_source));

            return true;
        }

        private bool map_source_action_transform_from_cb (Binding binding, Value from_value, ref Value to_value) {
            unowned var val = (Shumate.MapSource) from_value.get_object ();
            string id = val.id;
            switch (id) {
                case Shumate.MAP_SOURCE_OSM_MAPNIK:
                    to_value.set_variant (new Variant.string ("mapnik"));
                    break;
                case Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP:
                    to_value.set_variant (new Variant.string ("transport"));
                    break;
                default:
                    warning ("map_source_action_transform_from_cb: Invalid map_source: %s", id);
                    return false;
            }

            return true;
        }

        private static bool map_source_get_mapping_cb (Value value, Variant variant, void* user_data) {
            string map_source;
            var val = (string) variant;
            switch (val) {
                case "mapnik":
                    map_source = Shumate.MAP_SOURCE_OSM_MAPNIK;
                    break;
                case "transport":
                    map_source = Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP;
                    break;
                default:
                    warning ("map_source_get_mapping_cb: Invalid map_source: %s", val);
                    return false;
            }

            var registry = new Shumate.MapSourceRegistry.with_defaults ();
            value.set_object (registry.get_by_id (map_source));

            return true;
        }

        private static Variant map_source_set_mapping_cb (Value value, VariantType expected_type, void* user_data) {
            string map_source;
            var val = (Shumate.MapSource) value;
            unowned var id = val.id;
            switch (id) {
                case Shumate.MAP_SOURCE_OSM_MAPNIK:
                    map_source = "mapnik";
                    break;
                case Shumate.MAP_SOURCE_OSM_TRANSPORT_MAP:
                    map_source = "transport";
                    break;
                default:
                    warning ("map_source_set_mapping_cb: Invalid map_source: %s", id);
                    // fallback to mapnik
                    map_source = "mapnik";
                    break;
            }

            return new Variant.string (map_source);
        }

        private void on_search_activate () {
            search_entry.grab_focus ();
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

            row.activate.connect (() => {
                //map_widget.go_to_place (row.place);
            });

            return row;
        }
    }
}

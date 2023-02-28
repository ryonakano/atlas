/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2015 Atlas Developers
 *                         2018-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Atlas.MainWindow : Gtk.ApplicationWindow {
    construct {
        title = Application.APP_NAME;

        var header_box = new HeaderBox ();
        set_titlebar (header_box);

        var map_widget = new MapWidget ();
        child = map_widget;

        header_box.go_to_current.connect (() => {
            map_widget.go_to_current ();
        });

        header_box.src_mapnik_selected.connect (() => {
            map_widget.select_mapnik ();
        });

        header_box.src_transport_selected.connect (() => {
            map_widget.select_transport ();
        });

        map_widget.busy_begin.connect (() => {
            header_box.busy_begin ();
        });

        map_widget.busy_end.connect (() => {
            header_box.busy_end ();
        });

        var event_controller_key = new Gtk.EventControllerKey ();
        event_controller_key.key_pressed.connect ((keyval, keycode, state) => {
            if (Gdk.ModifierType.CONTROL_MASK in state) {
                switch (keyval) {
                    case Gdk.Key.q:
                        close_request ();
                        return true;
                    case Gdk.Key.f:
                        header_box.on_f_key_pressed ();
                        return true;
                    default:
                        break;
                }
            }

            return false;
        });
        ((Gtk.Widget) this).add_controller (event_controller_key);

        close_request.connect (() => {
            map_widget.save_map_state ();
            destroy ();
            return false;
        });
    }
}

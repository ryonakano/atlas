/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Spinner : Gtk.Spinner {
    public Spinner () {
        Object (
            no_show_all: true
        );
    }

    public new void activate (string reason) {
        tooltip_text = reason;
        show ();
        start ();
    }

    public void disactivate () {
        hide ();
        stop ();
    }
}

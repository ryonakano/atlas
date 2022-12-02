/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2022 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas.Spinner {
    public static void activate (Gtk.Spinner instance, string reason) {
        instance.tooltip_text = reason;
        instance.show ();
        instance.start ();
    }

    public static void deactivate (Gtk.Spinner instance) {
        instance.hide ();
        instance.stop ();
    }
}

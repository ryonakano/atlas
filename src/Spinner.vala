/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2023 Ryo Nakano <ryonakaknock3@gmail.com>
 */

namespace Atlas.Spinner {
    public static void activate (Gtk.Spinner self, string reason = "") {
        self.tooltip_text = reason;
        self.show ();
        self.start ();
    }

    public static void deactivate (Gtk.Spinner self) {
        self.hide ();
        self.stop ();
    }
}

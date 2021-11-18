/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2014-2021 Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Atlas.View.SearchOptionSelector : Gtk.Popover {

    public SearchOptionSelector () {
        add (new Gtk.Label ("Add Search Options"));
    }
}

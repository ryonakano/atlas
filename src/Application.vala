/*
* Copyright (c) 2014-2018 Atlas Maps Developers
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <https://www.gnu.org/licenses/>.
*
* Authored by: Steffen Schuhmann <dev@sschuhmann.de>
*/

public class Atlas.Application : Gtk.Application {
    private Window window;

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: Build.PROJECT_NAME
        );
    }

    protected override void activate () {
        if (get_windows () != null) {
            window.present ();
            return;
        }

        window = new Window (this);
        window.show_all ();
    }

    public static int main (string[] args) {
        Clutter.init (ref args);
        Gtk.init (ref args);
        var app = new Application ();
        return app.run (args);
    }
}

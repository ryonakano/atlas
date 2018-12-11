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

public class Atlas.App : Gtk.Application {

    construct {
        flags = ApplicationFlags.FLAGS_NONE;
        application_id = Build.PROJECT_NAME;
    }

    public Window window;
    
    protected override void activate () {
        if (get_windows () != null) {
            get_windows ().data.present (); // present window if app is already running
            return;
        }

        window = new Window (this);
        window.show_all ();
    }

    public static int main (string[] args) {
        Clutter.init (ref args);
        Gtk.init (ref args);
        var app = new App ();
        return app.run (args);
    }
}

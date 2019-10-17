/*
* Copyright 2014-2019 Atlas Developers
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
    private MainWindow window;
    public static Settings settings;

    public Application () {
        Object (
            flags: ApplicationFlags.FLAGS_NONE,
            application_id: Build.PROJECT_NAME
        );
    }

    static construct {
        settings = new Settings (Build.PROJECT_NAME);
    }

    protected override void activate () {
        if (get_windows () != null) {
            window.present ();
            return;
        }

        int x, y, w, h;
        x = Atlas.Application.settings.get_int ("position-x");
        y = Atlas.Application.settings.get_int ("position-y");
        w = Atlas.Application.settings.get_int ("window-width");
        h = Atlas.Application.settings.get_int ("window-height");

        window = new MainWindow (this);

        if (Atlas.Application.settings.get_boolean ("maximized")) {
            window.maximize ();
        } else if (x != -1 || y != -1) { // This is not the first time to launch
            window.move (x, y);
        } else { // This is the first time to launch
            window.window_position = Gtk.WindowPosition.CENTER;
        }

        window.set_default_size (w, h);
        window.show_all ();
    }

    public static int main (string[] args) {
        Clutter.init (ref args);
        Gtk.init (ref args);
        var app = new Application ();
        return app.run (args);
    }
}

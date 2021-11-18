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
* Inspired from https://gitlab.gnome.org/GNOME/gnome-clocks/blob/master/src/geocoding.vala
*/

public class Atlas.GeoClue : Object {
    private GClue.Simple? simple;

    public GeoClue () {
    }

    public async GClue.Location? get_current_location () {
        if (simple == null) {
            try {
                simple = yield new GClue.Simple (Build.PROJECT_NAME, GClue.AccuracyLevel.EXACT, null);
            } catch (Error e) {
                warning ("Failed to connect to GeoClue2 service: %s", e.message);
                return null;
            }
        }

        return simple.get_location ();
    }
}

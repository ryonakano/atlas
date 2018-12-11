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

public class Atlas.SavedState : Granite.Services.Settings {

    public double longitude { get; set; }
    public double langitude { get; set; }
    public int zoom_level { get; set; }
    public int window_width { get; set; }
    public int window_height { get; set; }
    public int position_x { get; set; }
    public int position_y { get; set; }
    public bool maximized { get; set; }

    public SavedState () {
        base (Build.PROJECT_NAME);
    }

}

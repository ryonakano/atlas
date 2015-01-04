// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2014 Atlas Developers (https://launchpad.net/atlas-maps)
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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Steffen Schuhmann <dev@sschuhmann.de>
 */

public class Atlas.Window : Gtk.Window {

	private GtkChamplain.Embed champlain;
	private Gtk.SearchEntry search;
	private GLib.Cancellable search_cancellable;
	private Gtk.EntryCompletion location_completion;
	private Gtk.ListStore location_store;
	private Atlas.LocationMarker point;
	private Atlas.Info info;
	
    public Window () {
        var headerbar = new Gtk.HeaderBar ();
        headerbar.show_close_button = true;
        
        search = new Gtk.SearchEntry ();
        search.placeholder_text = _("Search Location");
        search.hexpand = true;

        headerbar.pack_end (search);
        
        set_titlebar (headerbar);
        title = _("Atlas");
        window_position = Gtk.WindowPosition.CENTER;
        set_default_size (800, 600);
        
        location_store = new Gtk.ListStore(2, typeof(Geocode.Place), typeof (string));
        location_completion = new Gtk.EntryCompletion ();
        location_completion.set_minimum_key_length (3);
        search.set_completion (location_completion);
        
        location_completion.set_match_func ((completion, key, iter) => {
        	return true;
        });
        
        location_completion.set_model (location_store);
        location_completion.set_text_column (1);     
        
        location_completion.match_selected.connect ((model, iter) => suggestion_selected (model, iter));   
        
        champlain = new GtkChamplain.Embed ();
        var view = champlain.champlain_view;
        var factory = Champlain.MapSourceFactory.dup_default ();
        view.map_source = factory.create_cached_source (Champlain.MAP_SOURCE_OSM_MAPQUEST);
 //       view.set_min_zoom_level (1);
 //       view.set_max_zoom_level (10);
        
        point = new Atlas.LocationMarker ();
        
        view.zoom_level = 4;
        view.center_on (point.latitude, point.longitude);
        
        destroy.connect (() => {
        	Gtk.main_quit ();
        });
        
        search.search_changed.connect (() => on_search (search.text));
        
        add (champlain);
        
        info = new Atlas.Info ();
        info.location_changed.connect ((loc) => {
        	view.center_on (loc.latitude, loc.longitude);
        	view.zoom_level = 12;
        });
        info.seek.begin ();
        show_all ();
    }
    
    private void on_search (string search_location) {
    	compute_location.begin (search_location);
    }
    
    private bool suggestion_selected (Gtk.TreeModel model, Gtk.TreeIter iter) {
    	Value place;
    	
    	model.get_value (iter, 0, out place);
    	center_map ((Geocode.Place)place);
    	
    	return false;
    }
    
    private void center_map (Geocode.Place loc) {
		point.latitude = loc.location.latitude;
		point.longitude = loc.location.longitude;
		
		champlain.champlain_view.go_to (point.latitude, point.longitude);
		
		var marker_layer = new Champlain.MarkerLayer.full (Champlain.SelectionMode.SINGLE);
    	marker_layer.add_marker (point);
    	champlain.champlain_view.add_layer (marker_layer);
    	
    	champlain.champlain_view.zoom_level = 10;
    }
    
    private async void compute_location (string loc) {
    	if (search_cancellable != null)
    		search_cancellable.cancel ();
    	search_cancellable = new GLib.Cancellable ();
    	
    	var forward = new Geocode.Forward.for_string (loc);
    	try {
    		forward.set_answer_count (10);
    		var places = yield forward.search_async (search_cancellable);
    		
    		Gtk.TreeIter location;
    		if (places != null)
    			location_store.clear ();
    			
    		foreach (var place in places) {
    			location_store.append (out location);
    			location_store.set (location, 0, place, 1, place.name);
    		}
    		
    	} catch (Error error) {
    		warning (error.message);
    	}
   	}
}

public class Atlas.App : Granite.Application {

    construct {
        // This allows opening files. See the open() method below.
        flags |= ApplicationFlags.HANDLES_OPEN;

        // App info
        /*build_data_dir = Build.DATADIR;
        build_pkg_data_dir = Build.PKG_DATADIR;
        build_release_name = Build.RELEASE_NAME;
        build_version_info = Build.VERSION_INFO;*/
        build_version = "0.0.0";

        program_name = "Atlas";
        exec_name = "atlas-maps";

        app_copyright = "2014";
        application_id = "org.pantheon.atlas-maps";
        app_launcher = exec_name+".desktop";
        app_years = "2014";

        about_authors = {"Steffen Schuhmann <dev@sschuhmann.de>", null};

        about_artists = {null};
    }

    public Window window;
    
    protected override void activate () {
        if (get_windows () != null) {
            get_windows ().data.present (); // present window if app is already running
            return;
        }

        window = new Window ();
        window.show_all ();

        Gtk.main ();
    }

    public static int main (string[] args) {
        Gtk.init (ref args);
        Clutter.init (ref args);
        var app = new App ();
        return app.run (args);
    }
}

public class Atlas.LocationMarker : Champlain.Marker {
	public LocationMarker () {
        try {
            Gdk.Pixbuf pixbuf = new Gdk.Pixbuf.from_file ("%s/LocationMarker.svg".printf (Build.PKGDATADIR));
            Clutter.Image image = new Clutter.Image ();
            image.set_data (pixbuf.get_pixels (),
                          pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
                          pixbuf.width,
                          pixbuf.height,
                          pixbuf.rowstride);
            content = image;
            set_size (pixbuf.width, pixbuf.height);
            translation_x = -pixbuf.width/2;
            translation_y = -pixbuf.height;
        } catch (Error e) {
            critical (e.message);
        }
    }
}

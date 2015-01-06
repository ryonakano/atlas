namespace Atlas {

	public class SavedState : Granite.Services.Settings {
	
		public double longitude 	{get; set;}
		public double langitude 	{get; set;}
		public int zoom_level		{get; set;}
		public int window_width 	{get; set;}
		public int window_height 	{get; set;}
		public int position_x		{get; set;}
		public int position_y		{get; set;}
		public bool maximized 		{get; set;}
		
		public SavedState () {
			base ("org.pantheon.atlasmaps.state");
		}
	}
}

/*
 * Copyright (c) 2020 Lafydev. ()
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
*
* Authored by: Lafydev
 */
using Gtk;
//eos constants
private const string HIGH_CONTRAST_BG = "#fff";
private const string HIGH_CONTRAST_FG = "#333";
private const string DARK_BG = "rgba(46, 46, 46, 0.95)";
private const string DARK_FG = "#a5a5a5";
private const string SOLARIZED_LIGHT_BG = "rgba(253, 246, 227, 0.95)";
private const string SOLARIZED_LIGHT_FG = "#586e75";

public string get_cle(string cle) {
	string schema = "io.elementary.terminal.settings"; 
	
	//if schema exists retrieve key
	string couleur="";
	var settings_schema = SettingsSchemaSource.get_default ().lookup (schema, true);
    if (settings_schema != null) {
    if (settings_schema.has_key (cle)) {
        var settings = new GLib.Settings (schema);
        couleur = settings.get_string(cle);
		} 
	} else critical(_("no schema"));
	return (couleur);
}
public void set_cle(string cle, string couleur) {
	string schema = "io.elementary.terminal.settings"; 
	
	//if schema exists, set a new color
	var settings_schema = SettingsSchemaSource.get_default ().lookup (schema, true);
    if (settings_schema != null) {
    if (settings_schema.has_key (cle)) {
        var settings = new GLib.Settings (schema);
        settings.set_string(cle,couleur);
		} 
	} else critical(_("no schema"));
}

    public class Plug : Switchboard.Plug {
		//new entry in switchboard
        public Plug () {
            var settings = new Gee.TreeMap<string, string?> (null, null);
            Object (category: Switchboard.Plug.Category.PERSONAL,
                    code_name: "terminalcolors",
                    display_name: _("terminal colors"),
                    description: _("terminal colors"),
                    icon: "com.github.lafydev.terminalcolors",
                    supported_settings: settings);
        }

        public override Gtk.Widget get_widget () {
			
			
		//put ui in a new frame
        var frm = new Gtk.Frame (_("Choose your terminal's colors"));
		frm.margin = 100;
		frm.set_label_align(0.5f,1.0f);

		//grid 
		var grid = new Gtk.Grid ();
		grid.set_row_spacing (15);
		grid.set_column_spacing (10);

		//Eos Models
		var lblchoix = new Gtk.Label(_("Theme")) ;
		var cmbliste = new Gtk.ComboBoxText ();
		
        string[] modeles ={"",_("eos white"),_("eos solarised"),_("eos black")};
		for (int i=0;i<=3;i++){
				
                cmbliste.append_text(modeles[i]);
                }
        cmbliste.set_active(0);
			

		grid.attach(lblchoix,0,0);
		grid.attach(cmbliste,1,0,2,1);
			
	
	Gtk.ColorButton[] btncol =new Gtk.ColorButton[17];
	
	string[] tab ={"foreground","background"};
	string[] trad = {_("foreground"), _("background")};
			
	//background & foreground 
	var lbl_fg = new Gtk.Label(trad[0]) ;
	grid.attach(lbl_fg,0,1);

	var lbl_bg = new Gtk.Label(trad[1]) ;
	grid.attach(lbl_bg,0,2);

	var rgba = Gdk.RGBA ();
	for (int i=0;i<=1; i++)	
		{ 
		  btncol[i] = new Gtk.ColorButton();
		  rgba.parse (get_cle(tab[i]));
		  btncol[i].set_rgba(rgba);
		  
		  grid.attach(btncol[i],1,i+1,3,1);
	    }
			
	//Change eos theme
		cmbliste.changed.connect(()=> {
       
	   //charger modele
		var rgba_bg = Gdk.RGBA ();
		var rgba_fg = Gdk.RGBA ();
        switch (cmbliste.get_active ()) {
            case 1:
				rgba_bg.parse(HIGH_CONTRAST_BG);
				rgba_fg.parse(HIGH_CONTRAST_FG);
                break;		
			case 2:
				rgba_bg.parse(SOLARIZED_LIGHT_BG);
				rgba_fg.parse(SOLARIZED_LIGHT_FG);
				break;
			case 3:
				rgba_bg.parse(DARK_BG);
				rgba_fg.parse(DARK_FG);
				break;
		}
		if (cmbliste.get_active ()!=0) {
			btncol[0].set_rgba(rgba_fg);
			btncol[1].set_rgba(rgba_bg);
			}
		
            });
			
	//palette
	var lblpalette = new Gtk.Label(_("palette")) ;
	string couleurs= get_cle("palette");  
	string[] coul = couleurs.split(":"); 
	
	//parse colors with separator ":" 
	string[] libelle= {_("Black"),_("Red"),_("Green"),_("Orange"),_("Blue"),_("Purple"),_("Light Blue"),_("Gray")};
			
	grid.attach(lblpalette,0,3);
	for (int i=1;i<=16; i++)	
		{ 
		  btncol[i+1] = new Gtk.ColorButton();
		  if (i<=8) {grid.attach(btncol[i+1],i,4);} 
		  else {grid.attach(btncol[i+1],i-8,5);};
		  
		  rgba.parse (coul[i-1]); //from 0 to 15
		  btncol[i+1].set_rgba(rgba); //buttons from de 2 to 17
		  if (i<=8) btncol[i+1].tooltip_text=libelle[i-1];
	    }
		
		
	var btnappliquer = new Gtk.Button.with_label (_("Apply"));   
	btnappliquer.clicked.connect( ()=> { 
		//foreground & background
		for (int i=0;i<=1;i++) {
			rgba = btncol[i].get_rgba();
			set_cle(tab[i],rgba.to_string());
		}
		//palette reformer la chaine 
		string chpalette="";
		for (int i=2;i<=17;i++) {
			if (i!=2) {chpalette+=":";}
			chpalette+=(btncol[i].get_rgba()).to_string();
		}
		set_cle("palette",chpalette);
	});	
	
	grid.attach(btnappliquer,1,7,2,1);	
	frm.add(grid);	
	frm.show_all();
            
            return frm;
        }

        public override void shown () {
        }

        public override void hidden () {
        }

        public override void search_callback (string location) {
        }

        public override async Gee.TreeMap<string, string> search (string search) {
            return new Gee.TreeMap<string, string> (null, null);
        }

       /* private void load_settings () {
        }*/
    }


public Switchboard.Plug get_plug (Module module) {
    debug ("Activating plug");

    var plug = new Plug ();

    return plug;
}

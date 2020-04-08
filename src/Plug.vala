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
public string get_cle(string cle) {
	string schema = "io.elementary.terminal.settings"; 
	
	//verifie schema existe
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
	
	//verifie schema existe
	var settings_schema = SettingsSchemaSource.get_default ().lookup (schema, true);
    if (settings_schema != null) {
    if (settings_schema.has_key (cle)) {
        var settings = new GLib.Settings (schema);
        settings.set_string(cle,couleur);
		} 
	} else critical(_("no schema"));
}

    public class Plug : Switchboard.Plug {

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
		//affichage ui dans un frame ici
        var frm = new Gtk.Frame (_("Choose your terminal's colors"));
		frm.margin = 100;
		frm.set_label_align(0.5f,1.0f);
        
		var grid = new Gtk.Grid ();
		grid.set_row_spacing (15);
		grid.set_column_spacing (10);
	
	Gtk.Label[] lbl=new Gtk.Label[18];
	Gtk.ColorButton[] btncol =new Gtk.ColorButton[17];
	
	string[] tab ={"foreground","background"};
	string[] trad = {_("foreground"), _("background")};
	//récupérer background
	var rgba = Gdk.RGBA ();
		
	for (int i=0;i<=1; i++)	
		{ lbl[i] = new Gtk.Label(trad[i]) ;
		  btncol[i] = new Gtk.ColorButton();
		  rgba.parse (get_cle(tab[i]));
		  btncol[i].set_rgba(rgba);
		  grid.attach(lbl[i],0,i);
		  grid.attach(btncol[i],1,i,3,1);
	    }
	//palette
	var lblpalette = new Gtk.Label(_("palette")) ;
	string couleurs= get_cle("palette");  
	string[] coul = couleurs.split(":"); 
	
	//couleurs palette séparées par des :" 
	
	grid.attach(lblpalette,0,3);
	for (int i=1;i<=16; i++)	
		{ 
		  btncol[i+1] = new Gtk.ColorButton();
		  if (i<=8) {grid.attach(btncol[i+1],i,3);} 
		  else {grid.attach(btncol[i+1],i-8,4);};
		  
		  rgba.parse (coul[i-1]); //de 0 à 15
		  btncol[i+1].set_rgba(rgba); //col de 2 à 17
		  
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
	
	grid.attach(btnappliquer,1,5);	
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

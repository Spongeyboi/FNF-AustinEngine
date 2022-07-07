package source;

import haxe.Json;
import lime.app.Application;
import openfl.Assets;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

typedef AustinJSON =
{
	preload:Bool,
	title:{
		fnfText:Array<String>,
	    titlex:Float,
	    titley:Float,
	    startx:Float,
	    starty:Float,
	    gfx:Float,
	    gfy:Float,
	    backgroundSprite:String,
	    bpm:Int,
	    tweens:Bool,
	    austinLogo:Bool,
    },
    menu:{
        titleMusic:String,
        mainMusic:String,
        optionMusic:String,
		menuButtonsX:Float,
		austinStyled:Bool,
		centerMenuButtons:Bool,
    },
    socials:{
		twitter:String,
		discord:String,
		github:String,
		Youtube:String,
	},
	gameplay:{
        watermark:Bool,
        watermarkText:String,
        comboSprite:Bool,
		ratings:Array<Dynamic>
	}
}

class AustinData {
    public static function get(){
        var foundFile:Bool = false;
        var fileName:String = Paths.getPreloadPath('austinData.json');
        #if sys
		if(FileSystem.exists(fileName)) {
		#else
		if(Assets.exists(fileName)) {
		#end
			foundFile = true;
		}

        if(foundFile){
            var austinJson:AustinJSON = Json.parse(Paths.getTextFromFile('austinData.json'));
            return austinJson;
        }else{
            return null;
        }
    }
}
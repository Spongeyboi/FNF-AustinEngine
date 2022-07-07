package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.UncaughtErrorEvent;
#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;
import flixel.FlxSprite;
import source.AustinData;



class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = #if sys PreloadState #else TitleState #end; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	} 

	public function new()
	{
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	//Forever Engine code lol
	//Gonna give credits in the code because Yoshdubs worked their ass off to make this work.
	//https://github.com/Yoshubs/Forever-Engine-Legacy
	#if sys
	function onErrorEvent(e:UncaughtErrorEvent):Void{
		var rand:Array<String> = ['"I hate it when my code doesn\'t work!"','"Spongey did it, all him!"','"Worst engine ever! It just crashed on me!"','"Sucks to screw up yer code ain\'t it."','"I\'m surprised someone as small as you didn\'t break anything."','"Vaporeon. Yes."','"That\'s so stupid."'];
		var errMsg:String = "";
		var alsoerrMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "'");

		path = "./logs/crashes/" + "crash_" + dateNow + ".txt";

		errMsg += "---- Begin crash stack ----\n";
		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}
		errMsg += "----- End crash stack -----\n";

		errMsg += "\nFATAL Uncaught Error: " + e.error + "\nAustin Engine has crashed due to an error.\nPlease send the error to SylveonDev on discord, or github for help.\nThe stack dump will be saved to:\n"+path;
		errMsg += '\n' + rand[FlxG.random.int(0,rand.length)];
		alsoerrMsg += e.error;

		if (!FileSystem.exists("./logs/"))
			FileSystem.createDirectory("./logs/");
		if (!FileSystem.exists("./logs/crashes"))
			FileSystem.createDirectory("./logs/crashes");

		File.saveContent(path, errMsg + "\n");

		File.saveContent('./logs/latestError.txt', alsoerrMsg + "\n");
		File.saveContent('./logs/latestStack.txt', errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		var crashDialoguePath:String = "austinCrashDiag";

		#if windows
		crashDialoguePath += ".exe";
		#end

		if (FileSystem.exists("./" + crashDialoguePath))
		{
			Sys.println("Found crash dialog: " + crashDialoguePath);

			#if linux
			crashDialoguePath = "./" + crashDialoguePath;
			#end
			new Process(crashDialoguePath, [path]);
		}
		else
		{
			Sys.println("No crash dialog found! Making a simple alert instead...");
			Application.current.window.alert(errMsg, "Error!");
		}

		Sys.println("Closing Austin Engine now. Goodbye.");
		Sys.exit(1);
	} 
	#end

	private function init(?E:Event):Void
	{
		#if sys Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onErrorEvent); #end

		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		
		#if !html5
		if (AustinData.get().preload)
			initialState = PreloadState;
		#else
		initialState = TitleState;
		ClientPrefs.loadDefaultKeys();
		#end

		
	
		
		// fuck you, persistent caching stays ON during sex
		FlxGraphic.defaultPersist = true;
		// the reason for this is we're going to be handling our own cache smartly
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}
}

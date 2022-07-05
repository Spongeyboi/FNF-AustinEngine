package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon(char:String) {
		var dachar = Character.getIconFromCharacter(char);
		if (dachar == null) return;
		var name:String = 'icons/'+ dachar;
		if(!Paths.fileExists('images/' + name + '-old.png', IMAGE)) name = 'icons/icon-' + dachar; //Imagine how hard this gotta be
		if(Paths.fileExists('images/' + name + '-old.png', IMAGE)){
			if(isOldIcon = !isOldIcon) changeIcon(dachar+'-old');
			else changeIcon(dachar);
		}; //There's an old icon
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			var winningIcon:Bool;

			loadGraphic(file); //Load stupidly first for getting the file size
			
			//This is for determining if the icon has a winning icon
			//We'll floor the icon sizes so abnormally sized icons will not fail the algorithm and cause problems. 
			switch(Math.floor(width) / Math.floor(height)){
				case 3:
					trace('Winning icon enabled for '+char);
					winningIcon = true;
				default:
					winningIcon = false;
			}
			loadGraphic(file, true, Math.floor(width / (winningIcon ? 3 : 2)), Math.floor(height)); //Then load it fr
			iconOffsets[0] = (width - 150) / (winningIcon ? 3 : 2);
			iconOffsets[1] = (width - 150) / (winningIcon ? 3 : 2);
			updateHitbox();
			
			animation.add(char, winningIcon ? [0, 1, 2] : [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}
}

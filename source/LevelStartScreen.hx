package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * ...
 * @author Alex Vrhel
 */
class LevelStartScreen extends FlxSpriteGroup 
{
	public function new(MaxSize:Int = 0) 
	{
		super(MaxSize);
		var bg = new FlxSprite(64, 64).makeGraphic(FlxG.width - 128, FlxG.height - 128, FlxColor.GRAY);
		add(bg);
		var title = new FlxText(70, 70, bg.width - 12, "Day " + (GameData.currentLevel.levelNum + 1));
		title.setFormat(HUD.FONT, 28, HUD.BORDER_COLOR, CENTER);
		add(title);
		
		var text = new FlxText(70, 110, bg.width - 12, "Gather supplies and return home before nightfall");
		text.setFormat(HUD.FONT, 18, HUD.BORDER_COLOR, CENTER);
		add(text);
		
		var contText = new FlxText(70, 230, bg.width - 12, "[space]: begin");
		contText.setFormat(HUD.FONT, 12, HUD.BORDER_COLOR, RIGHT);
		add (contText);
	}
	
	override public function kill():Void {
		trace("killing start screen");
		alive = false;
		exists = false;
	}
	
}
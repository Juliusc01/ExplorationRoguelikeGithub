package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...
 */
class HUD extends FlxTypedGroup<FlxSprite> 
{
	
	private var _sprBackground:FlxSprite;
	private var _txtWood:FlxText;
	private var _sprWood:FlxSprite;
	private var _txtTimer:FlxText;
	private var _timer:Float;

	public function new(Time:Float) 
	{
		super();
		// Top Bar of UI
		_sprBackground = new FlxSprite().makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		_sprBackground.drawRect(0, 31, FlxG.width - 1, 0, FlxColor.WHITE);
		_txtWood = new FlxText(24, 2, 48, "0 / 1", 8);
		_txtWood.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		_sprWood = new FlxSprite(4, 2, AssetPaths.Item_00__png);
		_timer = Time;
		_txtTimer = new FlxText(0, 0, 0);

		
		add(_sprBackground);
		add(_txtWood);
		add(_sprWood);
		add(_txtTimer);
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_timer -= elapsed;
		_txtTimer.text = FlxStringUtil.formatTime(_timer);
	}
}
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
	private var _woodAmt:Int;
	private var _woodMax:Int;
	
	// Reference to the PlayState of our current
	// level, so we can update values.
	private var _ps:PlayState;

	public function new(ps:PlayState) 
	{
		super();
		_ps = ps;
		_woodAmt = 0;
		_woodMax = GameData.currentLevel.woodReq;

		// Top Bar of UI
		_sprBackground = new FlxSprite().makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		_sprBackground.drawRect(0, 31, FlxG.width - 1, 0, FlxColor.WHITE);
		_txtWood = new FlxText(60, 2, 48, Std.string(_woodAmt) + "/" + Std.string(_woodMax), 8);
		_txtWood.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		_sprWood = new FlxSprite(40, 2, AssetPaths.wood__png);
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
		_txtTimer.text = FlxStringUtil.formatTime(_ps.timer);
		_woodAmt = _ps.currentWood;
		_txtWood.text = _woodAmt + "/" + _woodMax;
	}
}
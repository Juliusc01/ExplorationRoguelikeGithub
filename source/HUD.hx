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
	
	private var _txtTimer:FlxText;

	private var _txtWood:FlxText;
	private var _sprWood:FlxSprite;
	private var _woodMax:Int;
	
	private var _txtFood:FlxText;
	private var _sprFood:FlxSprite;
	private var _foodMax:Int;
	

	
	// Reference to the PlayState of our current
	// level, so we can update values.
	private var _ps:PlayState;

	public function new(ps:PlayState) 
	{
		super();
		_ps = ps;
		_woodMax = GameData.currentLevel.woodReq;
		_foodMax = GameData.currentLevel.foodReq;

		// Top Bar of UI
		// TODO: figure out spacing rules for these
		_sprBackground = new FlxSprite().makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		_sprBackground.drawRect(0, 31, FlxG.width - 1, 0, FlxColor.WHITE);
		add(_sprBackground);
		_txtTimer = new FlxText(0, 0, 0);
		_txtTimer.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, 12);
		add(_txtTimer);
		
		_txtWood = new FlxText(40, Constants.TILE_HEIGHT - 2, Constants.TILE_WIDTH * 3, _ps.currentWood + " / " + Std.string(_woodMax));
		_txtWood.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, 12);
		_sprWood = new FlxSprite(40, 0, AssetPaths.wood__png);
		add(_txtWood);
		add(_sprWood);
		
		_txtFood = new FlxText(80, Constants.TILE_HEIGHT - 2, Constants.TILE_WIDTH * 3);
		_txtFood.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, 12);
		_sprFood = new FlxSprite(80, 0, AssetPaths.food__png);
		add(_txtFood);
		add(_sprFood);
		
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		_txtTimer.text = FlxStringUtil.formatTime(_ps.timer);
		_txtWood.text = _ps.currentWood + " / " + _woodMax;
		_txtFood.text = _ps.currentFood + " / " + _foodMax;
	}
}
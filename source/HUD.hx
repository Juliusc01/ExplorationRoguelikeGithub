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
	
	private var _sprTimer:FlxSprite;
	private var _txtTimer:FlxText;

	private var _txtWood:FlxText;
	private var _sprWood:FlxSprite;
	private var _woodMax:Int;
	
	private var _txtFood:FlxText;
	private var _sprFood:FlxSprite;
	private var _foodMax:Int;
	
	private var _txtStone:FlxText;
	private var _sprStone:FlxSprite;
	private var _stoneMax:Int;
	

	
	// Reference to the PlayState of our current
	// level, so we can update values.
	private var _ps:PlayState;

	public function new(ps:PlayState) 
	{
		super();
		_ps = ps;
		_woodMax = GameData.currentLevel.woodReq;
		_foodMax = GameData.currentLevel.foodReq;
		_stoneMax = GameData.currentLevel.stoneReq;

		// Top Bar of UI
		// TODO: figure out spacing rules for these
		_sprBackground = new FlxSprite().makeGraphic(FlxG.width, 32, FlxColor.BLACK);
		_sprBackground.drawRect(0, 31, FlxG.width - 1, 0, FlxColor.WHITE);
		add(_sprBackground);
		_txtTimer = new FlxText(2, Constants.TILE_HEIGHT - 2, 0);
		_txtTimer.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, 12);
		_sprTimer = new FlxSprite(2, 0, AssetPaths.time__png);
		add(_txtTimer);
		add(_sprTimer);
		
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
		
		_txtStone = new FlxText(120, Constants.TILE_HEIGHT - 2, Constants.TILE_WIDTH * 3);
		_txtStone.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, 12);
		_sprStone = new FlxSprite(120, 0, AssetPaths.stone__png);
		add(_txtStone);
		add(_sprStone);
		
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
		_txtStone.text = _ps.currentStone + " / " + _stoneMax;
	}
}
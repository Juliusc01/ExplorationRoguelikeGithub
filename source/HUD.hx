package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...
 */
class HUD extends FlxTypedGroup<FlxSprite> 
{
	
	public static var SPRITE_Y(default, never):Int = 1;
	public static var TEXT_Y(default, never):Int = Const.TILE_HEIGHT - 4;
	
	public static var WIDGET_WIDTH(default, never):Int = Const.TILE_WIDTH * 3;
	public static var WIDGET_HEIGHT(default, never):Int = Const.TILE_HEIGHT * 2;
	public static var HP_WIDGET_WIDTH(default, never):Int = Const.TILE_WIDTH * 4;
	
	public static var FONT_SIZE(default, never):Int = 13;
	
	private var _sprBackground:FlxSprite;
	
	private var _bgTimer:FlxSprite;
	private var _sprTimer:FlxSprite;
	private var _txtTimer:FlxText;

	private var _bgWood:FlxSprite;
	private var _txtWood:FlxText;
	private var _sprWood:FlxSprite;
	private var _woodMax:Int;
	private var _woodTween:FlxTween;
	
	private var _bgFood:FlxSprite;
	private var _txtFood:FlxText;
	private var _sprFood:FlxSprite;
	private var _foodMax:Int;
	
	private var _bgStone:FlxSprite;
	private var _txtStone:FlxText;
	private var _sprStone:FlxSprite;
	private var _stoneMax:Int;
	
	private var _toRemove:FlxSprite;
	
	// Reference to the PlayState of our current
	// level, so we can update values.
	private var _ps:PlayState;

	public function new(ps:PlayState) 
	{
		super();
		
		// Store reference to the play state
		// and the relevant values from the current level.
		_ps = ps;
		_woodMax = GameData.currentLevel.woodReq;
		_foodMax = GameData.currentLevel.foodReq;
		_stoneMax = GameData.currentLevel.stoneReq;

		// Determine whether to show particular
		// elements on the UI based on the requirements
		// of the current level.
		var hasFood:Bool = false;
		if (_foodMax > 0) {
			hasFood = true;
		}
		var hasStone:Bool = false;
		if (_stoneMax > 0) {
			hasStone = true;
		}
		var hasHp:Bool = false;
		if (GameData.currentLevel.levelNum >= Const.FIRST_HP_LVL) {
			hasHp = true;
		}
		
		// Generate the background of the top UI bar.
		_sprBackground = new FlxSprite().makeGraphic(FlxG.width, WIDGET_HEIGHT, FlxColor.WHITE);
		_sprBackground.drawRect(1, 1, FlxG.width - 2, WIDGET_HEIGHT - 2, FlxColor.BLACK);
		add(_sprBackground);
		
		var nextX = 0;
		
		// Add the time widget to the UI. This widget is present on every level,
		// and will always be in the upper left corner.
		_bgTimer = makeWidgetBackground(nextX);
		_txtTimer = makeWidgetText(nextX);
		_sprTimer = makeWidgetSprite(nextX, AssetPaths.time__png);
		add(_bgTimer);
		add(_txtTimer);
		add(_sprTimer);
		nextX += WIDGET_WIDTH;
		
		// Add the health widget to the UI, if we are on a level that uses health.
		if (hasHp) {
			// TODO: implement this.
		}
		
		// Add the wood widget to the UI.
		_bgWood = makeWidgetBackground(nextX);
		_txtWood = makeWidgetText(nextX);
		_sprWood = makeWidgetSprite(nextX, AssetPaths.wood__png);
		add(_bgWood);
		add(_txtWood);
		add(_sprWood);
		nextX += WIDGET_WIDTH;
		
		// Add the food widget to the UI, if necessary.
		if (hasFood) {
			_bgFood = makeWidgetBackground(nextX);
			_txtFood = makeWidgetText(nextX);
			_sprFood = makeWidgetSprite(nextX, AssetPaths.food__png);
			add(_bgFood);
			add(_txtFood);
			add(_sprFood);
			nextX += WIDGET_WIDTH;
		} else {
			this._txtFood = null;
		}
		
		// Add the stone widget to the UI, if nececssary.
		if (hasStone) {
			_bgStone = makeWidgetBackground(nextX);
			_txtStone = makeWidgetText(nextX);
			_sprStone = makeWidgetSprite(nextX, AssetPaths.stone__png);
			add(_bgStone);
			add(_txtStone);
			add(_sprStone);
			nextX += WIDGET_WIDTH;
		} else {
			this._txtStone = null;
		}
		
		forEach(function(spr:FlxSprite)
		{
			spr.scrollFactor.set(0, 0);
		});
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		_txtTimer.text = FlxStringUtil.formatTime(_ps.timer);
		_txtWood.text = _ps.currentWood + " / " + _woodMax;
		if (_txtFood != null) {
			_txtFood.text = _ps.currentFood + " / " + _foodMax;
		}
		if (_txtStone != null) {
			_txtStone.text = _ps.currentStone + " / " + _stoneMax;
		}
	}
	
	public function flashWood():Void {
		if (_woodTween == null) {
			_toRemove = _bgWood.drawRect(_bgWood.x, _bgWood.y, WIDGET_WIDTH, WIDGET_HEIGHT, FlxColor.TRANSPARENT);
			_woodTween = FlxTween.color(_toRemove, 0.5, FlxColor.TRANSPARENT, FlxColor.GREEN, {type: FlxTween.PERSIST, onComplete: resetWoodColor });
		} else {
			_woodTween.start();
		}
	}
	
	private function resetWoodColor(_):Void {
		//_bgWood.color = FlxColor.WHITE;
		FlxTween.color(_toRemove, 0.5, FlxColor.GREEN, FlxColor.TRANSPARENT);
	}
	
	private function makeWidgetBackground(widgetX:Int):FlxSprite {
		var bg = new FlxSprite(widgetX, 0).makeGraphic(WIDGET_WIDTH, WIDGET_HEIGHT, FlxColor.WHITE);
		bg.drawRect(widgetX + 1, 1, WIDGET_WIDTH - 2, WIDGET_HEIGHT - 2, FlxColor.BLACK);
		return bg;
	}
	
	private function makeWidgetText(widgetX:Int):FlxText {
		var txt = new FlxText(widgetX + 1, TEXT_Y, WIDGET_WIDTH - 2);
		txt.setFormat(AssetPaths.RobotoCondensed_Regular__ttf, FONT_SIZE, FlxColor.WHITE, CENTER);
		return txt;
	}
	
	private function makeWidgetSprite(widgetX:Int, assetPath:String):FlxSprite {
		var spr = new FlxSprite(widgetX + Const.TILE_WIDTH, SPRITE_Y, assetPath);
		return spr;
	}
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...
 */
class HUD extends FlxTypedGroup<FlxSprite> 
{
	
	public static var SPRITE_Y(default, never):Int = 1;
	public static var TEXT_Y(default, never):Int = Const.TILE_HEIGHT - 3;
	
	public static var WIDGET_WIDTH(default, never):Int = Const.TILE_WIDTH * 3;
	public static var WIDGET_HEIGHT(default, never):Int = Const.TILE_HEIGHT * 2;
	public static var HP_WIDGET_WIDTH(default, never):Int = Const.TILE_WIDTH * 4;
	public static var HP_BAR_WIDTH(default, never):Int = 50;
	
	public static var FONT_SIZE(default, never):Int = 13;
	
	public static var BORDER_COLOR(default, never):FlxColor = FlxColor.WHITE;
	public static var BG_COLOR(default, never):FlxColor = FlxColor.GRAY;
	
	public static var POPUP_WIDTH(default, never):Int = 250;
	public static var POPUP_HEIGHT(default, never):Int = 32;
	public static var POPUP_X(default, never):Float = (Const.GAME_WIDTH - POPUP_WIDTH) / 2;
	public static var POPUP_Y(default, never):Float = (Const.GAME_HEIGHT - POPUP_HEIGHT) / 2 + 85;
	
	public static var BOTTOM_BAR_Y(default, never):Int = Const.GAME_HEIGHT - WIDGET_HEIGHT;

	public static var FONT(default, never):String = "assets/data/expressway_rg.ttf";
	
	private var _sprBackgroundTop:FlxSprite;
	private var _sprBackgroundBottom:FlxSprite;
	
	private var _bgTimer:FlxSprite;
	private var _sprTimer:FlxSprite;
	private var _txtTimer:FlxText;
	
	private var _bgHealth:FlxSprite;
	private var _barHealth:FlxBar;
	private var _txtHealth:FlxText;
	private var _playerHealth:Int;
	private var _maxHealth:Int;

	private var _bgWood:FlxSprite;
	private var _txtWood:FlxText;
	private var _sprWood:FlxSprite;
	private var _woodMax:Int;
	private var _woodTween:FlxTween;
	private var _doneWithWood:Bool;
	
	private var _bgFood:FlxSprite;
	private var _txtFood:FlxText;
	private var _sprFood:FlxSprite;
	private var _foodMax:Int;
	private var _foodTween:FlxTween;
	private var _doneWithFood:Bool;
	
	private var _bgStone:FlxSprite;
	private var _txtStone:FlxText;
	private var _sprStone:FlxSprite;
	private var _stoneMax:Int;
	private var _stoneTween:FlxTween;
	private var _doneWithStone:Bool;
	
	private var _toRemove:FlxSprite;
	
	private var _bgPowerUp:FlxSprite;
	private var _sprPowerUp:FlxSprite;
	private var _titlePowerUp:FlxText;
	private var _txtPowerUp:FlxText;
	
	private var _nextPowerUpX:Int;
	private var _nextPowerUpY:Int;
	
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
		_sprBackgroundTop = new FlxSprite().makeGraphic(FlxG.width, WIDGET_HEIGHT, BORDER_COLOR);
		_sprBackgroundTop.drawRect(1, 1, FlxG.width - 2, WIDGET_HEIGHT - 2, BG_COLOR);
		add(_sprBackgroundTop);
		
		// Generate the background of the bottom UI bar.
		_sprBackgroundBottom = new FlxSprite(0, BOTTOM_BAR_Y);
		_sprBackgroundBottom.makeGraphic(FlxG.width, WIDGET_HEIGHT, BORDER_COLOR);
		_sprBackgroundBottom.drawRect(1, BOTTOM_BAR_Y + 1, FlxG.width - 2, WIDGET_HEIGHT - 2, BG_COLOR);
		add(_sprBackgroundBottom);
		
		_nextPowerUpX = 16;
		_nextPowerUpY = BOTTOM_BAR_Y + 8;
		trace(BOTTOM_BAR_Y + " is the y coord");
		for (i in 0...GameData.activePowerUps.length) {
			addPowerUpToHUD(GameData.activePowerUps[i]);
		}
		
		var nextX = 0;
		
		// Add the time widget to the UI. This widget is present on every level,
		// and will always be in the upper left corner.
		_bgTimer = makeWidgetBackground(nextX);
		_txtTimer = makeWidgetText(nextX, WIDGET_WIDTH - 2);
		_sprTimer = makeWidgetSprite(nextX, AssetPaths.time__png);
		add(_bgTimer);
		add(_txtTimer);
		add(_sprTimer);
		nextX += WIDGET_WIDTH;
		
		// Add the health widget to the UI, if we are on a level that uses health.
		if (hasHp) {
			_bgHealth = new FlxSprite(nextX, 0).makeGraphic(HP_WIDGET_WIDTH, WIDGET_HEIGHT, BORDER_COLOR);
			_bgHealth.drawRect(1, 1, HP_WIDGET_WIDTH - 2, WIDGET_HEIGHT - 2, BG_COLOR);
			_barHealth = new FlxBar(nextX + Std.int((HP_WIDGET_WIDTH - HP_BAR_WIDTH - 2) / 2), SPRITE_Y + 3, 50, 10);
			_barHealth.createFilledBar(FlxColor.GRAY, FlxColor.GREEN, true, BORDER_COLOR);
			_playerHealth = _maxHealth = _ps.player.hp;
			_barHealth.value = 100;
			_txtHealth = makeWidgetText(nextX, HP_WIDGET_WIDTH - 2);
			add(_bgHealth);
			add(_barHealth);
			add(_txtHealth);
			nextX += HP_WIDGET_WIDTH;
		} else {
			_barHealth = null;
		}
		
		// Add the wood widget to the UI.
		_bgWood = makeWidgetBackground(nextX);
		_txtWood = makeWidgetText(nextX, WIDGET_WIDTH - 2);
		_sprWood = makeWidgetSprite(nextX, AssetPaths.wood__png);
		add(_bgWood);
		add(_txtWood);
		add(_sprWood);
		nextX += WIDGET_WIDTH;
		
		// Add the food widget to the UI, if necessary.
		if (hasFood) {
			_bgFood = makeWidgetBackground(nextX);
			_txtFood = makeWidgetText(nextX, WIDGET_WIDTH - 2);
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
			_txtStone = makeWidgetText(nextX, WIDGET_WIDTH - 2);
			_sprStone = makeWidgetSprite(nextX, AssetPaths.stone__png);
			add(_bgStone);
			add(_txtStone);
			add(_sprStone);
			nextX += WIDGET_WIDTH;
		} else {
			this._txtStone = null;
		}
		
		// Add the powerup tooltip to the UI and make it invisible at first.
		_bgPowerUp = new FlxSprite(POPUP_X, POPUP_Y).makeGraphic(POPUP_WIDTH, POPUP_HEIGHT, BORDER_COLOR);
		_bgPowerUp.drawRect(1, 1, POPUP_WIDTH - 2, POPUP_HEIGHT - 2, BG_COLOR);
		_sprPowerUp = new FlxSprite(POPUP_X + 4, POPUP_Y + (POPUP_HEIGHT - Const.TILE_HEIGHT) / 2);
		_titlePowerUp = new FlxText(POPUP_X + 21, POPUP_Y, POPUP_WIDTH - 22);
		_titlePowerUp.setFormat(FONT, FONT_SIZE - 1, FlxColor.YELLOW, CENTER);
		_txtPowerUp = new FlxText(POPUP_X + 25, POPUP_Y + 15, POPUP_WIDTH - 26);
		_txtPowerUp.setFormat(FONT, FONT_SIZE - 3, FlxColor.WHITE, CENTER);
		trace("x,y: " + POPUP_X + ", " + POPUP_Y);
		add(_bgPowerUp);
		add(_sprPowerUp);
		add(_titlePowerUp);
		add(_txtPowerUp);
		hidePowerUp(null);
		
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
		if (_barHealth != null) {
			_playerHealth = _ps.player.hp;
			// TODO: support ability to change max health with a fn call from playstate
			_barHealth.value = (_playerHealth / _maxHealth) * 100;
			if (_barHealth.value < 25) {
				_barHealth.createFilledBar(FlxColor.GRAY, FlxColor.RED, true, BORDER_COLOR);
			} else {
				_barHealth.createFilledBar(FlxColor.GRAY, FlxColor.GREEN, true, BORDER_COLOR);
			}
			_txtHealth.text = _playerHealth + " / " + _maxHealth;
		}
	}
	
	/**
	 * Shows popup for powerup when it is picked up by the player.
	 */
	public function showPowerUp(pu:PowerUp):Void {
		_sprPowerUp.loadGraphic(pu.imagePath);
		_titlePowerUp.text = pu.name;
		_txtPowerUp.text = pu.effect;
		
		_bgPowerUp.alpha = 1;
		_sprPowerUp.alpha = 1;
		_titlePowerUp.alpha = 1;
		_txtPowerUp.alpha = 1; 
		
		addPowerUpToHUD(pu);
		
		// Hide the popup after 3 seconds.
		// TODO: polish this by using a tween to fade out instead.
		new FlxTimer().start(3, hidePowerUp, 1);
	}
	
	// Hides the popup showing which powerup was just collected
	// by the player.
	private function hidePowerUp(_):Void {
		_sprPowerUp.alpha = 0;
		_bgPowerUp.alpha = 0;
		_titlePowerUp.alpha = 0;
		_txtPowerUp.alpha = 0;
	}
	
	private function addPowerUpToHUD(pu:PowerUp):Void {
		var spr:FlxSprite = new FlxSprite(_nextPowerUpX, _nextPowerUpY);
		spr.loadGraphic(pu.imagePath);
		spr.scale.set(1.5, 1.5);
		add(spr);
		_nextPowerUpX += 32;
	}
	
	public function flashWood():Void {
		if (!_doneWithWood) {
			if (_woodTween == null) {
				_woodTween = FlxTween.color(_txtWood, 0.3, BORDER_COLOR, FlxColor.GREEN,
						{type: FlxTween.PERSIST, onComplete: resetWoodColor, ease: FlxEase.quadIn });
			} else {
				_woodTween.start();
			}
		}
	}
	
	private function resetWoodColor(_):Void {
		if (_ps.hasEnoughWood) {
			_doneWithWood = true;
		} else {
			FlxTween.color(_txtWood, 0.3, FlxColor.GREEN, BORDER_COLOR, { ease: FlxEase.quadOut });
		}
	}
	
	public function flashFood():Void {
		if (!_doneWithFood) {
			if (_foodTween == null) {
				_foodTween = FlxTween.color(_txtFood, 0.3, BORDER_COLOR, FlxColor.GREEN,
						{type: FlxTween.PERSIST, onComplete: resetFoodColor, ease: FlxEase.quadIn });
			} else {
				_foodTween.start();
			}
		}
	}
	
	private function resetFoodColor(_):Void {
		if (_ps.hasEnoughFood) {
			_doneWithFood = true;
		} else {
			FlxTween.color(_txtFood, 0.3, FlxColor.GREEN, BORDER_COLOR, { ease: FlxEase.quadOut });
		}
	}
	
	public function flashStone():Void {
		if (!_doneWithStone) {
			if (_stoneTween == null) {
				_stoneTween = FlxTween.color(_txtStone, 0.3, BORDER_COLOR, FlxColor.GREEN,
						{type: FlxTween.PERSIST, onComplete: resetStoneColor, ease: FlxEase.quadIn });
			} else {
				_stoneTween.start();
			}
		}
	}
	
	private function resetStoneColor(_):Void {
		if (_ps.hasEnoughStone) {
			_doneWithStone = true;
		} else {
			FlxTween.color(_txtStone, 0.3, FlxColor.GREEN, BORDER_COLOR, { ease: FlxEase.quadOut });
		}
	}
	
	private function makeWidgetBackground(widgetX:Int):FlxSprite {
		var bg = new FlxSprite(widgetX, 0).makeGraphic(WIDGET_WIDTH, WIDGET_HEIGHT, BORDER_COLOR);
		bg.drawRect(widgetX + 1, 1, WIDGET_WIDTH - 2, WIDGET_HEIGHT - 2, BG_COLOR);
		return bg;
	}
	
	private function makeWidgetText(widgetX:Int, txtWidth:Int):FlxText {
		var txt = new FlxText(widgetX + 1, TEXT_Y, txtWidth);
		txt.setFormat(FONT, FONT_SIZE, BORDER_COLOR, CENTER);
		return txt;
	}
	
	private function makeWidgetSprite(widgetX:Int, assetPath:String):FlxSprite {
		var spr = new FlxSprite(widgetX + Const.TILE_WIDTH, SPRITE_Y, assetPath);
		return spr;
	}
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Alex Vrhel
 */
class CraftingMenu extends FlxSpriteGroup 
{
	public static var MENU_X = 64;
	public static var MENU_Y = 80;
	public static var MENU_WIDTH = Const.GAME_WIDTH - 128;
	public static var MENU_ITEM_HEIGHT = 37;
	public static var MENU_HEIGHT = MENU_ITEM_HEIGHT * 4;
	public static var ITEM_Y_OFFSET = 7;
	public static var ITEM_X_OFFSET = 45;
	public static var FONT_SIZE = 16;
	public static var FONT_SIZE_SMALL = 13;
	public static var LEVEL_BOX_Y_OFFSET = 9;
	
	private var _sprBg:FlxSprite;
	private var _pointer:FlxSprite;
	private var _selected:Int = 0;
	private var _choices: Array<FlxText>;
	private var _sprLevels: Array<Array<FlxSprite>>;
	private var _sprCosts: Array<FlxSpriteGroup>;
	
	private var _up:Bool;
	private var _down:Bool;
	private var _fire:Bool;
	
	public var costs:Array<Array<Array<Int>>>;
	
	public function new(MaxSize:Int = 0) 
	{
		super(MaxSize);
		_sprBg = new FlxSprite(MENU_X, MENU_Y).makeGraphic(MENU_WIDTH, MENU_HEIGHT, HUD.BORDER_COLOR);
		_sprBg.drawRect(1, 1, MENU_WIDTH - 2, MENU_ITEM_HEIGHT - 2, HUD.BG_COLOR);
		_sprBg.drawRect(1, MENU_ITEM_HEIGHT + 1, MENU_WIDTH - 2, MENU_ITEM_HEIGHT - 2, HUD.BG_COLOR);
		_sprBg.drawRect(1, 2 * MENU_ITEM_HEIGHT + 1, MENU_WIDTH - 2, MENU_ITEM_HEIGHT - 2, HUD.BG_COLOR);
		_sprBg.drawRect(1, 3 * MENU_ITEM_HEIGHT + 1, MENU_WIDTH - 2, MENU_ITEM_HEIGHT - 2, HUD.BG_COLOR);

		add(_sprBg);
		
		_choices = new Array<FlxText>();
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET, "+ Damage", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + MENU_ITEM_HEIGHT, "+ Max Health", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + 2 * MENU_ITEM_HEIGHT, "+ Speed", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + 3 * MENU_ITEM_HEIGHT, "Exit Menu", FONT_SIZE));
		for (i in 0..._choices.length) {
			_choices[i].font = HUD.FONT;
		}
		add(_choices[0]);
		add(_choices[1]);
		add(_choices[2]);
		add(_choices[3]);
		
		for (i in 0...3) {
			add(new FlxSprite(MENU_X, MENU_Y + i * MENU_ITEM_HEIGHT + 1).makeGraphic(10, MENU_ITEM_HEIGHT - 2, HUD.BORDER_COLOR));
		}
		_sprLevels = new Array<Array<FlxSprite>>();
		for (i in 0...3) {
			_sprLevels[i] = new Array<FlxSprite>();
			for (j in 0...4) {
				_sprLevels[i][j] = new FlxSprite(MENU_X + 1, 1 + MENU_Y + i * MENU_ITEM_HEIGHT + (3 - j) * LEVEL_BOX_Y_OFFSET).makeGraphic(8, 8, FlxColor.BLACK);
				add(_sprLevels[i][j]);
			}
		}
		
		_pointer = new FlxSprite(MENU_X + 25, (MENU_ITEM_HEIGHT / 2) + 1, AssetPaths.pointer__png);
		_selected = 0;
		movePointer();
		add(_pointer);
		
		// Init costs of each level-up
		costs = Const.CRAFT_COSTS;
		
		_sprCosts = [new FlxSpriteGroup(), new FlxSpriteGroup(), new FlxSpriteGroup()];
		setItemDisplay(0);
		setItemDisplay(1);
		setItemDisplay(2);
		
		active = false;
		visible = false;
	}
	
	public function show():Void {
		_selected = 0;
		movePointer();
		visible = true;
		active = true;
	}
		
	public function hide():Void {
		visible = false;
		active = false;
	}
	
	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		trace("updating menu");
		
		// Read key input to determine action to take
		if (FlxG.keys.anyJustPressed([SPACE])) {
			_fire = true;
		} else if (FlxG.keys.anyJustPressed([W, UP])) {
			_up = true;
		} else if (FlxG.keys.anyJustPressed([S, DOWN])) {
			_down = true;
		}
		
		// Perform action based on the key inputs detected.
		if (_fire) {
			trace("firing selected: " + _selected);
			selectChoice();
		} else if (_up) {
			if (_selected > 0) {
				_selected--;
			}
			movePointer();
		} else if (_down) {
			if (_selected < 3) {
				_selected++;
			}
			movePointer();
		}
		_fire = false;
		_up = false;
		_down = false;
	}
	
	private function setItemDisplay(itemNum:Int):Void {
		// Remove the old sprites for the cost of this item.
		if (_sprCosts.length > itemNum) {
			remove(_sprCosts[itemNum]);
		}
		
		var toSet = new FlxSpriteGroup();
		
		// If skill is maxed out, simply show a text that says "MAX"
		var currentLvl = GameData.currentCraftLvls[itemNum];
		if (currentLvl >= 4) {
			var maxText = new FlxText(MENU_X + MENU_WIDTH - 50, MENU_Y + itemNum * MENU_ITEM_HEIGHT + 8, 0, "MAX");
			maxText.setFormat(HUD.FONT, FONT_SIZE, HUD.BORDER_COLOR);
			toSet.add(maxText);
		} else {
			var sprCraft = new FlxSprite(MENU_X + MENU_WIDTH - 20, MENU_Y + itemNum * MENU_ITEM_HEIGHT + 1, AssetPaths.craft__png);
			var sprResource = new FlxSprite(MENU_X + MENU_WIDTH - 20, MENU_Y + itemNum * MENU_ITEM_HEIGHT + 18);
			switch(itemNum) {
				case 0:
					sprResource.loadGraphic(AssetPaths.wood__png);
				case 1:
					sprResource.loadGraphic(AssetPaths.food__png);
				case 2:
					sprResource.loadGraphic(AssetPaths.stone__png);
			}
			toSet.add(sprCraft);
			toSet.add(sprResource);
			// Determine cost values, set it for the texts
			var textCraft = new FlxText(MENU_X + MENU_WIDTH - 36, MENU_Y + itemNum * MENU_ITEM_HEIGHT);
			var textResource = new FlxText(MENU_X + MENU_WIDTH - 36, MENU_Y + itemNum * MENU_ITEM_HEIGHT + 16);
			textCraft.setFormat(HUD.FONT, FONT_SIZE_SMALL, HUD.BORDER_COLOR, RIGHT);
			textResource.setFormat(HUD.FONT, FONT_SIZE_SMALL, HUD.BORDER_COLOR, RIGHT);
			textCraft.text = "" + costs[itemNum][currentLvl][0];
			textResource.text = "" + costs[itemNum][currentLvl][1];
			toSet.add(textCraft);
			toSet.add(textResource);
		}
		_sprCosts[itemNum] = toSet;
		add(toSet);
		
		for (i in 0...currentLvl) {
			_sprLevels[itemNum][i].makeGraphic(8, 8, FlxColor.GREEN);
		}
	}
	
	private function movePointer():Void {
		_pointer.y = _choices[_selected].y + (_choices[_selected].height / 2) - 8;
	}
	
	private function selectChoice():Void {
		// Set the selected values
		if (_selected >= 3) {
			GameData.currentPlayState.hideCraftingMenu();
		} else {
			GameData.currentPlayState.addCraftingLvl(_selected);
			setItemDisplay(_selected);
		}
	}
}
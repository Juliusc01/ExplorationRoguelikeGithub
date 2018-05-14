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
	public static var LEVEL_BOX_Y_OFFSET = 9;
	
	private var _sprBg:FlxSprite;
	private var _pointer:FlxSprite;
	private var _selected:Int = 0;
	private var _choices: Array<FlxText>;
	private var _levels: Array<Array<FlxSprite>>;
	
	private var _up:Bool;
	private var _down:Bool;
	private var _fire:Bool;
	
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
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET, "+ DAMAGE", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + MENU_ITEM_HEIGHT, "+ HEALTH", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + 2 * MENU_ITEM_HEIGHT, "+ SPEED", FONT_SIZE));
		_choices.push(new FlxText(_sprBg.x + ITEM_X_OFFSET, _sprBg.y + ITEM_Y_OFFSET + 3 * MENU_ITEM_HEIGHT, "EXIT MENU", FONT_SIZE));
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
		_levels = new Array<Array<FlxSprite>>();
		for (i in 0...3) {
			_levels[i] = new Array<FlxSprite>();
			for (j in 0...4) {
				_levels[i].push(new FlxSprite(MENU_X + 1, 1 + MENU_Y + i * MENU_ITEM_HEIGHT + j * LEVEL_BOX_Y_OFFSET).makeGraphic(8, 8, FlxColor.BLACK));
				add(_levels[i][j]);
				// TODO: apply green by reading powerups from GameData
			}
		}
		
		_pointer = new FlxSprite(MENU_X + 25, (MENU_ITEM_HEIGHT / 2) + 1).makeGraphic(16, 16, FlxColor.RED);
		_selected = 0;
		movePointer();
		add(_pointer);
		
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
	
	private function movePointer():Void {
		_pointer.y = _choices[_selected].y + (_choices[_selected].height / 2) - 8;
	}
	
	private function selectChoice():Void {
		switch(_selected) {
			case 0: // Damage
				
			case 1: // Health
				//GameData.currentPlayState.player.maxHp += 25;
				//GameData.currentPlayState.player.hp += 25;
			case 2: // Speed
				
			case 3:
				GameData.currentPlayState.hideCraftingMenu();
		}
	}

}
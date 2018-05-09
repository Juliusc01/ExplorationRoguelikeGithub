package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class MenuState extends FlxState {
	private var _txtPlay:FlxText;
	private var _btnPlay:FlxText;
	private var _winText:FlxText;
	private var _btnRestart:FlxButton;
	
	override public function create():Void {
		
		if (GameData.currentMenuState == 0) {
			FlxG.mouse.visible = false;
			_txtPlay = new FlxText(0, 0, "Press [space] to start");
			_txtPlay.setFormat(HUD.FONT, 14, FlxColor.WHITE, CENTER);
			_txtPlay.screenCenter();
			add(_txtPlay);
		} else if (GameData.currentMenuState == 1) {
			_winText = new FlxText(0, 0, 0, "Victory!\n\nThe forest grows harsher...");
			_winText.setFormat(HUD.FONT, 14, FlxColor.WHITE, CENTER);
			_winText.screenCenter();
			_winText.y = 64;
			add(_winText);
			_txtPlay = new FlxText(0, 0, "Press space to start day " + Std.string(GameData.currentLevel.levelNum + 2));
			_txtPlay.setFormat(HUD.FONT, 14, FlxColor.WHITE, CENTER);
			_txtPlay.screenCenter();
			_txtPlay.y = 240;
			add(_txtPlay);
		} else if (GameData.currentMenuState == 2) {
			FlxG.mouse.visible = true;
			_winText = new FlxText(0, 0, 0, "You won the game, restart?");
			_winText.screenCenter();
			_winText.y = 120;
			add(_winText);
			_btnRestart = new FlxButton(0, 0, "Restart", clickRestart);
			_btnRestart.screenCenter();
			add(_btnRestart);
		}
		
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([SPACE])) {
			if (GameData.currentMenuState == 0 || GameData.currentMenuState == 1) {
				clickPlay();
			} else if (GameData.currentMenuState == 2) {
				clickRestart();
			}
			
		}
		
	}
	
	private function clickPlay():Void {
		if (GameData.currentLevel == null) {
			GameData.currentLevel = GameData.levels[0];
		} else {
			GameData.currentLevel = GameData.levels[GameData.currentLevel.levelNum+1];
		}
		FlxG.switchState(new PlayState());
	}
	
	private function clickRestart():Void {
		GameData.currentLevel = null;
		GameData.currentMenuState = 0;
		FlxG.switchState(new MenuState());
	}
}
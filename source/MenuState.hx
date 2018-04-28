package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class MenuState extends FlxState {
	private var _btnPlay:FlxButton;
	private var _winText:FlxText;
	private var _btnRestart:FlxButton;
	
	override public function create():Void {
		
		if (GameData.currentMenuState == 0) {
			_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
			_btnPlay.screenCenter();
			add(_btnPlay);
		} else if (GameData.currentMenuState == 1) {
			_winText = new FlxText(140, 140, 0, "You won this level, click to continue!");
			add(_winText);
			_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
			_btnPlay.screenCenter();
			add(_btnPlay);
		} else if (GameData.currentMenuState == 2) {
			_winText = new FlxText(140, 140, 0, "You won the game, restart?");
			add(_winText);
			_btnRestart = new FlxButton(0, 0, "Restart", clickRestart);
			_btnRestart.screenCenter();
			add(_btnRestart);
		}
		
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
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
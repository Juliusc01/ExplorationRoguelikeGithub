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
	
	override public function create():Void {
		
		if (GameData.currentMenuState == 0) {
			_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
			_btnPlay.screenCenter();
			add(_btnPlay);
		} else if (GameData.currentMenuState == 1) {
			_winText = new FlxText(160, 160, 0, "You won this level, click to continue!");
			add(_winText);
			_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
			_btnPlay.screenCenter();
			add(_btnPlay);
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
}
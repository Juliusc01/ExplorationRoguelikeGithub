package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class LoseState extends FlxState {
	private var _btnRestart:FlxButton;
	private var _loseText:FlxText;
	
	override public function create():Void {
		FlxG.mouse.visible = true;
		_loseText = new FlxText(0, 0, 0, "You lose this level, restart?");
		_loseText.screenCenter();
		_loseText.y = 120;
		add(_loseText);
		_btnRestart = new FlxButton(0, 0, "Restart", clickRestart);
		_btnRestart.screenCenter();
		add(_btnRestart);
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([SPACE])) {
			clickRestart();
		}
	}
	
	private function clickRestart():Void {
		trace("in menu: " + GameData.activePowerUps.length);
		GameData.myLogger.logLevelStart(GameData.currentLevel.levelNum);
		FlxG.switchState(new PlayState());
	}
}
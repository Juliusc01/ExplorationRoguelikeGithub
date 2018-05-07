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
			_winText = new FlxText(0, 0, 0, "You won this level, click to continue!");
			_winText.screenCenter();
			_winText.y = 120;
			add(_winText);
			_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
			_btnPlay.screenCenter();
			add(_btnPlay);
		} else if (GameData.currentMenuState == 2) {
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
		GameData.myLogger.logActionWithNoLevel(LoggingActions.CLICK_START);
		if (GameData.currentLevel == null) {
			GameData.currentLevel = GameData.levels[0];
		} else {
			GameData.myLogger.logLevelEnd({won: true});
			GameData.currentLevel = GameData.levels[GameData.currentLevel.levelNum+1];
		}
		GameData.myLogger.logLevelStart(GameData.currentLevel.levelNum);
		FlxG.switchState(new PlayState());
	}
	
	private function clickRestart():Void {
		GameData.currentLevel = null;
		GameData.currentMenuState = 0;
		FlxG.switchState(new MenuState());
	}
}
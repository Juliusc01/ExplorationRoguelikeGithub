package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class MenuState extends FlxState {
	private var _txtPlay:FlxText;
	private var _btnPlay:FlxText;
	private var _winText:FlxText;
	private var _btnRestart:FlxButton;
	private var _canContinue:Bool;
	
	override public function create():Void {
		
		if (GameData.currentMenuState == 0) {
			add(new FlxSprite(0, 0, AssetPaths.title__png));
			FlxG.mouse.visible = false;
			_canContinue = true;
			var titleText = new FlxText(0, 0, "Forest Floor");
			titleText.setFormat(40, FlxColor.WHITE, CENTER);
			titleText.screenCenter();
			titleText.y = 30;
			add(titleText);
			_txtPlay = new FlxText(0, 0, "Press [space] to start");
			_txtPlay.setFormat(14, FlxColor.WHITE, CENTER);
			_txtPlay.screenCenter();
			_txtPlay.y = 280;
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
			new FlxTimer().start(0.5, displayContinueText, 1);
		} else if (GameData.currentMenuState == 2) {
			FlxG.mouse.visible = true;
			_winText = new FlxText(0, 0, 0, "Congratulations, you won!\n\nPlay again?");
			_winText.setFormat(HUD.FONT, 14, FlxColor.WHITE, CENTER);
			_winText.screenCenter();
			_winText.y = 64;
			add(_winText);
			_btnRestart = new FlxButton(0, 0, "Play Again", clickRestart);
			_btnRestart.screenCenter();
			_btnRestart.y = 160;
			add(_btnRestart);
		}
		
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([SPACE]) && _canContinue) {
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
		GameData.myLogger.logLevelStart(GameData.currentLevel.levelNum, {restart:false});
		FlxG.switchState(new PlayState());
	}
	
	private function clickRestart():Void {
		GameData.currentLevel = null;
		GameData.currentMenuState = 0;
		GameData.myLogger.logActionWithNoLevel(LoggingActions.RESTART_GAME);
		FlxG.switchState(new MenuState());
	}
	
	private function displayContinueText(_):Void {
		add(_txtPlay);
		_canContinue = true;
	}
}
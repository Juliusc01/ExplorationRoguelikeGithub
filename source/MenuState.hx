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
	public static var TOP_Y(default, never):Int = 30;
	public static var BOT_Y(default, never):Int = 280;
	
	private var _txtPlay:FlxText;
	private var _btnPlay:FlxText;
	private var _txtTop:FlxText;
	private var _txtMid:FlxText;
	private var _btnRestart:FlxButton;
	private var _canContinue:Bool;
	
	override public function create():Void {
		add(new FlxSprite(0, 0, AssetPaths.title__png));
		if (GameData.currentMenuState == 0) {
			FlxG.mouse.visible = false;
			_canContinue = true;
			_txtTop = new FlxText(0, 0, "Forest Floor");
			_txtTop.setFormat(40, FlxColor.WHITE, CENTER);
			_txtTop.screenCenter();
			_txtTop.y = TOP_Y;
			add(_txtTop);
			_txtPlay = new FlxText(0, 0, "Press [space] to start");
			_txtPlay.setFormat(14, FlxColor.WHITE, CENTER);
			_txtPlay.screenCenter();
			_txtPlay.y = BOT_Y;
			add(_txtPlay);
		} else if (GameData.currentMenuState == 1) {
			_txtTop = new FlxText(0, 0, 0, "Victory!\n\nThe forest grows harsher...");
			_txtTop.setFormat(20, FlxColor.WHITE, CENTER);
			_txtTop.screenCenter();
			_txtTop.y = TOP_Y;
			add(_txtTop);
			_txtPlay = new FlxText(0, 0, "Press [space] to start day " + Std.string(GameData.currentLevel.levelNum + 2));
			_txtPlay.setFormat(14, FlxColor.WHITE, CENTER);
			_txtPlay.screenCenter();
			_txtPlay.y = BOT_Y;
			new FlxTimer().start(0.5, displayContinueText, 1);
		} else if (GameData.currentMenuState == 2) {
			FlxG.mouse.visible = true;
			_txtTop = new FlxText(0, 0, 0, "Congratulations, you won!\n\nPlay again?");
			_txtTop.setFormat(14, FlxColor.WHITE, CENTER);
			_txtTop.screenCenter();
			_txtTop.y = TOP_Y;
			add(_txtTop);
			_btnRestart = new FlxButton(0, 0, "Play Again", clickRestart);
			_btnRestart.screenCenter();
			_btnRestart.y = BOT_Y;
			add(_btnRestart);
		}
		
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([SPACE]) && _canContinue) {
			if (GameData.currentMenuState == 0) {
				setExplanationText(0);
				GameData.currentMenuState = 1;
			} else if (GameData.currentMenuState == 1) {
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
	
	private function setExplanationText(levelNum:Int):Void {
		switch (levelNum) {
			case 0:
				_txtMid = new FlxText(0, 0, "Return home\nwith supplies before\nnight falls!");
				_txtMid.setFormat(14, FlxColor.WHITE, CENTER);
				_txtMid.screenCenter();
				_txtMid.y = 120;
				remove(_txtTop);
				add(_txtMid);
				_txtPlay.text = "Press [space] to begin day 1";
				_txtPlay.screenCenter();
				_txtPlay.y = BOT_Y;
		}
		
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
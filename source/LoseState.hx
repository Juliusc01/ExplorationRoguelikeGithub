package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxTimer;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class LoseState extends FlxState {
	private var _btnRestart:FlxButton;
	private var _loseText:FlxText;
	private var _canContinue:Bool;
	
	override public function create():Void {
		add(new FlxSprite(0, 0, AssetPaths.title__png));
		_canContinue = false;
		FlxG.mouse.visible = true;
		var text:String = "You ran out of health!\n";
		if (!GameData.lostToHp) {
			text = "You ran out of time!\n";
		}
		_loseText = new FlxText(0, 0, 0, text + "Try again?", 20);
		_loseText.setFormat(20, CENTER);
		_loseText.screenCenter();
		_loseText.y = 120;
		add(_loseText);
		_btnRestart = new FlxButton(0, 0, "Retry day " + (GameData.currentLevel.levelNum + 1), clickRestart);
		_btnRestart.screenCenter();
		_btnRestart.y = 200;
		//add(_btnRestart);
		new FlxTimer().start(0.25, allowContinue);
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([SPACE])) {
			clickRestart();
		}
	}
	
	
	private function allowContinue(_):Void {
		_canContinue = true;
		add(_btnRestart);
	}
	
	private function clickRestart():Void {
		if (_canContinue)  {
			GameData.myLogger.logLevelStart(GameData.currentLevel.levelNum, {restart:true, inControlGroup:GameData.inControlGroup, isGood: GameData.isGoodAtGame, isBad: GameData.isBadAtGame});
			FlxG.switchState(new PlayState());
		}
	}
}
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
		_loseText = new FlxText(160, 160, 0, "You lose this level, restart?");
		add(_loseText);
		_btnRestart = new FlxButton(0, 0, "Restart", clickRestart);
		_btnRestart.screenCenter();
		add(_btnRestart);
		super.create();
	}
	

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
	private function clickRestart():Void {
		FlxG.switchState(new PlayState());
	}
}
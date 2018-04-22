package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.ui.FlxButton;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class MenuState extends FlxState {
	private var _btnPlay:FlxButton;
	override public function create():Void {
		_btnPlay = new FlxButton(0, 0, "Play", clickPlay);
		_btnPlay.screenCenter();
		add(_btnPlay);
		super.create();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}
	
	private function clickPlay():Void {
		FlxG.switchState(new PlayState());
	}
}
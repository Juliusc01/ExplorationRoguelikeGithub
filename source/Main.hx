package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(336, 304, MenuState));
	}
}
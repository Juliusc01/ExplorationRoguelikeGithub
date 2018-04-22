package;

import flixel.FlxGame;
import openfl.display.Sprite;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class Main extends Sprite {
	public function new() {
		super();
		addChild(new FlxGame(320, 320, MenuState));
	}
}
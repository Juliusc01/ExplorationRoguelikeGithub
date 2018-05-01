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
		addChild(new FlxGame(Const.GAME_WIDTH, Const.GAME_HEIGHT, MenuState));
		makePowerUps();
	}
	
	private function makePowerUps() {
		GameData.powerUps = [new PowerUp(0, 0, "000", "testName", "testEffect", "item_00.png")];
	}
	
}
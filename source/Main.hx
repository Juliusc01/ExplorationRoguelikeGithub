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
		GameData.powerUps = [new PowerUp("000", "Shiny Armor", "Longer protection after being hit", "000_armor.png")];
		GameData.powerUps.push(new PowerUp("001", "Strangely Familiar Sword", "Damage Increased", "001_sword.png"));
		GameData.powerUps.push(new PowerUp("002", "Lucky Axe", "Chance of Extra Wood from Trees", "002_axe.png"));
		GameData.powerUps.push(new PowerUp("003", "Reflective Shield", "Reflect some damage back to enemies", "003_shield.png"));
		GameData.powerUps.push(new PowerUp("004", "Little Light of Mine", "Extra time before nightfall", "004_candle.png"));
		GameData.activePowerUps = new Array<PowerUp>();
	}
	
}
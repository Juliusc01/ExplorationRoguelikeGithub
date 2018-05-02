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
		GameData.powerUps.push(new PowerUp("002", "Lucky Axe", "Chance of extra wood from trees", "002_axe.png"));
		GameData.powerUps.push(new PowerUp("003", "Reflective Shield", "Reflect some damage back to enemies", "003_shield.png"));
		GameData.powerUps.push(new PowerUp("004", "Little Light of Mine", "Extra time before nightfall", "004_candle.png"));
		GameData.powerUps.push(new PowerUp("005", "Sturdy Boots", "Knockback from enemies reduced", "005_heavy_boots.png"));
		GameData.powerUps.push(new PowerUp("006", "Fairy Wings", "Immunity to terrain effects", "006_wings.png"));
		GameData.powerUps.push(new PowerUp("007", "Boots of Extreme Speed", "Speed increased", "007_boots.png"));
		// Power ups with IDs starting with "1" can only be spawned once food is introduced
		GameData.powerUps.push(new PowerUp("100", "Foraging Gloves", "Chance of extra food from bushes", "100_gloves.png"));
		// Power ups with IDs starting with "2" can only be spawned once gold is introduced
		
		
		// Power ups with IDs starting with "3" can only be spwaned once stone is introduced

		GameData.activePowerUps = new Array<PowerUp>();
	}
	
}
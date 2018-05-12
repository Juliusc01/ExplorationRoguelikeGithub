package;

import CapstoneLogger;
import flixel.FlxG;
import flixel.FlxGame;
import openfl.display.Sprite;
/**
 * ...
 * @author Julius Christenson + Alex Vrhel
 */

class Main extends Sprite {
	
	private var canStart:Bool = false;
	
	public function new() {
		super();
		GameData.myLogger = new CapstoneLogger(1802, "explorerogue", "bbe6affcdec9c0192930c77f9cc45788", 1, true);
		//Just generate ID for now, eventually also grab ID (once we get save data)
		var userID:String = GameData.myLogger.getSavedUserId();
		if (userID == null) {
			userID = GameData.myLogger.generateUuid();
			GameData.myLogger.setSavedUserId(userID);
		}
		GameData.myLogger.startNewSession(userID, this.callback);

	}
	
	public function callback(canStart:Bool):Void {
		addChild(new FlxGame(Const.GAME_WIDTH, Const.GAME_HEIGHT, MenuState, 1, 60, 60, true));
		makePowerUps();
		initRoomOptions();
	}
	
	private function makePowerUps() {
		GameData.powerUps = [new PowerUp("000", "Shiny Armor", "Longer protection after being hit", "000_armor.png")];
		//GameData.powerUps.push(new PowerUp("001", "Strangely Familiar Sword", "Damage Increased", "001_sword.png"));
		GameData.powerUps.push(new PowerUp("002", "Lucky Axe", "Chance of extra wood from trees", "002_axe.png"));
		GameData.powerUps.push(new PowerUp("003", "Reflective Shield", "Reflect some damage back to enemies", "003_shield.png"));
		GameData.powerUps.push(new PowerUp("004", "Little Light of Mine", "Time until night extended", "004_candle.png"));
		GameData.powerUps.push(new PowerUp("005", "Sturdy Boots", "Knockback from projectiles reduced", "005_heavy_boots.png"));
		GameData.powerUps.push(new PowerUp("006", "Fairy Wings", "Immunity to terrain effects", "006_wings.png"));
		GameData.powerUps.push(new PowerUp("007", "Boots of Extreme Speed", "Speed increased", "007_boots.png"));
		GameData.powerUps.push(new PowerUp("008", "Adrenaline Rush", "Kills increase momvement speed", "008_speed.png"));
		GameData.powerUps.push(new PowerUp("009", "Gift of Life", "Health regenerates over time", "009_regen.png"));
		GameData.powerUps.push(new PowerUp("010", "Amulet of Shielding", "Protects you for one hit each day", "010_amulet_shielding.png"));
		
		// Power ups with IDs starting with "1" can only be spawned once food is introduced
		GameData.powerUps.push(new PowerUp("100", "Foraging Gloves", "Chance of extra food from bushes", "100_gloves.png"));
		GameData.powerUps.push(new PowerUp("101", "Hunting Knife", "Chance of extra food from rabbits", "101_knife.png"));
		GameData.powerUps.push(new PowerUp("102", "Rabbit Charm", "Stops rabbits from running away", "102_animal.png"));
		
		// Power ups with IDs starting with "2" can only be spawned once stone is introduced

		
		// Power ups with IDs starting with "3" can only be spwaned once crafting is introduced

		
		GameData.activePowerUps = new Array<PowerUp>();
		//GameData.activePowerUps.push(new PowerUp("010", "Amulet of Shielding", "Protects you for one hit each day", "010_amulet_shielding.png"));
		//GameData.activePowerUps.push(new PowerUp("003", "Reflective Shield", "Reflect some damage back to enemies", "003_shield.png"));
		//GameData.activePowerUps.push(new PowerUp("008", "Adrenaline Rush", "Kills increase movement speed", "008_speed.png"));
		//GameData.activePowerUps.push(new PowerUp("102", "Rabbit Charm", "Stops rabbits from running away", "102_animal.png"));
		//GameData.activePowerUps.push(new PowerUp("009", "Gift of Life", "Health regenerates over time", "009_regen.png"));

	}
	
	private function initRoomOptions() {
		GameData.roomOptions.set("E", 1);
		GameData.roomOptions.set("ES", 1);
		GameData.roomOptions.set("ESW", 1);
		GameData.roomOptions.set("ESWN", 2);
		GameData.roomOptions.set("ESN", 1);
		GameData.roomOptions.set("EW", 1);
		GameData.roomOptions.set("EWN", 1);
		GameData.roomOptions.set("EN", 1);
		GameData.roomOptions.set("S", 0);
		GameData.roomOptions.set("SW", 1);
		GameData.roomOptions.set("SWN", 1);
		GameData.roomOptions.set("SN", 1);
		GameData.roomOptions.set("W", 0);
		GameData.roomOptions.set("WN", 1);
		GameData.roomOptions.set("N", 0);
		
		GameData.powerUpRoomOptions.set("E", 0);
		GameData.powerUpRoomOptions.set("S", 0);
		GameData.powerUpRoomOptions.set("W", 0);
		GameData.powerUpRoomOptions.set("N", 0);
	}
	
}
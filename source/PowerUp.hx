package;

import flixel.FlxSprite;
using StringTools;
/**
 * ...
 * @author Julius Christenson
 */
class PowerUp extends FlxSprite 
{
	public var powerUpID:String;
	public var name:String;
	public var effect:String;
	public var imagePath:String;
	public var isActive:Bool;
	
	
	public function new(powerUpID:String, name:String, effect:String, imagePath:String) 
	{
		super(0, 0);
		this.powerUpID = powerUpID;
		this.name = name;
		this.effect = effect;
		this.imagePath = "assets/images/items/" + imagePath;
		this.isActive = false;
		
		var w:Int = Const.TILE_WIDTH;
		var h:Int = Const.TILE_HEIGHT;
		
		loadGraphic(this.imagePath, false, w, h);
		setSize(w, h);
	}
	
	public function changeXY(X:Float, Y:Float) {
		this.x = X;
		this.y = Y;
	}
	
	public function isAllowedOnLevel():Bool {
		if (StringTools.startsWith(powerUpID, "0")) {
			return true;
		} else if (StringTools.startsWith(powerUpID, "1") &&
				GameData.currentLevel.levelNum >= Const.FIRST_FOOD_LVL) {
			return true;
		} else if (StringTools.startsWith(powerUpID, "2") &&
				GameData.currentLevel.levelNum >= Const.FIRST_GOLD_LVL) {
			return true;		
		} else if (StringTools.startsWith(powerUpID, "3") &&
				GameData.currentLevel.levelNum >= Const.FIRST_STONE_LVL) {
			return true;
		} else {
			return false;
		}
	}
	
	public static function powerUpIDS():Array<String> {
		var IDS = new Array<String>();
		for (powerup in GameData.activePowerUps) {
			IDS.push(powerup.powerUpID);
		}
		return IDS;
	}
	
	public static function copy(toCopy:PowerUp):PowerUp {
		trace(toCopy.imagePath.substr(20));
		var res:PowerUp = new PowerUp(toCopy.powerUpID, toCopy.name, toCopy.effect, toCopy.imagePath.substr(20));
		res.isActive = toCopy.isActive;
		return res;
	}
	
	/**
	 * Returns whether the given powerup ID is
	 * active in the current game by checking in the
	 * GameData.activePowerUps array.
	 */
	public static function isActiveById(id:String):Bool {
		for (i in 0...GameData.activePowerUps.length) {
			var current = GameData.activePowerUps[i];
			if (current.powerUpID == id) {
				return true;
			}
		}
		return false;
	}
	
}

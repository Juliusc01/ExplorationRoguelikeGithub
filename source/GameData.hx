package;
import flixel.math.FlxRandom;

/**
 * Global object which holds values that other components
 * of the game need access to, including current values
 * for the level and data about the game state that is cleaner
 * to separate from the PlayState which will change between each level.
 * @author Alex Vrhel
 */
class GameData 
{
	public static var currentLevel:LevelData = null;	
	public static var currentPlayState:PlayState = null;
	public static var currentMenuState:Int = 0;
	public static var currentCraft:Int = 0;
	public static var currentCraftLvls:Array<Int> = [0, 0, 0]; // Dmg, HP, Speed
	public static var powerUps:Array<PowerUp> = null;
	public static var activePowerUps:Array<PowerUp> = null;
	public static var enemiesRandom:Array<Int> = [0, 1, 2, 3, 4];
	public static var myLogger:CapstoneLogger;
	public static var testingHome:Bool = false;
	public static var roomToTest = AssetPaths.level_3E__oel;
	public static var lostToHp:Bool = false;
	public static var inControlGroup:Bool = (new FlxRandom()).bool();
	public static var isGoodAtGame:Bool = false;
	public static var isBadAtGame:Bool = false;
	public static var difficultyModifier:Float = 1.2;
	public static var totalDamageTaken:Int = 0;
	public static var totalTimeLeft:Float = 0;
	
	
	// LevelData(levelNum, time, rooms, wood, food, stone)
	public static var testRooms = new LevelData(-1, 180, -1, true, 1, 1, 0, 1, false);
	public static var level0 = new LevelData(0, 60, 1, true, 1, 0, 0, 1.0, false);
	//public static var level1 = new LevelData(1, 60, 2, true, 1, 0, 0, 1.0, false);
	public static var level1 = new LevelData(1, 60, 2, true, 1, 0, 0, 1.0, false);
	public static var level2 = new LevelData(2, 90, 5, true, 4, 1, 0, 1.0, false); // first food
	public static var level3 = new LevelData(3, 90, 6, true, 6, 2, 1, 1.0); // first stone, first crafting
	public static var level4 = new LevelData(4, 90, 7, true, 6, 3, 1, 1.2); 
	public static var level5 = new LevelData(5, 120, 8, true, 7, 3, 2, 1.4); 
	public static var level6 = new LevelData(6, 150, 10, false, 9, 4, 3, 1.6);
	public static var level7 = new LevelData(7, 180, 12, false, 10, 5, 5, 1.8);
	public static var level8 = new LevelData(8, 180, 14, false, 11, 6, 5, 2);
	public static var level9 = new LevelData(9, 210, 16, false, 13, 6, 6, 2.2);
	public static var level10 = new LevelData(10, 210, 18, false, 14, 7, 7, 2.4);
	public static var level11 = new LevelData(11, 210, 20, false, 15, 10, 5, 2.6);
	//Uncomment to test out a specific room:
	//public static var levels:Array<LevelData> = [testRooms];
	public static var levels:Array<LevelData> = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11];

	// Map storing room shape to max template number.
	// Gives the maximum number to append to the file
	// for rooms of the given shape.
	public static var roomOptions:Map<String, Int> = new Map<String, Int>();
	
	// Map storing room shape to max powerup template number.
	public static var powerUpRoomOptions:Map<String, Int> = new Map<String, Int>();
}
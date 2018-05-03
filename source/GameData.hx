package;

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
	public static var powerUps:Array<PowerUp> = null;
	public static var activePowerUps:Array<PowerUp> = null;
	public static var enemiesRandom:Array<Int> = [0, 1, 2];
	
	// LevelData(levelNum, time, rooms, wood, food, stone)
	public static var level0 = new LevelData(0, 60, -1, 1, 0, 0);
	public static var level1 = new LevelData(1, 60, -1, 1, 0, 0);
	public static var level2 = new LevelData(2, 60, -1, 1, 0, 0);
	public static var level3 = new LevelData(3, 60, 4, 4, 0, 0); 
	public static var level4 = new LevelData(4, 60, 5, 5, 1, 0); // first food
	public static var level5 = new LevelData(5, 60, 7, 7, 2, 0); 
	public static var level6 = new LevelData(6, 60, 7, 8, 3, 0); // first gold
	public static var level7 = new LevelData(7, 75, 9, 10, 3, 0);
	public static var level8 = new LevelData(8, 75, 8, 8, 3, 2); // first stone
	public static var level9 = new LevelData(9, 90, 10, 9, 4, 3);
	public static var level10 = new LevelData(10, 90, 12, 10, 5, 5);
	public static var level11 = new LevelData(11, 90, 14, 11, 6, 5);
	public static var level12 = new LevelData(12, 120, 16, 13, 6, 6);
	public static var level13 = new LevelData(13, 120, 18, 14, 7, 7);
	public static var level14 = new LevelData(14, 120, 20, 15, 10, 5);
	
	public static var levels:Array<LevelData> = [level0, level1, level2, level3, level4, level5, level6, level7, level8, level9, level10, level11, level12, level13, level14];

	// Map storing room shape to max template number.
	// Gives the maximum number to append to the file
	// for rooms of the given shape.
	public static var roomOptions:Map<String, Int> = new Map<String, Int>();


}
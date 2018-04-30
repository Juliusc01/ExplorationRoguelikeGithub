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
	//public static var currentWood:Int = 0;
	//public static var currentFood:Int = 0;
	//public static var currentStone:Int = 0;
	
	public static var currentPlayState:PlayState = null;
	public static var currentMenuState:Int = 0;
	public static var powerUps:Array<PowerUp> = null;
	
	// TODO: somewhere cleaner to hold the level data for each one,
	// or is putting them all globally available here fine?
	public static var tut0 = new LevelData(0, 60, -1, 1, 0, 0);
	public static var tut1 = new LevelData(1, 60, -1, 1, 0, 0);
	public static var tut2 = new LevelData(2, 60, -1, 1, 0, 0);
	public static var level0 = new LevelData(3, 60, 5, 5, 1, 2);
	public static var level1 = new LevelData(4, 60, 8, 10, 3, 0);
	public static var levels:Array<LevelData> = [tut0, tut1, tut2, level0, level1];
	
}
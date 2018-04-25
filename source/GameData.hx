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
	public static var currentLevel:LevelData;
	
	//public static var currentWood:Int = 0;
	//public static var currentFood:Int = 0;
	//public static var currentStone:Int = 0;
	
	public static var currentPlayState:PlayState = null;
	
	// TODO: somewhere cleaner to hold the level data for each one,
	// or is putting them all globally available here fine?
	public static var level0 = new LevelData(0, 60, 1, 1, 1, 0, 0);
}
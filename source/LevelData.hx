package;

/**
 * Encapsulates the data for a single level, including all of
 * the values that are relevant for that level (size of map, level number,
 * time limit, and required resources). Meant to be exposed globally
 * through GameData so components of the game can refer to properties
 * of the current level.
 * @author Alex Vrhel
 */
class LevelData 
{
	public var levelNum:Int;
	public var timeLimit:Float;
	//public var width:Int;
	//public var height:Int;
	public var numRooms:Int;
	public var woodReq:Int;
	public var foodReq:Int;
	public var stoneReq:Int;
	public var difficulty:Float;
	
	public function new(num:Int, time:Int, numRooms:Int, wood:Int, ?food:Int = 0, ?stone:Int = 0, ?difficulty:Float = 1.0) {
		this.levelNum = num;
		this.timeLimit = time;
		//this.width = w;
		//this.height = h;
		this.numRooms = numRooms;
		this.woodReq = wood;
		this.foodReq = food;
		this.stoneReq = stone;
		this.difficulty = difficulty;
	}
	
}
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
	public var width:Int;
	public var height:Int;
	public var woodReq:Int;
	public var foodReq:Int;
	public var stoneReq:Int;
	
	public function new(num:Int, time:Int, w:Int, h:Int, wood:Int, ?food:Int = 0, ?stone:Int = 0) {
		this.levelNum = num;
		this.timeLimit = time;
		this.width = w;
		this.height = h;
		this.woodReq = wood;
		this.foodReq = food;
		this.stoneReq = stone;
	}
	
}
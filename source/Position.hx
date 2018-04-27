package;
import flash.geom.Point;

/**
 * ...
 * @author Alex Vrhel
 */
class Position 
{
	public var x:Int;
	public var y:Int;
	public function new(x:Int, y:Int) 
	{
		this.x = x;
		this.y = y;
	}
	
	public function toString():String {
		return x + "," + y;
	}
	
	public static function asPosition(str:String):Position {
		var parts = str.split(",");
		return new Position(Std.parseInt(parts[0]), Std.parseInt(parts[1]));
	}
}
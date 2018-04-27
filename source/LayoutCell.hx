package;

/**
 * ...
 * @author Alex Vrhel
 */

class LayoutCell 
{
	public var x:Int;
	public var y:Int;
	public var exists:Bool;
	
	// Whether or not the cell has
	// a door in that direction.
	public var hasE:Bool;
	public var hasS:Bool;
	public var hasW:Bool;
	public var hasN:Bool;

	public function new(x:Int, y:Int) 
	{
		this.x = x;
		this.y = y;
		this.hasE = false;
		this.hasS = false;
		this.hasW = false;
		this.hasN = false;
	}
	
	/**
	 * Returns a string representation of the
	 * room's shape, using one capital letter
	 * for each direction the room has an exit.
	 * Order of the letters uses the unit circle
	 * ordering used elsewhere (starting at E,
	 * going clockwise).
	 */
	public function getShape():String {
		var val:String = "";
		if (this.hasE) {
			val += "E";
		}
		if (this.hasS) {
			val += "S";
		}
		if (this.hasW) {
			val += "W";
		}
		if (this.hasN) {
			val += "N";
		}
		trace("shape is: " + val);
		return val;
	}
}
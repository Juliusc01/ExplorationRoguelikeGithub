package;

/**
 * ...
 * @author Alex Vrhel
 */
class Anvil extends Feature 
{

	public function new(X:Float=0, Y:Float=0) 
	{
		var w = Const.ANVIL_WIDTH;
		var h = Const.ANVIL_HEIGHT;
		super(X, Y, w, h, AssetPaths.anvil__png);
	}
	
	override public function touchBySword():Void {
		trace("touched anvil!");
		// TODO: implement
	}
}
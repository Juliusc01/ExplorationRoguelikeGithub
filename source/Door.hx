package;

import flixel.FlxSprite;

/**
 * ...
 * @author Alex Vrhel
 */
class Door extends FlxSprite 
{
	public var direction:Direction;
	
	public function new(X:Float=0, Y:Float=0, dir:Direction) 
	{
		super(X, Y);
		this.direction = dir;
		var w:Int = Const.TILE_WIDTH;
		var h:Int = Const.TILE_HEIGHT;
		if (dir == Direction.WEST || dir == Direction.EAST) {
			h *= 2;
			loadGraphic(AssetPaths.doorEW__png, false, w, h);
		} else {
			w *= 2;
			loadGraphic(AssetPaths.doorNS__png, false, w, h);
		}
		setSize(w, h);
		set_immovable(true);

	}
	
}

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
		trace("made door with direction:" + direction);
	}
	
}

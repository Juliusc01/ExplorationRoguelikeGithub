package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author Alex Vrhel
 */
class Door extends FlxSprite 
{
	public var direction:Int; //TODO: figure out enums
	
	public function new(X:Float=0, Y:Float=0, Direction:Int) 
	{
		super(X, Y);
		this.direction = Direction;
		trace("made door with direction:" + direction);
	}
	
}